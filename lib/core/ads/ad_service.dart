import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:motionfit_squat/core/ads/ad_unit_ids.dart';
import 'package:motionfit_squat/core/ads/ad_eligibility.dart';
import 'package:motionfit_squat/core/analytics/analytics_service.dart';
import 'package:motionfit_squat/core/diagnostics/crash_reporting_service.dart';

class AdService extends ChangeNotifier {
  AdService({
    required AnalyticsService analytics,
    required CrashReportingService crashReporting,
  }) : _analytics = analytics,
       _crashReporting = crashReporting;

  static const _interstitialMaxAge = Duration(minutes: 55);
  static const _interstitialLoadWait = Duration(seconds: 8);
  static const _retryDelays = <Duration>[
    Duration(seconds: 5),
    Duration(seconds: 15),
    Duration(seconds: 30),
    Duration(minutes: 1),
  ];

  bool _ready = false;
  bool _disposed = false;
  bool _fullScreenShowing = false;
  Future<bool>? _initialization;
  DateTime? _lastInterstitialShownAt;
  final AnalyticsService _analytics;
  final CrashReportingService _crashReporting;
  int _completedWorkoutCount = 0;
  bool _onboardingCompleted = false;

  InterstitialAd? _interstitialAd;
  DateTime? _interstitialLoadedAt;
  bool _interstitialLoading = false;
  Completer<bool>? _interstitialLoadCompleter;
  int _interstitialLoadFailures = 0;
  Timer? _interstitialRetryTimer;

  bool get ready => _ready;
  bool get fullScreenShowing => _fullScreenShowing;

  void updatePolicyContext({
    required bool onboardingCompleted,
    required int completedWorkoutCount,
  }) {
    _onboardingCompleted = onboardingCompleted;
    _completedWorkoutCount = completedWorkoutCount;
    if (_ready) _loadInterstitial();
  }

  Future<bool> initialize() {
    if (!MotionFitAdUnits.isSupported || _disposed) {
      return Future.value(false);
    }
    return _initialization ??= _initialize();
  }

  Future<bool> _initialize() async {
    unawaited(_crashReporting.setCustomKey('ad_state', 'initializing'));
    try {
      if (!await ConsentInformation.instance.canRequestAds()) return false;
      await MobileAds.instance.initialize();
      if (_disposed) return false;
      _ready = true;
      unawaited(_crashReporting.setCustomKey('ad_state', 'ready'));
      notifyListeners();
      _loadInterstitial();
      return true;
    } on Object catch (error, stackTrace) {
      _debug('initialization failed: $error');
      unawaited(_recordNonFatal(error, stackTrace, 'ad_initialization'));
      return false;
    } finally {
      if (!_ready) _initialization = null;
    }
  }

  Future<bool> showInterstitialIfAvailable({
    required DateTime? lastInterstitialShownAt,
    required int completedWorkoutCount,
    DateTime? now,
  }) async {
    _completedWorkoutCount = completedWorkoutCount;
    if (!AdEligibility.canShowInterstitial(
      completedWorkoutCount: completedWorkoutCount,
    )) {
      _analytics.adSkippedByPolicy(
        format: 'interstitial',
        placement: 'workout_complete',
        skipReason: 'before_first_workout',
        workoutCompletionCount: completedWorkoutCount,
        onboardingCompleted: _onboardingCompleted,
      );
      return false;
    }
    final current = now ?? DateTime.now();
    final latestShownAt = _latestDateTime(
      _lastInterstitialShownAt,
      lastInterstitialShownAt,
    );
    if (!AdEligibility.isInterstitialCooldownElapsed(
      lastShownAt: latestShownAt,
      now: current,
    )) {
      _analytics.adSkippedByPolicy(
        format: 'interstitial',
        placement: 'workout_complete',
        skipReason: 'cooldown_10_minutes',
        workoutCompletionCount: completedWorkoutCount,
        onboardingCompleted: _onboardingCompleted,
      );
      return false;
    }
    if (!_ready) await initialize();
    if (!_ready || _disposed || _fullScreenShowing) {
      return false;
    }
    var ad = _validInterstitialAd();
    if (ad == null) {
      final loaded = await _waitForInterstitial();
      if (!loaded || _disposed || _fullScreenShowing) return false;
      ad = _validInterstitialAd();
      if (ad == null) return false;
    }
    final loadedAd = ad;

    _interstitialAd = null;
    _interstitialLoadedAt = null;
    _fullScreenShowing = true;
    unawaited(_crashReporting.setCustomKey('ad_state', 'showing'));
    final completion = Completer<void>();
    var didShow = false;
    var finished = false;

    void finish() {
      if (finished) return;
      finished = true;
      _fullScreenShowing = false;
      unawaited(_crashReporting.setCustomKey('ad_state', 'dismissed'));
      unawaited(loadedAd.dispose());
      _loadInterstitial();
      if (!completion.isCompleted) completion.complete();
    }

    loadedAd.fullScreenContentCallback =
        FullScreenContentCallback<InterstitialAd>(
          onAdShowedFullScreenContent: (_) {
            didShow = true;
            _lastInterstitialShownAt = DateTime.now();
          },
          onAdImpression: (_) => _analytics.adShown(
            format: 'interstitial',
            placement: 'workout_complete',
            workoutCompletionCount: _completedWorkoutCount,
            onboardingCompleted: _onboardingCompleted,
          ),
          onAdClicked: (_) => _analytics.adClick(
            format: 'interstitial',
            placement: 'workout_complete',
          ),
          onAdDismissedFullScreenContent: (_) {
            _analytics.adDismissed(
              format: 'interstitial',
              placement: 'workout_complete',
              workoutCompletionCount: _completedWorkoutCount,
              onboardingCompleted: _onboardingCompleted,
            );
            finish();
          },
          onAdFailedToShowFullScreenContent: (_, error) {
            _debug('interstitial failed to show: $error');
            _analytics.adFailed(
              format: 'interstitial',
              placement: 'workout_complete',
              failureStage: 'show',
              workoutCompletionCount: _completedWorkoutCount,
              onboardingCompleted: _onboardingCompleted,
            );
            unawaited(
              _recordNonFatal(
                error,
                StackTrace.current,
                'interstitial_show_callback',
              ),
            );
            finish();
          },
        );

    try {
      await loadedAd.show();
    } on Object catch (error, stackTrace) {
      _debug('interstitial show threw: $error');
      _analytics.adFailed(
        format: 'interstitial',
        placement: 'workout_complete',
        failureStage: 'show_exception',
        workoutCompletionCount: _completedWorkoutCount,
        onboardingCompleted: _onboardingCompleted,
      );
      unawaited(_recordNonFatal(error, stackTrace, 'interstitial_show'));
      finish();
    }
    await completion.future;
    return didShow;
  }

