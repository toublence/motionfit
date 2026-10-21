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
       sdk = sdk ?? GoogleAdSdk(crashReporting: crashReporting),
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
    AdFormat.appOpen => MotionFitAdUnits.appOpen,
  };
  static const appOpenMaxAge = Duration(hours: 4);
  static const appOpenWait = Duration(seconds: 3);
  AdLoader? _appOpen;
  DateTime? _appOpenLoadedAt;
  Timer? _appOpenExpiry;
  Timer? _appOpenDeadline;
  bool _appOpenEnabled = false;
  int _appOpenEntryCount = 0;
  final Set<String> _monetizedWorkoutIds = {};
  bool Function()? _appOpenValid;
  void Function(DateTime)? _appOpenOnShown;
  Map<String, Object>? _appOpenOpportunity;
  bool _appOpenPresenting = false;
  bool get appOpenPending => _appOpenOpportunity != null || _appOpenPresenting;

  static const interstitialMaxAge = Duration(minutes: 55);
  bool _ready = false;
  bool _sdkInitialized = false;
  bool _consentRetryRequired = false;
  bool _trackingDeferred = false;

  void retryDeferredTrackingAuthorization() {
    if (_trackingDeferred && _foreground && _onboardingCompleted) {
      unawaited(initialize(retryDeferredTracking: true));
    }
  }

  bool _disposed = false;
  bool _foreground = true;
  bool _visible = true;
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
  bool get visible => _visible;

  // A presented fullscreen ad covers the Flutter view, which iOS reports as
  // inactive → hidden → paused until dismissal. Loads keep running meanwhile so
  // the next ad is ready instead of being cancelled and restarted.
  bool get loadsAllowed => _visible || _fullScreenShowing;
  bool get fullScreenShowing => _fullScreenShowing;
  DateTime? get lastInterstitialShownAt => _lastInterstitialShownAt;
  bool get interstitialLoading => _interstitial?.loading ?? false;
  String? unitFor(AdFormat format) => _unitResolver(format);

  void record(String name, Map<String, Object> fields) =>
      _analytics.adEvent(name, {
        'ad_policy_version': AdEligibility.policyVersion,
        'fullscreen_cooldown_seconds':
            AdEligibility.interstitialCooldown.inSeconds,
        'app_open_visit_count': _appOpenEntryCount,
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
    _syncFullScreenLoads();
  }

  /// [value] is the active (resumed) app; consent and fullscreen ads need it.
  /// [visible] also covers iOS inactive (system alerts, Control Center, the
  /// unfocused side of iPad split view), where view ads and loads continue.
  void setForeground(bool value, {bool? visible}) {
    final shown = value || (visible ?? false);
    if (_disposed || (value == _foreground && shown == _visible)) return;
    _foreground = value;
    _visible = shown;
    _consent.setForeground(value);
    if (!value) {
      cancelAppOpenOpportunity('background');
      _initializationRetry?.cancel();
    }
    _syncFullScreenLoads();
    notifyListeners();
    if (value && _onboardingCompleted) {
      unawaited(initialize(retryDeferredTracking: true));
    }
  }

  Future<bool> initialize({bool retryDeferredTracking = false}) {
    if (_disposed || !_foreground || !_consent.supported) {
      return Future.value(false);
    }
    if (_trackingDeferred && !retryDeferredTracking) {
      return Future.value(_ready);
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
          _syncFullScreenLoads();
          return true;
        }
        if (!allowed) {
          _setReady(false);
          _consent.invalidate();
        }
      }
      _trackingDeferred = false;
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
      _trackingDeferred = result.failure?.kind == 'att_pending';
      if (!result.retryable) _initializationFailures = 0;
      if (!result.allowed) {
        _setReady(false);
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
        _setReady(false);
        _consent.invalidate();
        _scheduleInitializationRetry();
        return false;
      }
      _setReady(true);
      record('mf2_ads_init_result', {
        'stage': 'sdk',
        'result': 'ready',
        'elapsed_ms': elapsed.elapsedMilliseconds,
      });
      if (_consentRetryRequired) _scheduleInitializationRetry();
      _syncFullScreenLoads();
      return true;
    } on Object catch (error, stack) {
      if (!_disposed) {
        _setReady(false);
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
    if (_disposed ||
        !_foreground ||
        _trackingDeferred ||
        _initializationRetry?.isActive == true) {
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
      _appOpen?.setEnabled(false);
      _appOpen?.discard('consent_change');
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
    if (!MotionFitAdUnits.valid(unitId)) {
      throw const AdFailure('invalid_unit');
    }
    if (_disposed || !_ready || !loadsAllowed || !callbacks.isActive()) {
      throw const AdFailure('inactive');
    }
    if (!await _consent.canRequestAds()) {
      _setReady(false);
      _consent.invalidate();
      unawaited(initialize());
      throw const AdFailure('consent_blocked');
    }
    if (_disposed || !_ready || !loadsAllowed || !callbacks.isActive()) {
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

  void _syncFullScreenLoads() {
    _syncInterstitial();
    _syncAppOpen();
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
          loadsAllowed &&
          _onboardingCompleted &&
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
        _syncFullScreenLoads();
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
      reason = 'no_completed_workout';
    } else if (workoutSessionId != null &&
        _monetizedWorkoutIds.contains(workoutSessionId)) {
      reason = 'workout_already_monetized';
    } else if (!AdEligibility.isInterstitialCooldownElapsed(
      lastShownAt: latest,
      now: current,
    )) {
      reason = 'fullscreen_cooldown';
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
      if (!_disposed) _syncFullScreenLoads();
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
      _syncFullScreenLoads();
      return false;
    }
    fields.addAll(loader!.context);
    _expiry?.cancel();
    _loadedAt = null;
    return _presentFullScreen(
      ad,
      fields,
      isOpportunityValid: isOpportunityValid,
      onShown: onShown,
    );
  }

  Future<bool> _presentFullScreen(
    AdHandle ad,
    Map<String, Object> fields, {
    bool Function()? isOpportunityValid,
    void Function(DateTime)? onShown,
  }) {
    _fullScreenShowing = true;
    _syncFullScreenLoads();
    var shown = false;
    var finished = false;
    var abandoned = false;
    final done = Completer<bool>();
    void release() => unawaited(ad.dispose().catchError((Object _) {}));
    late final Timer watchdog;
    void finish([AdFailure? error]) {
      if (finished) return;
      finished = true;
      watchdog.cancel();
      _fullScreenShowing = false;
      if (error != null) {
        record(shown ? 'mf2_ad_show_terminal' : 'mf2_ad_show_result', {
          ...fields,
          'result': error.kind == 'unconfirmed_timeout'
              ? 'unconfirmed_timeout'
              : 'failed',
          ...error.parameters,
        });
      }
      if (!shown && error == null) {
        record('mf2_ad_show_result', {
          ...fields,
          'result': 'dismissed_without_show',
        });
      }
      // An abandoned ad stays alive so a late presentation still reports its
      // callbacks; its own terminal callback disposes it.
      if (!abandoned) {
        record('mf2_ad_disposed', {
          ...fields,
          'reason': error == null ? 'dismissed' : 'show_failed',
        });
        release();
      }
      if (!done.isCompleted) done.complete(shown);
      _syncFullScreenLoads();
    }

    // A missing native callback must not strand navigation or the session:
    // the iOS plugin drops show() without any callback when its native ad is
    // gone. A presentation that still arrives late starts the cooldown, so no
    // second fullscreen ad can follow it.
    watchdog = Timer(const Duration(seconds: 30), () {
      if (shown) return;
      abandoned = true;
      finish(const AdFailure('unconfirmed_timeout'));
    });
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
                if (shown || (finished && !abandoned)) return;
                shown = true;
                _lastInterstitialShownAt = _clock();
                final workoutId = fields['workout_session_id'];
                if (workoutId is String) _monetizedWorkoutIds.add(workoutId);
                record('mf2_ad_show_result', {
                  ...fields,
                  'result': abandoned ? 'late_showed' : 'showed',
                });
                try {
                  onShown?.call(_lastInterstitialShownAt!);
                } on Object {
                  record('mf2_ad_cooldown_persist_failed', fields);
                }
              },
              dismissed: () => abandoned ? release() : finish(),
              failed: (error) => abandoned ? release() : finish(error),
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

  String? _appOpenBlockReason() {
    if (_disposed || !_foreground || _appOpenValid?.call() != true) {
      return 'inactive_opportunity';
    }
    if (!_onboardingCompleted) return 'onboarding_incomplete';
    if (_consent.trackingAuthorizationPending) return 'tracking_prompt_pending';
    if (!AdEligibility.canShowAppOpen(appEntryCount: _appOpenEntryCount)) {
      return 'app_open_intro_protected';
    }
    if (!AdEligibility.isInterstitialCooldownElapsed(
      lastShownAt: _lastInterstitialShownAt,
      now: _clock(),
    )) {
      return 'fullscreen_cooldown';
    }
    if (_fullScreenShowing) return 'full_screen_showing';
    return null;
  }

  /// One bounded loading-screen opportunity. A late load is cached for a later
  /// foreground, never displayed after the user has entered the app.
  void beginAppOpenOpportunity({
    required String trigger,
    required int appEntryCount,
    required DateTime? lastFullScreenShownAt,
    required bool Function() isOpportunityValid,
    required void Function(DateTime) onShown,
  }) {
    if (_disposed) return;
    if (unitFor(AdFormat.appOpen) == null) {
      record('mf2_ad_decision', {
        'ad_format': 'appOpen',
        'ad_placement': 'app_open',
        'result': 'skipped',
        'skip_reason': 'unconfigured',
      });
      return;
    }
    // Repeated resume notifications cannot extend the deadline or show twice.
    if (appOpenPending) return;
    _appOpenEnabled = true;
    _appOpenEntryCount = appEntryCount;
    if (lastFullScreenShownAt != null &&
        (_lastInterstitialShownAt == null ||
            lastFullScreenShownAt.isAfter(_lastInterstitialShownAt!))) {
      _lastInterstitialShownAt = lastFullScreenShownAt;
    }
    _appOpenValid = isOpportunityValid;
    _appOpenOnShown = onShown;
    _appOpenOpportunity = {
      'ad_format': 'appOpen',
      'ad_placement': 'app_open',
      'opportunity_id': const Uuid().v7(),
      'trigger': trigger,
    };
    record('mf2_ad_opportunity', _appOpenOpportunity!);
    final reason = _appOpenBlockReason();
    if (reason != null) {
      cancelAppOpenOpportunity(reason);
      _syncFullScreenLoads();
      return;
    }
    _appOpenDeadline = Timer(appOpenWait, () {
      cancelAppOpenOpportunity(
        _appOpenBlockReason() ??
            (!_ready ? 'sdk_not_ready' : 'load_not_ready_within_window'),
      );
    });
    notifyListeners();
    _syncFullScreenLoads();
    unawaited(initialize());
  }

  void cancelAppOpenOpportunity(String reason, {bool notify = true}) {
    final fields = _appOpenOpportunity;
    if (fields == null) return;
    _appOpenOpportunity = null;
    _appOpenDeadline?.cancel();
    _appOpenValid = null;
    _appOpenOnShown = null;
    record('mf2_ad_decision', {
      ...fields,
      'result': 'skipped',
      'skip_reason': reason,
    });
    if (!_disposed && notify) notifyListeners();
  }

  void _syncAppOpen() {
    if (_disposed || !_appOpenEnabled) return;
    final unit = unitFor(AdFormat.appOpen);
    if (unit == null) return;
    _appOpen ??= AdLoader(
      format: AdFormat.appOpen,
      placement: 'app_open',
      unitId: unit,
      telemetry: record,
      create: (callbacks) => createAd(
        format: AdFormat.appOpen,
        unitId: unit,
        callbacks: callbacks,
      ),
    )..addListener(_onAppOpenChanged);
    _appOpen!.setEnabled(_ready && loadsAllowed && _onboardingCompleted);
    _maybeShowAppOpen();
  }

  void _onAppOpenChanged() {
    if (_disposed) return;
    if (_appOpen?.ad == null) {
      _appOpenLoadedAt = null;
      _appOpenExpiry?.cancel();
    } else if (_appOpenLoadedAt == null) {
      _appOpenLoadedAt = _clock();
      _appOpenExpiry?.cancel();
      _appOpenExpiry = Timer(appOpenMaxAge, () {
        _appOpen?.discard('expired');
        _syncAppOpen();
      });
    }
    _maybeShowAppOpen();
  }

  void _maybeShowAppOpen() {
    if (_appOpenOpportunity == null || !_ready || _fullScreenShowing) return;
    final reason = _appOpenBlockReason();
    if (reason != null) {
      cancelAppOpenOpportunity(reason);
      return;
    }
    if (_appOpenLoadedAt != null &&
        _clock().difference(_appOpenLoadedAt!) >= appOpenMaxAge) {
      _appOpen?.discard('expired');
      _syncAppOpen();
      return;
    }
    final ad = _appOpen?.takeAd();
    if (ad == null) return;
    final fields = {
      ..._appOpenOpportunity!,
      ..._appOpen!.context,
      'cache_age_ms': _clock().difference(_appOpenLoadedAt!).inMilliseconds,
    };
    final valid = _appOpenValid!;
    final onShown = _appOpenOnShown;
    _appOpenOpportunity = null;
    _appOpenDeadline?.cancel();
    _appOpenValid = null;
    _appOpenOnShown = null;
    _appOpenLoadedAt = null;
    _appOpenExpiry?.cancel();
    // Keep the loading cover until a real presentation/terminal callback.
    _appOpenPresenting = true;
    void releaseCover() {
      if (!_appOpenPresenting) return;
      _appOpenPresenting = false;
      if (!_disposed) notifyListeners();
    }

    // Synchronously reserve the same fullscreen lock as workout interstitials.
    final result = _presentFullScreen(
      ad,
      fields,
      isOpportunityValid: valid,
      onShown: (at) {
        releaseCover();
        onShown?.call(at);
      },
    );
    notifyListeners();
    unawaited(result.then((_) => releaseCover()));
  }

  @override
  void dispose() {
    cancelAppOpenOpportunity('disposed', notify: false);
    _disposed = true;
    _appOpenPresenting = false;
    _appOpenDeadline?.cancel();
    _appOpenExpiry?.cancel();
    _appOpen?.removeListener(_onAppOpenChanged);
    _appOpen?.dispose();
    _initializationRetry?.cancel();
    _expiry?.cancel();
    _interstitial?.removeListener(_onInterstitialChanged);
    _interstitial?.dispose();
    super.dispose();
  }
}
