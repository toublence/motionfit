import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:uuid/uuid.dart';
import 'ad_eligibility.dart';
import 'ad_failure.dart';
import 'ad_loader.dart';
import 'ad_sdk.dart';
import 'ad_unit_ids.dart';
import '../analytics/analytics_service.dart';
import '../diagnostics/crash_reporting_service.dart';
import '../privacy/privacy_consent_service.dart';

class AdService extends ChangeNotifier {
  AdService({
    required AnalyticsService analytics,
    CrashReportingService? crashReporting,
    PrivacyConsentService? consent,
    AdSdk? sdk,
    DateTime Function()? clock,
    String? Function(AdFormat)? unitResolver,
  }) : _analytics = analytics,
       _crash = crashReporting,
       _consent =
           consent ?? PrivacyConsentService(crashReporting: crashReporting),
       sdk = sdk ?? GoogleAdSdk(),
       _clock = clock ?? DateTime.now,
       _unitResolver = unitResolver ?? _defaultUnit;
  final AnalyticsService _analytics;
  final CrashReportingService? _crash;
  final PrivacyConsentService _consent;
  final AdSdk sdk;
  final DateTime Function() _clock;
  final String? Function(AdFormat) _unitResolver;
  static String? _defaultUnit(AdFormat format) => switch (format) {
    AdFormat.interstitial => MotionFitAdUnits.interstitial,
    AdFormat.native => MotionFitAdUnits.native,
    AdFormat.banner => MotionFitAdUnits.banner,
  };
  static const interstitialMaxAge = Duration(minutes: 55);
  bool _ready = false;
  bool _sdkInitialized = false;
  bool _consentRetryRequired = false;
  bool _disposed = false;
  bool _foreground = true;
  bool _fullScreenShowing = false;
  int _completedWorkoutCount = 0;
  int? _snapshotCount;
  Set<String> _snapshotIds = {};
  final Set<String> _savedCompletions = {};
  int? get completedWorkoutCount =>
      _snapshotCount == null ? null : _completedWorkoutCount;
  bool _onboardingCompleted = false;
  int _initializationFailures = 0;
  Future<bool>? _initialization;
  Timer? _initializationRetry;
  Timer? _expiry;
  AdLoader? _interstitial;
  DateTime? _loadedAt;
  DateTime? _lastInterstitialShownAt;
  bool get ready => _ready;
  bool get foreground => _foreground;
  bool get fullScreenShowing => _fullScreenShowing;
  DateTime? get lastInterstitialShownAt => _lastInterstitialShownAt;
  bool get interstitialLoading => _interstitial?.loading ?? false;
  String? unitFor(AdFormat format) => _unitResolver(format);

  void record(String name, Map<String, Object> fields) =>
      _analytics.adEvent(name, {
        'workout_completion_count': _completedWorkoutCount,
        'onboarding_completed': _onboardingCompleted,
        'foreground': _foreground,
        ...fields,
      });

  // Foreground recovery must not depend on a successful workout DB snapshot.
  void updateOnboardingContext(bool completed) {
    _onboardingCompleted = completed;
  }

  void updatePolicyContext({
    required bool onboardingCompleted,
    required int completedWorkoutCount,
    Set<String> completedSessionIds = const {},
  }) {
    _onboardingCompleted = onboardingCompleted;
    _snapshotCount = completedWorkoutCount;
    _snapshotIds = completedSessionIds;
    _reconcileCompletions();
  }

  void workoutCompleted(String key) {
    _savedCompletions.add(key);
    _reconcileCompletions();
  }

  void _reconcileCompletions() {
    if (_snapshotCount != null) {
      _completedWorkoutCount =
          _snapshotCount! + _savedCompletions.difference(_snapshotIds).length;
    }
    _syncInterstitial();
  }

  void setForeground(bool value) {
    if (_disposed || value == _foreground) return;
    _foreground = value;
    _consent.setForeground(value);
    if (!value) {
      _initializationRetry?.cancel();
    }
    _syncInterstitial();
    notifyListeners();
    if (value && _onboardingCompleted) unawaited(initialize());
  }

  Future<bool> initialize() {
    if (_disposed || !_foreground || !_consent.supported) {
      return Future.value(false);
    }
    return _initialization ??= Future<bool>.microtask(
      _initialize,
    ).whenComplete(() => _initialization = null);
  }

