import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:motionfit_squat/core/analytics/workout_analytics_session.dart';
import 'package:motionfit_squat/core/diagnostics/crash_reporting_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

abstract interface class AnalyticsSink {
  Future<void> logEvent(String name, Map<String, Object> parameters);

  Future<void> logScreenView(String screenName);
}

class AnalyticsService {
  AnalyticsService({
    CrashReportingService? crashReporting,
    AnalyticsSink? sink,
    TargetPlatform? platformOverride,
    String? appVersion,
    String? buildNumber,
    String Function()? sessionIdFactory,
  }) : _crashReporting = crashReporting,
       _sink = sink,
       _platformOverride = platformOverride,
       _sessionIdFactory = sessionIdFactory ?? const Uuid().v7 {
    if (appVersion != null) _appVersion = appVersion;
    if (buildNumber != null) _buildNumber = buildNumber;
  }

  String _appVersion = const String.fromEnvironment(
    'FLUTTER_BUILD_NAME',
    defaultValue: '1.0.0',
  );
  String _buildNumber = const String.fromEnvironment(
    'FLUTTER_BUILD_NUMBER',
    defaultValue: '1',
  );

  final List<_PendingAnalyticsEvent> _pending = [];
  final CrashReportingService? _crashReporting;
  AnalyticsSink? _sink;
  final TargetPlatform? _platformOverride;
  final String Function() _sessionIdFactory;
  Future<void>? _initialization;
  Future<void> _dispatchChain = Future.value();
  String _deviceCategory = 'unknown';
  String? _lastScreenName;
  DateTime? _lastScreenAt;
  WorkoutAnalyticsSession? _workoutSession;