  InterstitialAd? _validInterstitialAd() {
    final ad = _interstitialAd;
    final loadedAt = _interstitialLoadedAt;
    if (ad == null || loadedAt == null) return null;
    if (DateTime.now().difference(loadedAt) < _interstitialMaxAge) return ad;
    _interstitialAd = null;
    _interstitialLoadedAt = null;
    unawaited(ad.dispose());
    return null;
  }

  Future<bool> _waitForInterstitial() async {
    if (_validInterstitialAd() != null) return true;
    _loadInterstitial();
    final pending = _interstitialLoadCompleter;
    if (pending == null) return _validInterstitialAd() != null;
    return pending.future.timeout(
      _interstitialLoadWait,
      onTimeout: () => false,
    );
  }

  void _loadInterstitial() {
    final adUnitId = MotionFitAdUnits.interstitial;
    if (!_ready ||
        _disposed ||
        adUnitId == null ||
        _interstitialLoading ||
        _validInterstitialAd() != null) {
      return;
    }
    _interstitialLoading = true;
    _interstitialLoadCompleter = Completer<bool>();
    _analytics.adRequested(
      format: 'interstitial',
      placement: 'workout_complete',
      workoutCompletionCount: _completedWorkoutCount,
      onboardingCompleted: _onboardingCompleted,
    );
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          if (_disposed) {
            unawaited(ad.dispose());
            return;
          }
          _interstitialLoading = false;
          _interstitialLoadFailures = 0;
          _interstitialRetryTimer?.cancel();
          _interstitialAd = ad;
          _interstitialLoadedAt = DateTime.now();
          _completeInterstitialLoad(true);
          unawaited(_crashReporting.setCustomKey('ad_state', 'loaded'));
          _analytics.adLoaded(
            format: 'interstitial',
            placement: 'workout_complete',
            workoutCompletionCount: _completedWorkoutCount,
            onboardingCompleted: _onboardingCompleted,
          );
          _debug('interstitial loaded');
        },
        onAdFailedToLoad: (error) {
          _interstitialLoading = false;
          _interstitialAd = null;
          _interstitialLoadedAt = null;
          _completeInterstitialLoad(false);
          _analytics.adFailed(
            format: 'interstitial',
            placement: 'workout_complete',
            failureStage: 'load',
            workoutCompletionCount: _completedWorkoutCount,
            onboardingCompleted: _onboardingCompleted,
          );
          _debug('interstitial failed to load: $error');
          if (_interstitialLoadFailures == 0) {
            unawaited(
              _recordNonFatal(error, StackTrace.current, 'interstitial_load'),
            );
          }
          _scheduleInterstitialRetry();
        },
      ),
    );
  }

  void _completeInterstitialLoad(bool loaded) {
    final completer = _interstitialLoadCompleter;
    _interstitialLoadCompleter = null;
    if (completer != null && !completer.isCompleted) {
      completer.complete(loaded);
    }
  }

  void _scheduleInterstitialRetry() {
    if (_disposed || _interstitialRetryTimer?.isActive == true) return;
    final delay = _retryDelay(_interstitialLoadFailures++);
    _interstitialRetryTimer = Timer(delay, _loadInterstitial);
  }

  Duration _retryDelay(int failureCount) =>
      _retryDelays[failureCount.clamp(0, _retryDelays.length - 1).toInt()];

  DateTime? _latestDateTime(DateTime? first, DateTime? second) {
    if (first == null) return second;
    if (second == null) return first;
    return first.isAfter(second) ? first : second;
  }

  void _debug(String message) {
    if (kDebugMode) debugPrint('[MotionFitAds] $message');
  }

  Future<void> _recordNonFatal(
    Object error,
    StackTrace stackTrace,
    String reason,
  ) => _crashReporting.recordNonFatal(error, stackTrace, reason: reason);

  @override
  void dispose() {
    _disposed = true;
    unawaited(_crashReporting.setCustomKey('ad_state', 'disposed'));
    _interstitialRetryTimer?.cancel();
    _completeInterstitialLoad(false);
    final interstitialAd = _interstitialAd;
    _interstitialAd = null;
    if (interstitialAd != null) unawaited(interstitialAd.dispose());
    super.dispose();
  }
}