  Future<bool> _initialize() async {
    _initializationRetry?.cancel();
    final elapsed = Stopwatch()..start();
    var stage = 'consent';
    try {
      if (_ready) {
        final allowed = await _consent.canRequestAds();
        if (allowed && !_consentRetryRequired) {
          _syncInterstitial();
          return true;
        }
        if (!allowed) _consent.invalidate();
      }
      _setReady(false);
      final result = await _consent.requestTrackingAndConsent();
      if (_disposed) return false;
      record('mf2_ads_init_result', {
        'stage': result.stage,
        'allowed': result.allowed,
        'retryable': result.retryable,
        'elapsed_ms': elapsed.elapsedMilliseconds,
        ...?result.failure?.parameters,
      });
      _consentRetryRequired = result.retryable;
      if (!result.allowed) {
        if (result.retryable) _scheduleInitializationRetry();
        return false;
      }
      record('mf2_ads_configuration', {
        'test_mode': MotionFitAdUnits.testMode,
        for (final format in AdFormat.values)
          '${format.name}_unit': unitFor(format) ?? 'unconfigured',
        'sdk': 'google_mobile_ads_9.0.0',
      });
      record('mf2_ads_init_started', {'stage': 'sdk'});
      stage = 'sdk';
      elapsed.reset();
      if (!_sdkInitialized) {
        await sdk.initialize().timeout(const Duration(seconds: 20));
        _sdkInitialized = true;
      }
      if (_disposed) return false;
      if (!await _consent.canRequestAds()) {
        _consent.invalidate();
        _scheduleInitializationRetry();
        return false;
      }
      _initializationFailures = 0;
      _setReady(true);
      record('mf2_ads_init_result', {
        'stage': 'sdk',
        'result': 'ready',
        'elapsed_ms': elapsed.elapsedMilliseconds,
      });
      if (_consentRetryRequired) _scheduleInitializationRetry();
      _syncInterstitial();
      return true;
    } on Object catch (error, stack) {
      if (!_disposed) {
        record('mf2_ads_init_result', {
          'stage': stage,
          'result': 'failed',
          'elapsed_ms': elapsed.elapsedMilliseconds,
          'error_kind': error is TimeoutException
              ? 'timeout'
              : 'invocation_error',
        });
        if (_crash != null) {
          unawaited(
            _crash.recordNonFatal(error, stack, reason: 'ad_initialization'),
          );
        }
        _scheduleInitializationRetry();
      }
      return false;
    }
  }

  void _scheduleInitializationRetry() {
    if (_disposed || !_foreground || _initializationRetry?.isActive == true) {
      return;
    }
    _initializationRetry = Timer(
      AdLoader.retryDelay(++_initializationFailures),
      () {
        _initializationRetry = null;
        unawaited(initialize());
      },
    );
  }

  void _setReady(bool value) {
    if (_ready == value) return;
    _ready = value;
    if (!value) {
      _interstitial?.setEnabled(false);
      _interstitial?.discard('consent_change');
    }
    notifyListeners();
  }

  Future<AdHandle> createAd({
    required AdFormat format,
    required String unitId,
    required AdCallbacks callbacks,
    AdSize? size,
    NativeTemplateStyle? templateStyle,
  }) async {
    if (!MotionFitAdUnits.valid(unitId)) throw const AdFailure('configuration');
    if (_disposed || !_ready || !_foreground || !callbacks.isActive()) {
      throw const AdFailure('inactive');
    }
    if (!await _consent.canRequestAds()) {
      _setReady(false);
      _consent.invalidate();
      unawaited(initialize());
      throw const AdFailure('consent_blocked');
    }
    if (_disposed || !_ready || !_foreground || !callbacks.isActive()) {
      throw const AdFailure('inactive');
    }
    return sdk.create(
      format: format,
      unitId: unitId,
      callbacks: callbacks,
      size: size,
      templateStyle: templateStyle,
    );
  }

  void _syncInterstitial() {
    if (_disposed) return;
    final unit = unitFor(AdFormat.interstitial);
    if (unit == null) return;
    _interstitial ??= AdLoader(
      format: AdFormat.interstitial,
      placement: 'workout_complete',
      unitId: unit,
      telemetry: record,
      create: (callbacks) => createAd(
        format: AdFormat.interstitial,
        unitId: unit,
        callbacks: callbacks,
      ),
    )..addListener(_onInterstitialChanged);
    _interstitial!.setEnabled(
      _ready &&
          _foreground &&
          !_fullScreenShowing &&
          AdEligibility.canPreloadInterstitial(
            completedWorkoutCount: _completedWorkoutCount,
          ),
    );
  }

  void _onInterstitialChanged() {
    if (_disposed) return;
    if (_interstitial?.ad == null && !_fullScreenShowing) {
      _loadedAt = null;
      _expiry?.cancel();
    }
    if (_interstitial?.ad != null && _loadedAt == null) {
      _loadedAt = _clock();
      _expiry?.cancel();
      _expiry = Timer(interstitialMaxAge, () {
        _loadedAt = null;
        _interstitial?.discard('expired');
        _syncInterstitial();
      });
    }
  }