  bool get _isSupported =>
      _sink != null ||
      (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS));

  String get _platform => switch (_platformOverride ?? defaultTargetPlatform) {
    TargetPlatform.iOS => 'ios',
    TargetPlatform.android => 'android',
    _ => 'unsupported',
  };

  void updateDeviceCategory(double shortestSide) {
    _deviceCategory = shortestSide >= 600 ? 'tablet' : 'phone';
  }

  Future<void> initialize() {
    if (_sink != null) return Future.value();
    if (!_isSupported) return Future.value();
    return _initialization ??= _initialize();
  }

  Future<void> _initialize() async {
    try {
      final app = Firebase.apps.isEmpty
          ? await Firebase.initializeApp()
          : Firebase.app();
      try {
        final packageInfo = await PackageInfo.fromPlatform();
        _appVersion = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      } on Object {
        // Compile-time values remain a safe fallback for analytics context.
      }
      final analytics = FirebaseAnalytics.instanceFor(app: app);
      await analytics.setAnalyticsCollectionEnabled(true);
      final sink = _FirebaseAnalyticsSink(analytics);
      _sink = sink;
      final pending = List<_PendingAnalyticsEvent>.of(_pending);
      _pending.clear();
      for (final event in pending) {
        await _dispatch(sink, event);
      }
    } on Object catch (error, stackTrace) {
      _initialization = null;
      await _crashReporting?.recordNonFatal(
        error,
        stackTrace,
        reason: 'analytics_initialization',
      );
      debugPrint('[Analytics] initialization failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  void screenView(String screenName) {
    final now = DateTime.now();
    if (_lastScreenName == screenName &&
        _lastScreenAt != null &&
        now.difference(_lastScreenAt!) < const Duration(seconds: 1)) {
      return;
    }
    _lastScreenName = screenName;
    _lastScreenAt = now;
    _enqueue(_PendingAnalyticsEvent.screenView(screenName));
  }

  void onboardingStarted({required int totalSteps}) =>
      _logV2('mf2_onboarding_started', {'total_steps': totalSteps});

  void onboardingStepViewed({
    required int stepIndex,
    required String stepName,
    required int totalSteps,
    required Duration elapsed,
  }) => _logV2('mf2_onboarding_step_viewed', {
    'step_index': stepIndex,
    'step_name': stepName,
    'total_steps': totalSteps,
    'elapsed_time_bucket': elapsedTimeBucket(elapsed),
  });

  void onboardingNextTapped({
    required int stepIndex,
    required String stepName,
    required int totalSteps,
    required Duration elapsed,
  }) => _logV2('mf2_onboarding_next_tapped', {
    'step_index': stepIndex,
    'step_name': stepName,
    'total_steps': totalSteps,
    'elapsed_time_bucket': elapsedTimeBucket(elapsed),
  });

  void onboardingBackTapped({
    required int stepIndex,
    required String stepName,
    required int totalSteps,
    required Duration elapsed,
  }) => _logV2('mf2_onboarding_back_tapped', {
    'step_index': stepIndex,
    'step_name': stepName,
    'total_steps': totalSteps,
    'elapsed_time_bucket': elapsedTimeBucket(elapsed),
  });

  void onboardingSkipped({
    required int stepIndex,
    required String stepName,
    required int totalSteps,
    required Duration elapsed,
  }) => _logV2('mf2_onboarding_skipped', {
    'step_index': stepIndex,
    'step_name': stepName,
    'total_steps': totalSteps,
    'elapsed_time_bucket': elapsedTimeBucket(elapsed),
    'exit_reason': 'skipped',
  });

  void onboardingComplete({
    required int totalSteps,
    required Duration elapsed,
  }) => _logV2('mf2_onboarding_completed', {
    'step_index': totalSteps - 1,
    'step_name': 'continuity',
    'total_steps': totalSteps,
    'elapsed_time_bucket': elapsedTimeBucket(elapsed),
  });

  void onboardingAbandoned({
    required int stepIndex,
    required int totalSteps,
    required Duration elapsed,
    required String exitReason,
  }) => _logV2('mf2_onboarding_abandoned', {
    'step_index': stepIndex,
    'step_name': onboardingStepName(stepIndex),
    'total_steps': totalSteps,
    'elapsed_time_bucket': elapsedTimeBucket(elapsed),
    'exit_reason': exitReason,
  });

  void workoutSetupViewed({
    required int plannedSets,
    required int plannedRepsPerSet,
  }) => _logV2('mf2_workout_setup_viewed', {
    'planned_sets_bucket': countBucket(plannedSets),
    'planned_reps_bucket': repsBucket(plannedRepsPerSet),
    'entry_point': 'home',
    'challenge_active': 0,
    'target_sets': plannedSets,
    'target_reps': plannedSets * plannedRepsPerSet,
  });

  void workoutStartTapped({
    required int plannedSets,
    required int plannedRepsPerSet,
    required String launchSource,
    bool isRecovery = false,
    bool challengeActive = false,
  }) {
    final entryPoint = isRecovery
        ? 'resume'
        : challengeActive || launchSource == 'challengeTab'
        ? 'challenge'
        : launchSource == 'workoutTab'
        ? 'home'
        : 'other';
    _workoutSession = WorkoutAnalyticsSession(
      sessionId: _sessionIdFactory(),
      entryPoint: entryPoint,
      challengeActive: challengeActive,
      targetSets: plannedSets,
      targetReps: plannedSets * plannedRepsPerSet,
    );
    _logWorkoutV2('mf2_workout_start_tapped', {
      'planned_sets_bucket': countBucket(plannedSets),
      'planned_reps_bucket': repsBucket(plannedRepsPerSet),
    });
  }

  void cameraPermissionResult({
    required String result,
    required bool requested,
  }) => _logWorkoutV2('mf2_camera_permission_result', {
    'result': result,
    'permission_requested': requested,
  });

  void cameraPermissionRequested() =>
      _logWorkoutV2('mf2_camera_permission_requested', null);

  void cameraInitializationStarted() =>
      _logWorkoutV2('mf2_camera_init_started', null, oncePerSession: true);

  void cameraInitializationCompleted() =>
      _logWorkoutV2('mf2_camera_init_completed', null, oncePerSession: true);

  void cameraInitializationFailed({
    required String failureReason,
    required String sessionState,
  }) => _logWorkoutV2('mf2_camera_init_failed', {
    'failure_stage': 'camera_initialization',
    'failure_reason': failureReason,
    'camera_state': 'failed',
    'permission_state': 'granted',
    'session_state': sessionState,
  }, oncePerSession: true);

  void workoutFailed({
    required String failureStage,
    required String failureReason,
    required String cameraState,
    required String permissionState,
    required String sessionState,
  }) => _logWorkoutV2('mf2_workout_failed', {
    'failure_stage': failureStage,
    'failure_reason': failureReason,
    'camera_state': cameraState,
    'permission_state': permissionState,
    'session_state': sessionState,
  }, terminal: true);

  void workoutScreenViewed() =>
      _logWorkoutV2('mf2_workout_screen_viewed', null, oncePerSession: true);

  // Countdown entry is not camera initialization; the actual Future is logged
  // by cameraInitializationStarted.
  void workoutInitializationStarted() {}

  void calibrationStarted() =>
      _logWorkoutV2('mf2_calibration_started', null, oncePerSession: true);

  void calibrationCompleted({required Duration elapsed}) => _logWorkoutV2(
    'mf2_calibration_completed',
    {'elapsed_time_bucket': elapsedTimeBucket(elapsed)},
    oncePerSession: true,
  );

  void calibrationFailed({required String failureReason}) => _logWorkoutV2(
    'mf2_calibration_failed',
    {'failure_reason': failureReason},
    oncePerSession: true,
  );

  void firstRepDetected({required Duration elapsed}) => _logWorkoutV2(
    'mf2_first_rep_detected',
    {'elapsed_time_bucket': elapsedTimeBucket(elapsed)},
    oncePerSession: true,
  );

  void workoutStarted({
    required int plannedSets,
    required int plannedRepsPerSet,
  }) => _logWorkoutV2('mf2_workout_started', <String, Object>{
    'planned_sets_bucket': countBucket(plannedSets),
    'planned_reps_bucket': repsBucket(plannedRepsPerSet),
    'target_reps_bucket': repsBucket(plannedSets * plannedRepsPerSet),
  }, oncePerSession: true);

  void workoutComplete({
    required int reps,
    required int sets,
    required int durationSeconds,
  }) {
    if (reps <= 0) return;
    _logWorkoutV2('mf2_workout_completed', <String, Object>{
      'reps_bucket': repsBucket(reps),
      'sets_bucket': countBucket(sets),
      'duration_bucket': durationBucket(Duration(seconds: durationSeconds)),
    }, terminal: true);
  }

  void secondWorkoutCompleted() => _logV2('mf2_second_workout_completed');

  void workoutSummaryViewed({required bool completed}) =>
      _logWorkoutV2('mf2_workout_summary_viewed', {'completed': completed});

  void repTimelineViewed({required String? workoutSessionId}) => _logV2(
    'mf2_rep_timeline_viewed',
    {'workout_session_id': ?workoutSessionId},
  );

  void repClipPlayed({
    required String? workoutSessionId,
    required int repNumber,
    required String issueType,
  }) => _logV2('mf2_rep_clip_played', {
    'workout_session_id': ?workoutSessionId,
    'rep_number': repNumber,
    'issue_type': issueType,
  });

  void workoutInterrupted({
    required int reps,
    required int sets,
    required int durationSeconds,
  }) => _logWorkoutV2('mf2_workout_interrupted', {
    'reps_bucket': repsBucket(reps),
    'sets_bucket': countBucket(sets),
    'duration_bucket': durationBucket(Duration(seconds: durationSeconds)),
  }, oncePerSession: true);

  void workoutCancelled({
    required String cancelStage,
    required String cancelReason,
    required Duration elapsed,
    required int detectedReps,
    required Duration trackingLoss,
  }) => _logWorkoutV2('mf2_workout_cancelled', {
    'cancel_stage': cancelStage,
    'cancel_reason': cancelReason,
    'elapsed_time_bucket': elapsedTimeBucket(elapsed),
    'detected_rep_bucket': repsBucket(detectedReps),
    'tracking_loss_bucket': trackingLossBucket(trackingLoss),
  }, terminal: true);

  void reminderEnabled({
    required int weekday,
    required int hour,
    required int minute,
    required String source,
  }) => _logV2('mf2_reminder_enabled', {
    'weekday': weekday,
    'time_bucket': timeOfDayBucket(hour),
    'source': source,
  });

  void reminderPromptShown({required int completedWorkoutCount}) => _logV2(
    'mf2_reminder_prompt_shown',
    {'completed_workout_count': completedWorkoutCount},
  );

  void reminderPromptAccepted({required int completedWorkoutCount}) => _logV2(
    'mf2_reminder_prompt_accepted',
    {'completed_workout_count': completedWorkoutCount},
  );

  void reminderPromptDeclined({required int completedWorkoutCount}) => _logV2(
    'mf2_reminder_prompt_declined',
    {'completed_workout_count': completedWorkoutCount},
  );

  // Permission result is the canonical signal; request attempts add no funnel
  // information and are intentionally not duplicated in v2.
  void reminderPermissionRequested({required String source}) {}

  void reminderPermissionResult({
    required String result,
    String source = 'unknown',
  }) {
    final parameters = <String, Object>{'result': result, 'source': source};
    _logV2('mf2_reminder_permission_result', parameters);
  }

  void reminderScheduled({required String source}) {}

  void reminderScheduleFailed({required String source}) {}

  void reminderDisabled({required String source}) {}

  void workoutDetectionSummary({
    required bool completed,
    required int trackingLostCount,
    required int trackingLostMilliseconds,
    required int calibrationMilliseconds,
    required int calibrationRetries,
    required int shallowAttemptCount,
    required double averageConfidence,
  }) => _logWorkoutV2('mf2_workout_detection_summary', {
    'completed': completed,
    'tracking_loss_bucket': trackingLossBucket(
      Duration(milliseconds: trackingLostMilliseconds),
    ),
    'tracking_loss_count_bucket': countBucket(trackingLostCount),
    'calibration_time_bucket': elapsedTimeBucket(
      Duration(milliseconds: calibrationMilliseconds),
    ),
    'calibration_retry_bucket': countBucket(calibrationRetries),
    'shallow_attempt_bucket': countBucket(shallowAttemptCount),
    'confidence_bucket': confidenceBucket(averageConfidence),
  });

  void recoveryResume({
    required int savedReps,
    required int savedDurationSeconds,
  }) => _logWorkoutV2('mf2_workout_resumed', {
    'saved_reps_bucket': repsBucket(savedReps),
    'saved_duration_bucket': durationBucket(
      Duration(seconds: savedDurationSeconds),
    ),
  });

  void reviewEligibilityMet({
    required int validWorkoutCount,
    required int distinctWorkoutDays,
    required String triggerSource,
    required int daysSinceInstall,
    required int? daysSinceLastRequest,
  }) => _logV2(
    'mf2_review_eligibility_met',
    _reviewParameters(
      validWorkoutCount: validWorkoutCount,
      distinctWorkoutDays: distinctWorkoutDays,
      triggerSource: triggerSource,
      daysSinceInstall: daysSinceInstall,
      daysSinceLastRequest: daysSinceLastRequest,
    ),
  );

  void reviewRequestScheduled({
    required int validWorkoutCount,
    required int distinctWorkoutDays,
    required String triggerSource,
    required int daysSinceInstall,
    required int? daysSinceLastRequest,
  }) => _logV2(
    'mf2_review_request_scheduled',
    _reviewParameters(
      validWorkoutCount: validWorkoutCount,
      distinctWorkoutDays: distinctWorkoutDays,
      triggerSource: triggerSource,
      daysSinceInstall: daysSinceInstall,
      daysSinceLastRequest: daysSinceLastRequest,
    ),
  );

  void reviewRequestSkipped({
    required int validWorkoutCount,
    required int distinctWorkoutDays,
    required String triggerSource,
    required String skipReason,
    required int daysSinceInstall,
    required int? daysSinceLastRequest,
  }) => _logV2('mf2_review_request_skipped', {
    ..._reviewParameters(
      validWorkoutCount: validWorkoutCount,
      distinctWorkoutDays: distinctWorkoutDays,
      triggerSource: triggerSource,
      daysSinceInstall: daysSinceInstall,
      daysSinceLastRequest: daysSinceLastRequest,
    ),
    'skip_reason': skipReason,
  });

  void reviewPromptRequested({
    required int validWorkoutCount,
    required int distinctWorkoutDays,
    required String triggerSource,
    required int daysSinceInstall,
    required int? daysSinceLastRequest,
  }) => _logV2(
    'mf2_review_requested',
    _reviewParameters(
      validWorkoutCount: validWorkoutCount,
      distinctWorkoutDays: distinctWorkoutDays,
      triggerSource: triggerSource,
      daysSinceInstall: daysSinceInstall,
      daysSinceLastRequest: daysSinceLastRequest,
    ),
  );

  void reviewRequestCompleted({
    required int validWorkoutCount,
    required int distinctWorkoutDays,
    required String triggerSource,
    required int daysSinceInstall,
    required int? daysSinceLastRequest,
  }) => _logV2(
    'mf2_review_request_completed',
    _reviewParameters(
      validWorkoutCount: validWorkoutCount,
      distinctWorkoutDays: distinctWorkoutDays,
      triggerSource: triggerSource,
      daysSinceInstall: daysSinceInstall,
      daysSinceLastRequest: daysSinceLastRequest,
    ),
  );

  void manualRateTapped({required String triggerSource}) =>
      _logV2('mf2_manual_rate_tapped', {'trigger_source': triggerSource});

  void storeReviewPageOpened({required String triggerSource}) =>
      _logV2('mf2_store_review_page_opened', {'trigger_source': triggerSource});

  void storeReviewPageFailed({
    required String triggerSource,
    required String failureReason,
  }) => _logV2('mf2_store_review_page_failed', {
    'trigger_source': triggerSource,
    'failure_reason': failureReason,
  });

  void challengeTabViewed({
    required bool hasActiveChallenge,
    required String activeChallengeType,
    required int daysSinceInstall,
    required bool hasWorkoutHistory,
  }) => _logV2('mf2_challenge_tab_viewed', {
    'has_active_challenge': hasActiveChallenge,
    'active_challenge_type': activeChallengeType,
    'days_since_install_bucket': daysBucket(daysSinceInstall),
    'has_workout_history': hasWorkoutHistory,
  });

  void challengeRecommendationViewed({
    required String recommendedType,
    required String recommendedLevel,
    required int referenceWorkoutReps,
  }) {
    final parameters = <String, Object>{
      'recommended_type': recommendedType,
      'recommended_level': recommendedLevel,
      'reference_workout_reps_bucket': repsBucket(referenceWorkoutReps),
    };
    _logV2('mf2_challenge_recommendation_viewed', parameters);
  }

  void challengeCardSelected({
    required String challengeType,
    required bool isRecommended,
  }) {
    final parameters = <String, Object>{
      'challenge_type': challengeType,
      'is_recommended': isRecommended,
    };
    _logV2('mf2_challenge_selected', parameters);
  }

  void challengeRecommendationDismissed({required String recommendedType}) =>
      _logV2('mf2_challenge_recommendation_dismissed', {
        'recommended_type': recommendedType,
      });

  void challengeStarted({required String challengeType}) =>
      _logV2('mf2_challenge_started', {'challenge_type': challengeType});

  void challengeWorkoutStarted({
    required String challengeType,
    required double currentProgress,
  }) => _logWorkoutV2('mf2_challenge_workout_started', {
    'challenge_type': challengeType,
    'launch_source': 'challenge_tab',
    'progress_bucket': progressBucket(currentProgress),
  });

  void challengeCompleted({required String challengeType}) =>
      _logV2('mf2_challenge_completed', {'challenge_type': challengeType});

  void challengeCancelled({required String challengeType}) =>
      _logV2('mf2_challenge_cancelled', {'challenge_type': challengeType});

  // Badge impressions are UI noise and are not retained in schema v2.
  void challengeTabBadgeViewed() {}

  void adRequested({
    required String format,
    required String placement,
    required int workoutCompletionCount,
    required bool onboardingCompleted,
  }) => _logV2(
    'mf2_ad_request_attempted',
    _adParameters(
      format: format,
      placement: placement,
      workoutCompletionCount: workoutCompletionCount,
      onboardingCompleted: onboardingCompleted,
    ),
  );

  void adLoaded({
    required String format,
    required String placement,
    required int workoutCompletionCount,
    required bool onboardingCompleted,
  }) {}

  void adShown({
    required String format,
    required String placement,
    required int workoutCompletionCount,
    required bool onboardingCompleted,
  }) {}

  void adDismissed({
    required String format,
    required String placement,
    required int workoutCompletionCount,
    required bool onboardingCompleted,
  }) {}

  void adFailed({
    required String format,
    required String placement,
    required String failureStage,
    required int workoutCompletionCount,
    required bool onboardingCompleted,
  }) {}

  void adSkippedByPolicy({
    required String format,
    required String placement,
    required String skipReason,
    required int workoutCompletionCount,
    required bool onboardingCompleted,
  }) => _logV2('mf2_ad_skipped_by_policy', {
    ..._adParameters(
      format: format,
      placement: placement,
      workoutCompletionCount: workoutCompletionCount,
      onboardingCompleted: onboardingCompleted,
    ),
    'skip_reason': skipReason,
  });

  // AdMob/Firebase ad_impression and ad_click remain the source of truth.
  void adClick({required String format, String placement = 'unknown'}) {}

  static Map<String, Object> _adParameters({
    required String format,
    required String placement,
    required int workoutCompletionCount,
    required bool onboardingCompleted,
  }) => {
    'ad_format': format,
    'ad_placement': placement,
    'workout_completion_count': workoutCompletionCount,
    'onboarding_completed': onboardingCompleted,
  };

  Map<String, Object> _reviewParameters({
    required int validWorkoutCount,
    required int distinctWorkoutDays,
    required String triggerSource,
    required int daysSinceInstall,
    required int? daysSinceLastRequest,
  }) => {
    'valid_workout_count_bucket': countBucket(validWorkoutCount),
    'distinct_workout_days_bucket': countBucket(distinctWorkoutDays),
    'trigger_source': triggerSource,
    'days_since_install_bucket': daysBucket(daysSinceInstall),
    'days_since_last_request_bucket': daysSinceLastRequest == null
        ? 'never'
        : daysBucket(daysSinceLastRequest),
  };

  static String onboardingStepName(int index) => switch (index) {
    0 => 'automatic_count',
    1 => 'realtime_coaching',
    2 => 'continuity',
    _ => 'unknown',
  };

  static String elapsedTimeBucket(Duration elapsed) {
    if (elapsed < const Duration(seconds: 3)) return 'under_3s';
    if (elapsed <= const Duration(seconds: 10)) return '3_10s';
    if (elapsed <= const Duration(seconds: 30)) return '11_30s';
    return 'over_30s';
  }

  static String repsBucket(int reps) {
    if (reps <= 0) return '0';
    if (reps <= 5) return '1_5';
    if (reps <= 10) return '6_10';
    if (reps <= 30) return '11_30';
    return '31_plus';
  }

  static String countBucket(int count) {
    if (count <= 0) return '0';
    if (count == 1) return '1';
    if (count <= 3) return '2_3';
    if (count <= 5) return '4_5';
    return '6_plus';
  }

  static String durationBucket(Duration duration) {
    if (duration < const Duration(minutes: 1)) return 'under_1m';
    if (duration < const Duration(minutes: 3)) return '1_3m';
    if (duration < const Duration(minutes: 10)) return '3_10m';
    return 'over_10m';
  }

  static String trackingLossBucket(Duration duration) {
    if (duration <= Duration.zero) return 'none';
    if (duration < const Duration(seconds: 3)) return 'low';
    if (duration < const Duration(seconds: 10)) return 'medium';
    return 'high';
  }

  static String confidenceBucket(double confidence) {
    if (confidence <= 0) return 'none';
    if (confidence < .5) return 'low';
    if (confidence < .8) return 'medium';
    return 'high';
  }

  static String progressBucket(double progress) {
    if (progress <= 0) return '0';
    if (progress < .25) return 'under_25';
    if (progress < .5) return '25_49';
    if (progress < .75) return '50_74';
    if (progress < 1) return '75_99';
    return 'complete';
  }

  static String daysBucket(int days) {
    if (days <= 0) return '0';
    if (days <= 3) return '1_3';
    if (days <= 7) return '4_7';
    if (days <= 30) return '8_30';
    return '31_plus';
  }

  static String timeOfDayBucket(int hour) {
    if (hour < 6) return 'overnight';
    if (hour < 12) return 'morning';
    if (hour < 18) return 'afternoon';
    return 'evening';
  }

  void _logV2(String name, [Map<String, Object>? parameters]) {
    if (!name.startsWith('mf2_')) {
      throw ArgumentError.value(name, 'name', 'v2 events must start with mf2_');
    }
    _enqueue(_PendingAnalyticsEvent.custom(name, parameters));
  }

  @visibleForTesting
  void logV2Event(String name, {Map<String, Object>? parameters}) =>
      _logV2(name, parameters);

  void _logWorkoutV2(
    String name,
    Map<String, Object>? parameters, {
    bool oncePerSession = false,
    bool terminal = false,
  }) {
    final session = _workoutSession;
    if (session == null) return;
    if (terminal) {
      if (!session.markTerminal(name)) return;
    } else if (oncePerSession && !session.markOnce(name)) {
      return;
    }
    _logV2(name, <String, Object>{...session.parameters, ...?parameters});
  }

  String? get currentWorkoutSessionId => _workoutSession?.sessionId;

  @visibleForTesting
  Future<void> flush() => _dispatchChain;

  void _enqueue(_PendingAnalyticsEvent event) {
    if (!_isSupported) return;
    final sink = _sink;
    if (sink == null) {
      _pending.add(event);
      unawaited(initialize());
      return;
    }
    _dispatchChain = _dispatchChain.then((_) => _dispatch(sink, event));
  }

  Future<void> _dispatch(
    AnalyticsSink sink,
    _PendingAnalyticsEvent event,
  ) async {
    try {
      if (event.screenName != null) {
        await sink.logScreenView(event.screenName!);
        return;
      }
      final parameters = _parametersWithContext(event.parameters);
      if (kDebugMode) {
        debugPrint(
          'AnalyticsV2: ${event.name} '
          'session=${parameters['workout_session_id'] ?? '-'} '
          'platform=${parameters['platform']} '
          'version=${parameters['app_version']}',
        );
      }
      await sink.logEvent(event.name!, parameters);
    } on Object catch (error, stackTrace) {
      await _crashReporting?.recordNonFatal(
        error,
        stackTrace,
        reason: 'analytics_event_${event.name ?? 'screen_view'}',
      );
      debugPrint('[Analytics] ${event.name ?? 'screen_view'} failed: $error');
    }
  }

  Map<String, Object> _parametersWithContext(Map<String, Object>? parameters) {
    final values = <String, Object>{};
    if (parameters != null) {
      for (final entry in parameters.entries) {
        values[entry.key] = entry.value is bool
            ? ((entry.value as bool) ? 1 : 0)
            : entry.value;
      }
    }
    values
      ..['analytics_schema'] = 2
      ..['platform'] = _platform
      ..['app_version'] = _appVersion
      ..['build_number'] = _buildNumber
      ..['device_category'] = _deviceCategory;
    return values;
  }
}

class _FirebaseAnalyticsSink implements AnalyticsSink {
  const _FirebaseAnalyticsSink(this._analytics);

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logEvent(String name, Map<String, Object> parameters) =>
      _analytics.logEvent(name: name, parameters: parameters);

  @override
  Future<void> logScreenView(String screenName) => _analytics.logScreenView(
    screenName: screenName,
    screenClass: 'MotionFit',
  );
}

class _PendingAnalyticsEvent {
  const _PendingAnalyticsEvent.custom(this.name, this.parameters)
    : screenName = null;

  const _PendingAnalyticsEvent.screenView(this.screenName)
    : name = null,
      parameters = null;

  final String? name;
  final Map<String, Object>? parameters;
  final String? screenName;
}