  Future<bool> showInterstitialIfAvailable({
    required DateTime? lastInterstitialShownAt,
    required int completedWorkoutCount,
    DateTime? now,
    bool Function()? isOpportunityValid,
    String? workoutSessionId,
    void Function(DateTime)? onShown,
  }) async {
    final opportunity = const Uuid().v7();
    final fields = <String, Object>{
      'opportunity_id': opportunity,
      'ad_format': 'interstitial',
      'ad_placement': 'workout_complete',
      'workout_session_id': ?workoutSessionId,
      if (_loadedAt != null)
        'cache_age_ms': _clock().difference(_loadedAt!).inMilliseconds,
    };
    record('mf2_ad_opportunity', fields);
    _completedWorkoutCount = completedWorkoutCount;
    final current = now ?? _clock();
    final latest = _lastInterstitialShownAt == null
        ? lastInterstitialShownAt
        : lastInterstitialShownAt == null ||
              _lastInterstitialShownAt!.isAfter(lastInterstitialShownAt)
        ? _lastInterstitialShownAt
        : lastInterstitialShownAt;
    String? reason;
    if (!AdEligibility.canShowInterstitial(
      completedWorkoutCount: completedWorkoutCount,
    )) {
      reason = 'first_workout_protected';
    } else if (!AdEligibility.isInterstitialCooldownElapsed(
      lastShownAt: latest,
      now: current,
    )) {
      reason = 'cooldown_10_minutes';
    } else if (_disposed ||
        !_foreground ||
        isOpportunityValid?.call() == false) {
      reason = 'inactive_opportunity';
    } else if (_fullScreenShowing) {
      reason = 'full_screen_showing';
    } else if (!_ready) {
      reason = 'sdk_not_ready';
    }
    if (reason != null) {
      record('mf2_ad_decision', {
        ...fields,
        'result': 'skipped',
        'skip_reason': reason,
      });
      if (!_disposed) _syncInterstitial();
      return false;
    }
    if (_loadedAt != null &&
        _clock().difference(_loadedAt!) >= interstitialMaxAge) {
      _loadedAt = null;
      _interstitial?.discard('expired');
    }
    final loader = _interstitial;
    final ad = loader?.takeAd();
    if (ad == null) {
      record('mf2_ad_decision', {
        ...fields,
        'result': 'skipped',
        'skip_reason': loader?.loading == true ? 'load_pending' : 'cache_empty',
      });
      _syncInterstitial();
      return false;
    }
    fields.addAll(loader!.context);
    _expiry?.cancel();
    _loadedAt = null;
    _fullScreenShowing = true;
    loader.setEnabled(false);
    var shown = false;
    var finished = false;
    final done = Completer<bool>();
    // A missing native callback must not strand navigation. Keep ownership of
    // the uncertain native presentation until its terminal callback, so a late
    // presentation can never overlap a second ad.
    final watchdog = Timer(const Duration(seconds: 30), () {
      if (!shown && !finished) {
        record('mf2_ad_show_result', {
          ...fields,
          'result': 'unconfirmed_timeout',
        });
        if (!done.isCompleted) done.complete(false);
      }
    });
    void finish([AdFailure? error]) {
      if (finished) return;
      finished = true;
      watchdog.cancel();
      _fullScreenShowing = false;
      if (error != null) {
        record(shown ? 'mf2_ad_show_terminal' : 'mf2_ad_show_result', {
          ...fields,
          'result': 'failed',
          ...error.parameters,
        });
      }
      if (!shown && error == null) {
        record('mf2_ad_show_result', {
          ...fields,
          'result': 'dismissed_without_show',
        });
      }
      record('mf2_ad_disposed', {
        ...fields,
        'reason': error == null ? 'dismissed' : 'show_failed',
      });
      unawaited(ad.dispose().catchError((Object _) {}));
      if (!done.isCompleted) done.complete(shown);
      _syncInterstitial();
    }

    unawaited(
      Future<void>.microtask(() async {
        try {
          if (!await _consent.canRequestAds().timeout(
            const Duration(seconds: 2),
          )) {
            _setReady(false);
            _consent.invalidate();
            finish(const AdFailure('consent_blocked'));
            return;
          }
          if (_disposed ||
              !_foreground ||
              isOpportunityValid?.call() == false) {
            record('mf2_ad_decision', {
              ...fields,
              'result': 'skipped',
              'skip_reason': 'inactive_opportunity',
            });
            finish(const AdFailure('inactive'));
            return;
          }
          record('mf2_ad_decision', {...fields, 'result': 'allowed'});
          record('mf2_ad_show_attempted', fields);
          await ad.show(
            AdShowCallbacks(
              showed: () {
                if (finished || shown) return;
                shown = true;
                _lastInterstitialShownAt = _clock();
                record('mf2_ad_show_result', {...fields, 'result': 'showed'});
                try {
                  onShown?.call(_lastInterstitialShownAt!);
                } on Object {
                  record('mf2_ad_cooldown_persist_failed', fields);
                }
              },
              dismissed: () => finish(),
              failed: finish,
            ),
          );
        } on Object catch (error) {
          if (!shown) {
            finish(
              AdFailure(
                error is TimeoutException ? 'timeout' : 'invocation_error',
                message: error.toString(),
              ),
            );
          } else {
            record('mf2_ad_show_invocation_error', fields);
          }
        }
      }),
    );
    return done.future;
  }

  @override
  void dispose() {
    _disposed = true;
    _initializationRetry?.cancel();
    _expiry?.cancel();
    _interstitial?.removeListener(_onInterstitialChanged);
    _interstitial?.dispose();
    super.dispose();
  }
}
