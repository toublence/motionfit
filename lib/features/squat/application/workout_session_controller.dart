import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motionfit_squat/core/providers.dart';
import 'package:motionfit_squat/features/records/application/records_providers.dart';
import 'package:motionfit_squat/features/records/domain/workout_session_details.dart';
import 'package:motionfit_squat/features/settings/application/preferences_controller.dart';
import 'package:motionfit_squat/features/squat/application/workout_coach_messages.dart';
import 'package:motionfit_squat/features/squat/application/workout_session_state.dart';
import 'package:motionfit_squat/features/squat/data/native_pose_engine.dart';
import 'package:motionfit_squat/features/squat/domain/models/pose_frame.dart';
import 'package:motionfit_squat/features/squat/domain/models/rep_record.dart';
import 'package:motionfit_squat/features/squat/domain/models/squat_metrics.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_enums.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_journal.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_plan.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_session.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_set.dart';
import 'package:motionfit_squat/features/squat/domain/services/coach_engine.dart';
import 'package:motionfit_squat/features/squat/domain/services/form_analyzer.dart';
import 'package:motionfit_squat/features/squat/domain/services/pose_engine.dart';
import 'package:motionfit_squat/features/squat/domain/services/pose_feedback_classifier.dart';
import 'package:motionfit_squat/features/squat/domain/services/pose_landmark_smoother.dart';
import 'package:motionfit_squat/features/squat/domain/services/rep_detector.dart';
import 'package:motionfit_squat/features/squat/domain/services/workout_session_policy.dart';
import 'package:uuid/uuid.dart';

final poseEngineFactoryProvider = Provider<PoseEngine Function()>((ref) {
  return NativePoseEngine.new;
});

final coachVoiceEngineFactoryProvider = Provider<CoachVoiceEngine Function()>((
  ref,
) {
  return SystemTtsCoachEngine.new;
});

final workoutSessionControllerProvider =
    NotifierProvider<WorkoutSessionController, WorkoutSessionState>(
      WorkoutSessionController.new,
    );

class WorkoutSessionController extends Notifier<WorkoutSessionState> {
  final _uuid = const Uuid();
  final _activeStopwatch = Stopwatch();
  Duration _activeBase = Duration.zero;
  final _totalStopwatch = Stopwatch();
  Duration _totalBase = Duration.zero;
  final _localClock = Stopwatch()..start();
  PoseEngine? _poseEngine;
  SquatRepDetector? _repDetector;
  final FormAnalyzer _formAnalyzer = const SquatFormAnalyzer();
  final PoseFeedbackClassifier _poseFeedbackClassifier =
      const PoseFeedbackClassifier();
  final PoseLandmarkSmoother _overlaySmoother = PoseLandmarkSmoother();
  CoachQueue? _coachQueue;
  CoachPolicy _coachPolicy = CoachPolicy();
  WorkoutCoachMessages? _messages;
  StreamSubscription? _poseSubscription;
  StreamSubscription? _subtitleSubscription;
  Timer? _ticker;
  DateTime? _restStartedAt;
  Duration _restAccumulated = Duration.zero;
  Duration _setActiveStartedAt = Duration.zero;
  int? _lastPoseTimestampUs;
  int? _lastPoseReceivedLocalUs;
  int? _lastRenderablePoseReceivedLocalUs;
  Future<void> _eventChain = Future.value();
  Future<void> _journalChain = Future.value();
  bool _finishingSet = false;
  bool _startingNextSet = false;
  bool _disposed = false;
  int _repSequenceOffset = 0;
  int _spokenRepOffset = 0;
  bool _cumulativeChallenge = false;
  int? _sevenDayChallengeDay;
  final Map<int, RepMotionTrace> _pendingRepSaves = {};
  final List<int> _inferenceLatencies = [];
  final List<Map<String, Object?>> _coachDiagnostics = [];
  PoseModelQuality _activeModelQuality = PoseModelQuality.lite;
  int _targetInferenceFps = 30;
  bool _performanceTuning = false;
  bool _calibrationRequired = true;
  bool _pausedDuringCalibration = false;
  int? _calibrationWindowStartedLocalUs;
  int? _lastCalibrationPromptLocalUs;
  int _lastJournalCheckpointSecond = -1;
  Future<void>? _prewarmOperation;
  bool _prewarming = false;
  Completer<void>? _prewarmReady;
  int? _prewarmFirstFrameLocalUs;
  int _prewarmInferenceFrames = 0;
  int _prewarmConsecutivePoseFrames = 0;
  bool _prewarmSawPose = false;
  int _trackingLostCount = 0;
  int? _trackingLostStartedLocalUs;
  int _trackingLostDurationUs = 0;
  int _calibrationDurationMilliseconds = 0;
  int _calibrationRetryCount = 0;
  int _shallowAttemptCount = 0;
  double _confidenceTotal = 0;
  int _confidenceSampleCount = 0;
  bool _detectionSummaryLogged = false;
  bool _inferenceFailureReported = false;
  bool _calibrationCompletedLogged = false;
  bool _firstRepLogged = false;
  bool _workoutStartedLogged = false;
  bool _cameraRetrying = false;
  bool _finalizing = false;
  bool _finalized = false;
  int? _workoutTimelineOriginUs;
  bool _videoReviewRequested = false;
  bool _engineVideoCapabilityRequested = false;
  bool _videoRecordingActive = false;
  PoseVideoRecordingResult? _finalizedWorkoutVideo;

  static const _calibrationPromptInterval = Duration(seconds: 12);
  static const _overlayTrackingHoldUs = 1800000;
  static const _minimumPrewarmDurationUs = 750000;
  static const _minimumPrewarmInferenceFrames = 6;
  static const _minimumStablePrewarmPoseFrames = 3;

  @override
  WorkoutSessionState build() {
    ref.onDispose(_disposeResources);
    return WorkoutSessionState.idle();
  }

  Future<void> prewarm(WorkoutCoachMessages messages) async {
    if (state.status != WorkoutSessionStatus.idle || _poseEngine != null) {
      return;
    }
    final inFlight = _prewarmOperation;
    if (inFlight != null) {
      await inFlight;
      return;
    }
    _videoReviewRequested = ref
        .read(preferencesControllerProvider)
        .repVideoReviewEnabled;
    final operation = _prewarmRuntime(messages);
    _prewarmOperation = operation;
    try {
      await operation;
    } finally {
      if (identical(_prewarmOperation, operation)) {
        _prewarmOperation = null;
      }
    }
  }

  Future<void> _prewarmRuntime(WorkoutCoachMessages messages) async {
    _prewarming = true;
    _messages = messages;
    try {
      await _startEnginesAndWarmPreview(messages);
    } on Object catch (error, stackTrace) {
      unawaited(_recordNonFatal(error, stackTrace, 'camera_prewarm'));
      _prewarming = false;
      await _releaseRuntimeResources();
      state = WorkoutSessionState.idle();
      rethrow;
    }
  }

  Future<void> _startEnginesAndWarmPreview(
    WorkoutCoachMessages messages,
  ) async {
    final ready = Completer<void>();
    _prewarmReady = ready;
    _prewarmFirstFrameLocalUs = null;
    _prewarmInferenceFrames = 0;
    _prewarmConsecutivePoseFrames = 0;
    _prewarmSawPose = false;
    try {
      await _startEngines(messages);
      _enqueueCalibrationInstruction();
      try {
        await ready.future.timeout(const Duration(seconds: 4));
      } on TimeoutException {
        // The initialized engine remains attached and continues warming.
      }
    } finally {
      if (identical(_prewarmReady, ready)) _prewarmReady = null;
    }
  }

  Future<void> cancelPreparation() async {
    final inFlight = _prewarmOperation;
    if (inFlight != null) {
      try {
        await inFlight;
      } on Object {
        // Failed preparation has already released its native resources.
      }
    }
    if (state.status != WorkoutSessionStatus.idle || state.session != null) {
      return;
    }
    _prewarming = false;
    await _releaseRuntimeResources();
    state = WorkoutSessionState.idle();
  }

  Future<void> start(
    WorkoutPlan plan,
    WorkoutCoachMessages messages, {
    int maxRepsPerSet = WorkoutPlan.maxReps,
    int spokenRepOffset = 0,
    bool cumulativeChallenge = false,
    int? sevenDayChallengeDay,
  }) async {
    if (state.isWorkoutInProgress) return;
    final inFlight = _prewarmOperation;
    if (inFlight != null) {
      try {
        await inFlight;
      } on Object {
        // Start retries with a fresh runtime below.
      }
    }
    final wantsVideoReview = ref
        .read(preferencesControllerProvider)
        .repVideoReviewEnabled;
    var reusePreparedRuntime =
        _poseEngine != null && _repDetector != null && _coachQueue != null;
    if (reusePreparedRuntime &&
        _engineVideoCapabilityRequested != wantsVideoReview) {
      await _releaseRuntimeResources();
      reusePreparedRuntime = false;
    }
    if (!reusePreparedRuntime) await _releaseRuntimeResources();
    _prewarming = false;
    _resetTiming(preservePreparedRuntime: reusePreparedRuntime);
    _videoReviewRequested = wantsVideoReview;
    if (reusePreparedRuntime) {
      _repDetector!.prepareForWorkout();
      final snapshot = _repDetector!.snapshot;
      _calibrationRequired = snapshot.calibrationProgress < 1;
      _adoptPreparedCalibration(snapshot);
    }
    final idleState = WorkoutSessionState.idle();
    final previewState = reusePreparedRuntime ? state : idleState;
    final normalizedPlan = plan.normalized(maxRepsPerSet: maxRepsPerSet);
    final now = DateTime.now();
    final repository = ref.read(workoutRepositoryProvider);
    final recoverable = await repository.loadRecoverableSession();
    if (recoverable != null) {
      await repository.markInterrupted(recoverable.session.id, now);
    }
    final sessionId = _uuid.v7();
    final setId = _uuid.v7();
    final session = WorkoutSession(
      id: sessionId,
      startedAt: now,
      plannedSetCount: normalizedPlan.setCount,
      plannedRepsPerSet: normalizedPlan.targetRepsPerSet,
      plannedRestSeconds: normalizedPlan.restDurationSeconds,
      completedSetCount: 0,
      totalReps: 0,
      activeDurationSeconds: 0,
      restDurationSeconds: 0,
      totalDurationSeconds: 0,
      averageRepDurationMilliseconds: 0,
      completed: false,
      interrupted: false,
      createdAt: now,
      analyticsSessionId: ref
          .read(analyticsServiceProvider)
          .currentWorkoutSessionId,
    );
    final firstSet = WorkoutSet(
      id: setId,
      sessionId: sessionId,
      setIndex: 1,
      startedAt: now,
      targetReps: normalizedPlan.targetRepsPerSet,
      completedReps: 0,
      activeDurationSeconds: 0,
      restDurationAfterSeconds: 0,
    );
    state = idleState.copyWith(
      status: WorkoutSessionStatus.preparing,
      plan: normalizedPlan,
      session: session,
      currentSet: firstSet,
      currentSetIndex: 1,
      saveState: WorkoutSaveState.saving,
      previewTextureId: reusePreparedRuntime
          ? _poseEngine?.previewTextureId
          : null,
      trackingState: previewState.trackingState,
      calibrationProgress: _repDetector?.snapshot.calibrationProgress ?? 0,
      overlayLandmarks: previewState.overlayLandmarks,
      previewTransform: previewState.previewTransform,
      previewMirrored: previewState.previewMirrored,
      previewRotationDegrees: previewState.previewRotationDegrees,
      previewHandlesCropAndRotation: previewState.previewHandlesCropAndRotation,
      previewInputWidth: previewState.previewInputWidth,
      previewInputHeight: previewState.previewInputHeight,
      poseFeedbackLevel: previewState.poseFeedbackLevel,
      voiceAvailable: previewState.voiceAvailable,
    );
    _messages = messages;
    _repSequenceOffset = 0;
    _spokenRepOffset = spokenRepOffset;
    _cumulativeChallenge = cumulativeChallenge;
    _sevenDayChallengeDay = sevenDayChallengeDay;
    if (reusePreparedRuntime) {
      final preferences = ref.read(preferencesControllerProvider);
      _coachQueue?.setEnabled(
        previewState.voiceAvailable &&
            (_isChallengeWorkout || preferences.voiceCoachingEnabled),
      );
    }
    _totalStopwatch.start();
    _workoutTimelineOriginUs = _nowMonotonicUs();
    ref.read(analyticsServiceProvider)
      ..screenView('calibration')
      ..calibrationStarted();
    try {
      await repository.createSession(session, firstSet);
      ref
        ..invalidate(recoverableSessionProvider)
        ..invalidate(allSessionsProvider)
        ..invalidate(todaySessionsProvider);
      await _saveJournal(WorkoutSessionStatus.preparing);
      if (!reusePreparedRuntime) {
        await _startEnginesAndWarmPreview(messages);
      }
      await _startWorkoutVideoIfAvailable(session.id);
      final calibrationSnapshot = _repDetector!.snapshot;
      final calibrated = calibrationSnapshot.calibrationProgress >= 1;
      _adoptPreparedCalibration(calibrationSnapshot);
      _calibrationRequired = !calibrated;
      state = state.copyWith(
        status: calibrated
            ? WorkoutSessionStatus.active
            : WorkoutSessionStatus.calibrating,
        phase: calibrated ? SquatPhase.ready : SquatPhase.calibrating,
        previewTextureId: _poseEngine?.previewTextureId,
        saveState: WorkoutSaveState.saved,
      );
      if (calibrated) {
        _logCalibrationCompleted();
        _activeStopwatch.start();
        await _saveJournal(WorkoutSessionStatus.active);
        _enqueueCoach(
          CoachMessageType.set,
          _workoutStartMessage(),
          _cumulativeChallenge
              ? 'cumulative_challenge_start'
              : 'set_start_${state.currentSetIndex}',
        );
      } else {
        _beginCalibrationWindow();
        await _saveJournal(WorkoutSessionStatus.calibrating);
      }
      unawaited(_setDiagnosticState('workout_state', 'active'));
      unawaited(_diagnosticLog('workout_started'));
      _startTicker();
    } on PoseEngineException catch (error, stackTrace) {
      unawaited(_recordCameraFailure(error, stackTrace, 'workout_start'));
      state = state.copyWith(
        status: WorkoutSessionStatus.error,
        errorCode: error.code,
        saveState: WorkoutSaveState.saved,
      );
      await _disposeEngineOnly();
    } on Object catch (error, stackTrace) {
      unawaited(_recordCameraFailure(error, stackTrace, 'workout_start'));
      state = state.copyWith(
        status: WorkoutSessionStatus.error,
        errorCode: 'start_failed',
        saveState: WorkoutSaveState.failed,
      );
      await _disposeEngineOnly();
    }
  }

  Future<void> recover(
    WorkoutSessionDetails details,
    WorkoutCoachMessages messages,
  ) async {
    if (state.isWorkoutInProgress ||
        details.session.completed ||
        details.session.interrupted) {
      return;
    }
    final inFlight = _prewarmOperation;
    if (inFlight != null) {
      try {
        await inFlight;
      } on Object {
        // Recovery retries with a fresh runtime below.
      }
    }
    var reusePreparedRuntime =
        _poseEngine != null && _repDetector != null && _coachQueue != null;
    if (reusePreparedRuntime && _engineVideoCapabilityRequested) {
      await _releaseRuntimeResources();
      reusePreparedRuntime = false;
    }
    if (!reusePreparedRuntime) await _releaseRuntimeResources();
    _prewarming = false;
    _resetTiming(preservePreparedRuntime: reusePreparedRuntime);
    // A recovered workout cannot append safely to its previous finalized or
    // interrupted media file. Its persisted text analysis remains available.
    _videoReviewRequested = false;
    if (reusePreparedRuntime) {
      _repDetector!.prepareForWorkout();
      final snapshot = _repDetector!.snapshot;
      _calibrationRequired = snapshot.calibrationProgress < 1;
      _adoptPreparedCalibration(snapshot);
    }
    final idleState = WorkoutSessionState.idle();
    final previewState = reusePreparedRuntime ? state : idleState;
    final session = details.session;
    final repository = ref.read(workoutRepositoryProvider);
    final journal = await repository.loadWorkoutJournal(session.id);
    final plan = WorkoutPlan(
      id: 'recovery:${session.id}',
      setCount: session.plannedSetCount,
      targetRepsPerSet: session.plannedRepsPerSet,
      restDurationSeconds: session.plannedRestSeconds,
      createdAt: session.createdAt,
      updatedAt: DateTime.now(),
    );
    var currentSet = details.sets.isEmpty
        ? WorkoutSet(
            id: _uuid.v7(),
            sessionId: session.id,
            setIndex: 1,
            startedAt: DateTime.now(),
            targetReps: plan.targetRepsPerSet,
            completedReps: 0,
            activeDurationSeconds: 0,
            restDurationAfterSeconds: 0,
          )
        : details.sets.last;
    final restoringRest =
        journal?.status == WorkoutSessionStatus.resting &&
        journal?.currentSetId == currentSet.id &&
        currentSet.completedReps >= currentSet.targetReps;
    if (!restoringRest &&
        currentSet.completedReps >= currentSet.targetReps &&
        currentSet.setIndex < plan.setCount) {
      currentSet = WorkoutSet(
        id: _uuid.v7(),
        sessionId: session.id,
        setIndex: currentSet.setIndex + 1,
        startedAt: DateTime.now(),
        targetReps: plan.targetRepsPerSet,
        completedReps: 0,
        activeDurationSeconds: 0,
        restDurationAfterSeconds: 0,
      );
      await repository.saveSetAndSession(currentSet, session);
    } else if (details.sets.isEmpty) {
      await repository.saveSetAndSession(currentSet, session);
    }
    final recoveredSetReps = _recoveredSetReps(session, currentSet);
    if (recoveredSetReps > currentSet.completedReps) {
      currentSet = currentSet.copyWith(completedReps: recoveredSetReps);
      await repository.saveSetAndSession(currentSet, session);
    }
    final journalMatchesSet = journal?.currentSetId == currentSet.id;
    final storedActiveSeconds = journal == null
        ? session.activeDurationSeconds
        : journal.activeDurationSeconds > session.activeDurationSeconds
        ? journal.activeDurationSeconds
        : session.activeDurationSeconds;
    final storedRestSeconds = journal == null
        ? session.restDurationSeconds
        : journal.restDurationSeconds > session.restDurationSeconds
        ? journal.restDurationSeconds
        : session.restDurationSeconds;
    final storedTotalSeconds = journal == null
        ? session.totalDurationSeconds
        : journal.totalDurationSeconds > session.totalDurationSeconds
        ? journal.totalDurationSeconds
        : session.totalDurationSeconds;
    _activeBase = Duration(seconds: storedActiveSeconds);
    _restAccumulated = Duration(seconds: storedRestSeconds);
    var recoveredTotalSeconds = storedTotalSeconds;
    if (restoringRest && journal != null) {
      final restClockEnd = _earlierDate(
        DateTime.now(),
        journal.restEndsAt ?? DateTime.now(),
      );
      final uncheckpointedRest = restClockEnd.difference(journal.updatedAt);
      if (!uncheckpointedRest.isNegative) {
        recoveredTotalSeconds += uncheckpointedRest.inSeconds;
      }
    }
    _totalBase = Duration(seconds: recoveredTotalSeconds);
    _totalStopwatch.start();
    _workoutTimelineOriginUs =
        _nowMonotonicUs() -
        Duration(seconds: recoveredTotalSeconds).inMicroseconds;
    final currentSetActiveSeconds = journalMatchesSet
        ? journal!.currentSetActiveDurationSeconds
        : currentSet.activeDurationSeconds;
    final setStart = _activeBase - Duration(seconds: currentSetActiveSeconds);
    _setActiveStartedAt = setStart.isNegative ? Duration.zero : setStart;
    _restStartedAt = restoringRest ? journal?.restStartedAt : null;
    _repSequenceOffset = session.totalReps;
    _firstRepLogged = session.totalReps > 0;
    _workoutStartedLogged = session.totalReps > 0;
    _messages = messages;
    _cumulativeChallenge = false;
    _sevenDayChallengeDay = null;
    final analyses = details.reps
        .map(
          (rep) => FormAnalysisResult(
            repSequence: rep.sequenceNumber ?? rep.repIndex,
            metrics: const {},
            detectedIssues: rep.detectedIssues,
            primaryIssue:
                rep.primaryIssue ??
                (rep.detectedIssues.isEmpty ? null : rep.detectedIssues.first),
            depthScore: rep.depthScore,
            controlScore: rep.controlScore,
            balanceScore: rep.balanceScore,
            overallScore: rep.overallFormScore,
            coverage: rep.overallFormScore == null ? 0 : 1,
            cameraAngle: rep.cameraAngle,
            confidence: rep.confidence,
          ),
        )
        .toList(growable: false);
    state = idleState.copyWith(
      status: WorkoutSessionStatus.preparing,
      plan: plan,
      session: session,
      currentSet: currentSet,
      currentSetIndex: currentSet.setIndex,
      currentSetReps: currentSet.completedReps,
      totalReps: session.totalReps,
      formAnalyses: analyses,
      activeElapsed: _activeBase,
      restElapsed: _restAccumulated,
      totalElapsed: _totalElapsed,
      saveState: WorkoutSaveState.saved,
      previewTextureId: reusePreparedRuntime
          ? _poseEngine?.previewTextureId
          : null,
      trackingState: previewState.trackingState,
      calibrationProgress: _repDetector?.snapshot.calibrationProgress ?? 0,
      overlayLandmarks: previewState.overlayLandmarks,
      previewTransform: previewState.previewTransform,
      previewMirrored: previewState.previewMirrored,
      previewRotationDegrees: previewState.previewRotationDegrees,
      previewHandlesCropAndRotation: previewState.previewHandlesCropAndRotation,
      previewInputWidth: previewState.previewInputWidth,
      previewInputHeight: previewState.previewInputHeight,
      poseFeedbackLevel: previewState.poseFeedbackLevel,
      workoutStarted: session.totalReps > 0,
    );
    try {
      if (!reusePreparedRuntime) {
        await _startEnginesAndWarmPreview(messages);
      }
      if (restoringRest) {
        await _poseEngine?.pause();
        _repDetector?.pause(_nowMonotonicUs());
        state = state.copyWith(
          status: WorkoutSessionStatus.resting,
          previewTextureId: _poseEngine?.previewTextureId,
          restEndsAt: journal?.restEndsAt ?? DateTime.now(),
          phase: SquatPhase.paused,
        );
        await _saveJournal(WorkoutSessionStatus.resting);
      } else {
        final calibrationSnapshot = _repDetector!.snapshot;
        final calibrated = calibrationSnapshot.calibrationProgress >= 1;
        _adoptPreparedCalibration(calibrationSnapshot);
        _calibrationRequired = !calibrated;
        state = state.copyWith(
          status: calibrated
              ? WorkoutSessionStatus.active
              : WorkoutSessionStatus.calibrating,
          phase: calibrated ? SquatPhase.ready : SquatPhase.calibrating,
          previewTextureId: _poseEngine?.previewTextureId,
        );
        if (calibrated) {
          _logCalibrationCompleted();
          _activeStopwatch.start();
          await _saveJournal(WorkoutSessionStatus.active);
          _enqueueCoach(
            CoachMessageType.set,
            _messages!.setStart(state.currentSetIndex),
            'set_start_${state.currentSetIndex}',
          );
        } else {
          _beginCalibrationWindow();
          await _saveJournal(WorkoutSessionStatus.calibrating);
        }
      }
      _startTicker();
      ref
          .read(analyticsServiceProvider)
          .recoveryResume(
            savedReps: session.totalReps,
            savedDurationSeconds: recoveredTotalSeconds,
          );
    } on PoseEngineException catch (error, stackTrace) {
      unawaited(_recordCameraFailure(error, stackTrace, 'workout_recovery'));
      state = state.copyWith(
        status: WorkoutSessionStatus.error,
        errorCode: error.code,
      );
      await _disposeEngineOnly();
    } on Object catch (error, stackTrace) {
      unawaited(_recordCameraFailure(error, stackTrace, 'workout_recovery'));
      state = state.copyWith(
        status: WorkoutSessionStatus.error,
        errorCode: 'start_failed',
      );
      await _disposeEngineOnly();
    }
  }

  Future<void> _startEngines(WorkoutCoachMessages messages) async {
    ref.read(analyticsServiceProvider).cameraInitializationStarted();
    unawaited(_setDiagnosticState('camera_state', 'initializing'));
    unawaited(_diagnosticLog('camera_initialization_started'));
    final preferences = ref.read(preferencesControllerProvider);
    final voiceEngine = ref.read(coachVoiceEngineFactoryProvider)();
    _coachQueue = CoachQueue(voiceEngine, onDelivery: _recordCoachDelivery);
    _subtitleSubscription = _coachQueue!.subtitles.listen((subtitle) {
      if (_disposed) return;
      state = state.copyWith(
        subtitle: subtitle,
        clearSubtitle: subtitle == null,
      );
    });
    _repDetector = SquatRepDetector();
    _poseEngine = ref.read(poseEngineFactoryProvider)();
    _poseSubscription = _poseEngine!.frames.listen(
      _onPoseFrame,
      onError: _onPoseError,
    );
    final results = await Future.wait<Object?>([
      _poseEngine!.start(
        PoseEngineConfig(
          camera: preferences.selectedCamera,
          preferredQuality: _activeModelQuality,
          targetInferenceFps: _targetInferenceFps,
          enableVideoRecording: _videoReviewRequested,
        ),
      ),
      (() async {
        try {
          return await voiceEngine.configure(
            locale: messages.locale,
            rate: preferences.ttsRate,
          );
        } on Object catch (error, stackTrace) {
          unawaited(_recordNonFatal(error, stackTrace, 'tts_configuration'));
          return false;
        }
      })(),
    ]);
    _engineVideoCapabilityRequested = _videoReviewRequested;
    final voiceAvailable = results[1]! as bool;
    _coachQueue!.setEnabled(
      voiceAvailable &&
          (_isChallengeWorkout || preferences.voiceCoachingEnabled),
    );
    state = state.copyWith(
      voiceAvailable: voiceAvailable,
      previewTextureId: _poseEngine?.previewTextureId,
    );
    unawaited(_setDiagnosticState('camera_state', 'initialized'));
    unawaited(_diagnosticLog('camera_initialization_completed'));
    unawaited(_diagnosticLog('pose_engine_started'));
    ref.read(analyticsServiceProvider).cameraInitializationCompleted();
  }

  int _recoveredSetReps(WorkoutSession session, WorkoutSet currentSet) {
    final repsBeforeCurrentSet =
        (currentSet.setIndex - 1) * session.plannedRepsPerSet;
    return (session.totalReps - repsBeforeCurrentSet)
        .clamp(0, currentSet.targetReps)
        .toInt();
  }

  void _onPoseFrame(PoseFrame frame) {
    if (_repDetector == null) {
      return;
    }
    if ((_prewarming && state.status == WorkoutSessionStatus.idle) ||
        state.status == WorkoutSessionStatus.preparing) {
      _handlePrewarmFrame(frame);
      return;
    }
    if (state.status != WorkoutSessionStatus.calibrating &&
        state.status != WorkoutSessionStatus.active) {
      return;
    }
    _lastPoseTimestampUs = frame.timestampUs;
    final receivedLocalUs = _localClock.elapsedMicroseconds;
    _lastPoseReceivedLocalUs = receivedLocalUs;
    _observeInferenceLatency(frame.inferenceLatencyMilliseconds);
    final previewInputWidth = frame.inputWidth > 0
        ? frame.inputWidth
        : state.previewInputWidth;
    final previewInputHeight = frame.inputHeight > 0
        ? frame.inputHeight
        : state.previewInputHeight;
    final hasRenderablePose =
        frame.peopleCount > 0 && frame.landmarks.length >= 33;
    List<PoseLandmark> overlayLandmarks;
    if (hasRenderablePose) {
      _lastRenderablePoseReceivedLocalUs = receivedLocalUs;
      overlayLandmarks = _overlaySmoother.smooth(
        frame.landmarks,
        frame.timestampUs,
      );
    } else {
      final lastRenderableAt = _lastRenderablePoseReceivedLocalUs;
      final canHoldLastPose =
          lastRenderableAt != null &&
          receivedLocalUs - lastRenderableAt <= _overlayTrackingHoldUs &&
          state.overlayLandmarks.length >= 33;
      overlayLandmarks = canHoldLastPose
          ? state.overlayLandmarks
          : const <PoseLandmark>[];
      if (!canHoldLastPose) _resetOverlayTracking();
    }

    try {
      final events = _repDetector!.addFrame(frame);
      final snapshot = _repDetector!.snapshot;
      if (snapshot.trackingState == TrackingState.tracking) {
        _recordTrackingRecovered();
        final confidence = snapshot.lastMetrics?.confidence;
        if (confidence != null) {
          _confidenceTotal += confidence;
          _confidenceSampleCount++;
        }
      }
      state = state.copyWith(
        phase: snapshot.phase,
        trackingState: frame.trackingState,
        calibrationProgress: snapshot.calibrationProgress,
        overlayLandmarks: overlayLandmarks,
        previewTransform: frame.previewTransform,
        previewMirrored: frame.mirrored,
        previewRotationDegrees: frame.rotationDegrees,
        previewHandlesCropAndRotation: frame.previewHandlesCropAndRotation,
        previewInputWidth: previewInputWidth,
        previewInputHeight: previewInputHeight,
        poseFeedbackLevel: _poseFeedbackClassifier.classify(
          snapshot.lastMetrics,
          trackingState: frame.trackingState,
        ),
      );
      for (final event in events) {
        switch (event.type) {
          case RepEventType.calibrated:
            _calibrationRequired = false;
            _calibrationWindowStartedLocalUs = null;
            _lastCalibrationPromptLocalUs = null;
            _calibrationDurationMilliseconds +=
                (event.calibrationDurationUs ?? 0) ~/ 1000;
            _calibrationRetryCount += event.calibrationRetries ?? 0;
            state = state.copyWith(
              status: WorkoutSessionStatus.active,
              phase: SquatPhase.ready,
            );
            _logCalibrationCompleted();
            _activeStopwatch.start();
            _saveJournalSafely(WorkoutSessionStatus.active);
            _enqueueCoach(
              CoachMessageType.set,
              _workoutStartMessage(),
              _cumulativeChallenge
                  ? 'cumulative_challenge_start'
                  : 'set_start_${state.currentSetIndex}',
            );
          case RepEventType.completed:
            if (event.trace != null) _handleRepCompleted(event.trace!);
          case RepEventType.trackingLost:
            _recordTrackingLost(
              elapsedBeforeReportUs: event.trackingLostDurationUs ?? 0,
            );
            _enqueueCoach(
              CoachMessageType.tracking,
              _messages!.tracking(snapshot.trackingState, state.totalReps % 2),
              'tracking_${snapshot.trackingState.name}',
            );
          case RepEventType.shallowAttempt:
            _shallowAttemptCount++;
            final preferences = ref.read(preferencesControllerProvider);
            if (preferences.formVoiceEnabled || _isChallengeWorkout) {
              _enqueueCoach(
                CoachMessageType.form,
                _messages!.formIssue(
                  FormIssue.insufficientDepth,
                  _shallowAttemptCount,
                ),
                'shallow_attempt',
              );
            }
          case RepEventType.started:
            _logFirstRep();
          case RepEventType.bottom:
          case RepEventType.ready:
            break;
        }
      }
    } on Object {
      state = state.copyWith(
        trackingState: frame.trackingState,
        phase: SquatPhase.trackingLost,
        overlayLandmarks: overlayLandmarks,
        previewTransform: frame.previewTransform,
        previewMirrored: frame.mirrored,
        previewRotationDegrees: frame.rotationDegrees,
        previewHandlesCropAndRotation: frame.previewHandlesCropAndRotation,
        previewInputWidth: previewInputWidth,
        previewInputHeight: previewInputHeight,
        poseFeedbackLevel: PoseFeedbackLevel.unavailable,
      );
    }
  }

  void _handlePrewarmFrame(PoseFrame frame) {
    final receivedLocalUs = _localClock.elapsedMicroseconds;
    final previewInputWidth = frame.inputWidth > 0
        ? frame.inputWidth
        : state.previewInputWidth;
    final previewInputHeight = frame.inputHeight > 0
        ? frame.inputHeight
        : state.previewInputHeight;
    final hasRenderablePose =
        frame.peopleCount == 1 && frame.landmarks.length >= 33;
    if (frame.inferenceLatencyMilliseconds > 0) {
      _prewarmInferenceFrames++;
      _prewarmFirstFrameLocalUs ??= receivedLocalUs;
      _observeInferenceLatency(frame.inferenceLatencyMilliseconds);
    }
    if (hasRenderablePose) {
      _prewarmSawPose = true;
      _prewarmConsecutivePoseFrames++;
      _lastRenderablePoseReceivedLocalUs = receivedLocalUs;
    } else {
      _prewarmConsecutivePoseFrames = 0;
    }
    final overlayLandmarks = hasRenderablePose
        ? _overlaySmoother.smooth(frame.landmarks, frame.timestampUs)
        : state.overlayLandmarks;
    state = state.copyWith(
      trackingState: frame.trackingState,
      overlayLandmarks: overlayLandmarks,
      previewTransform: frame.previewTransform,
      previewMirrored: frame.mirrored,
      previewRotationDegrees: frame.rotationDegrees,
      previewHandlesCropAndRotation: frame.previewHandlesCropAndRotation,
      previewInputWidth: previewInputWidth,
      previewInputHeight: previewInputHeight,
      poseFeedbackLevel: _poseFeedbackClassifier.classify(
        _repDetector?.snapshot.lastMetrics,
        trackingState: frame.trackingState,
      ),
    );
    if (_repDetector!.snapshot.calibrationProgress >= 1) {
      _calibrationRequired = false;
    } else {
      try {
        final events = _repDetector!.addFrame(frame);
        if (events.any((event) => event.type == RepEventType.calibrated)) {
          _calibrationRequired = false;
        }
      } on Object {
        // A later stable frame can still complete preparation.
      }
    }
    final firstFrameAt = _prewarmFirstFrameLocalUs;
    final inferenceReady =
        _prewarmInferenceFrames >= _minimumPrewarmInferenceFrames;
    final poseReady =
        !_prewarmSawPose ||
        _prewarmConsecutivePoseFrames >= _minimumStablePrewarmPoseFrames;
    if (firstFrameAt != null &&
        previewInputWidth > 0 &&
        previewInputHeight > 0 &&
        inferenceReady &&
        poseReady &&
        receivedLocalUs - firstFrameAt >= _minimumPrewarmDurationUs) {
      final ready = _prewarmReady;
      if (ready != null && !ready.isCompleted) ready.complete();
    }
  }

  void _handleRepCompleted(RepMotionTrace trace) {
    if (_finishingSet ||
        state.status != WorkoutSessionStatus.active ||
        state.currentSetReps >= state.targetReps) {
      return;
    }
    _logFirstRep();
    final nextSetReps = state.currentSetReps + 1;
    final nextTotalReps = state.totalReps + 1;
    state = state.copyWith(
      currentSetReps: nextSetReps,
      totalReps: nextTotalReps,
      phase: SquatPhase.completed,
      saveState: WorkoutSaveState.saving,
    );
    final preferences = ref.read(preferencesControllerProvider);
    if (preferences.hapticsEnabled) {
      unawaited(HapticFeedback.selectionClick().catchError((Object _) {}));
    }
    if (preferences.repCountVoiceEnabled || _isChallengeWorkout) {
      _enqueueCoach(
        CoachMessageType.repCount,
        _messages!.repCount(_spokenRepOffset + nextSetReps),
        'rep_$nextSetReps',
      );
    }
    _pendingRepSaves[nextSetReps] = trace;
    _eventChain = _eventChain.then((_) async {
      if (state.saveState == WorkoutSaveState.failed) return;
      await _persistCompletedRep(trace, nextSetReps);
    });
  }

  Future<bool> _persistCompletedRep(
    RepMotionTrace trace,
    int expectedRepIndex,
  ) async {
    final currentSet = state.currentSet;
    final session = state.session;
    if (currentSet == null || session == null) return false;
    FormAnalysisResult analysis;
    try {
      analysis = _formAnalyzer.analyze(trace);
    } on Object {
      analysis = FormAnalysisResult(
        repSequence: trace.repSequence,
        metrics: const {},
        detectedIssues: const [],
        primaryIssue: null,
        depthScore: null,
        controlScore: null,
        balanceScore: null,
        overallScore: null,
        coverage: 0,
        cameraAngle: CameraAngle.uncertain,
        confidence: trace.detectionConfidence,
      );
    }
    final timelineOriginUs = _workoutTimelineOriginUs ?? trace.startedAtUs;
    int elapsedMilliseconds(int timestampUs) =>
        ((timestampUs - timelineOriginUs) ~/ 1000).clamp(0, 86400000);
    int mediaMilliseconds(int? videoElapsedUs, int timestampUs) =>
        videoElapsedUs == null
        ? elapsedMilliseconds(timestampUs)
        : (videoElapsedUs ~/ 1000).clamp(0, 86400000);
    final videoStartMilliseconds = mediaMilliseconds(
      trace.videoStartedAtUs,
      trace.startedAtUs,
    );
    final videoBottomMilliseconds = trace.bottomAtUs == null
        ? null
        : mediaMilliseconds(trace.videoBottomAtUs, trace.bottomAtUs!);
    final videoEndMilliseconds = mediaMilliseconds(
      trace.videoCompletedAtUs,
      trace.completedAtUs,
    );
    final startedAt = session.startedAt.add(
      Duration(milliseconds: videoStartMilliseconds),
    );
    final completedAt = session.startedAt.add(
      Duration(milliseconds: videoEndMilliseconds),
    );
    final bottomAt = trace.bottomAtUs == null
        ? null
        : session.startedAt.add(
            Duration(milliseconds: videoBottomMilliseconds!),
          );
    final repIndex = expectedRepIndex;
    final rep = RepRecord(
      id: '${session.id}:${_repSequenceOffset + trace.repSequence}',
      sessionId: session.id,
      setId: currentSet.id,
      repIndex: repIndex,
      startedAt: startedAt,
      bottomAt: bottomAt,
      completedAt: completedAt,
      durationMilliseconds: trace.durationMilliseconds,
      depthScore: analysis.depthScore,
      controlScore: analysis.controlScore,
      balanceScore: analysis.balanceScore,
      overallFormScore: analysis.overallScore,
      detectedIssues: analysis.detectedIssues,
      cameraAngle: analysis.cameraAngle,
      confidence: trace.detectionConfidence,
      sequenceNumber: _repSequenceOffset + trace.repSequence,
      videoStartMilliseconds: videoStartMilliseconds,
      videoBottomMilliseconds: videoBottomMilliseconds,
      videoEndMilliseconds: videoEndMilliseconds,
      primaryIssue: analysis.primaryIssue,
      depthQuality: _repQuality(analysis, FormMetricType.depth),
      upperBodyQuality: _repQuality(analysis, FormMetricType.torsoLean),
      kneeAlignmentQuality: _repQuality(analysis, FormMetricType.kneeAlignment),
    );
    final updatedSet = currentSet.copyWith(completedReps: repIndex);
    final analyses = [...state.formAnalyses, analysis];
    final averageDuration = _averageRepDuration(
      session.averageRepDurationMilliseconds,
      session.totalReps,
      trace.durationMilliseconds,
    );
    final updatedSession = session.copyWith(
      totalReps: _repSequenceOffset + trace.repSequence,
      activeDurationSeconds: _activeElapsed.inSeconds,
      restDurationSeconds: _restAccumulated.inSeconds,
      totalDurationSeconds: _totalElapsed.inSeconds,
      averageRepDurationMilliseconds: averageDuration,
    );
    try {
      await ref
          .read(workoutRepositoryProvider)
          .saveProgress(rep: rep, set: updatedSet, session: updatedSession);
      if (_disposed) return false;
      _pendingRepSaves.remove(expectedRepIndex);
      state = state.copyWith(
        currentSet: updatedSet,
        session: updatedSession,
        formAnalyses: analyses,
        saveState: _pendingRepSaves.isEmpty
            ? WorkoutSaveState.saved
            : WorkoutSaveState.saving,
      );
      await _saveJournal(WorkoutSessionStatus.active);
      final preferences = ref.read(preferencesControllerProvider);
      final setFinished = updatedSet.completedReps >= updatedSet.targetReps;
      final issueToCoach = (preferences.formVoiceEnabled || _isChallengeWorkout)
          ? _coachPolicy.selectIssue(analysis)
          : null;
      if (kDebugMode) {
        final issues = analysis.detectedIssues
            .map((issue) => issue.name)
            .join(',');
        debugPrint(
          '[MotionFitCoach] rep=${analysis.repSequence} '
          'angle=${analysis.cameraAngle.name} confidence=${analysis.confidence.toStringAsFixed(2)} '
          'issues=[$issues] cue=${issueToCoach?.name ?? 'none'} '
          'voice=${preferences.voiceCoachingEnabled}/${preferences.formVoiceEnabled} '
          'available=${state.voiceAvailable}',
        );
      }
      if (issueToCoach != null) {
        _enqueueCoach(
          CoachMessageType.form,
          _messages!.formIssue(issueToCoach, trace.repSequence % 2),
          'form_${issueToCoach.name}',
          repSequence: _repSequenceOffset + trace.repSequence,
        );
      } else if (!setFinished &&
          analysis.primaryIssue == null &&
          preferences.encouragementVoiceEnabled) {
        final remaining = updatedSet.targetReps - updatedSet.completedReps;
        if (remaining == 1 || remaining == 2) {
          _enqueueCoach(
            CoachMessageType.encouragement,
            _messages!.goalNear(remaining),
            'goal_near_$remaining',
          );
        } else if (trace.repSequence % 3 == 0) {
          _enqueueCoach(
            CoachMessageType.encouragement,
            _messages!.goodRep(trace.repSequence % 3),
            'good_${trace.repSequence % 3}',
          );
        }
      }
      if (setFinished) {
        await _completeCurrentSet();
      }
      return true;
    } on Object {
      if (!_disposed) {
        state = state.copyWith(saveState: WorkoutSaveState.failed);
      }
      return false;
    }
  }

  Future<void> _completeCurrentSet() async {
    if (_finishingSet) return;
    _finishingSet = true;
    try {
      _activeStopwatch.stop();
      _repDetector?.pause(_nowMonotonicUs());
      // Keep a single workout file across set rests. Pose frames are ignored
      // while resting, and the detector remains paused.
      if (!_videoRecordingActive) await _poseEngine?.pause();
      final now = DateTime.now();
      var session = state.session!;
      var set = state.currentSet!.copyWith(
        endedAt: now,
        activeDurationSeconds: (_activeElapsed - _setActiveStartedAt).inSeconds
            .clamp(0, 864000)
            .toInt(),
      );
      session = session.copyWith(
        completedSetCount: state.currentSetIndex,
        activeDurationSeconds: _activeElapsed.inSeconds,
        totalDurationSeconds: _totalElapsed.inSeconds,
      );
      await ref.read(workoutRepositoryProvider).saveSetAndSession(set, session);
      if (state.currentSetIndex >= state.totalSets) {
        await _finishCompleted(session, set);
      } else {
        _restStartedAt = now;
        final restEndsAt = now.add(
          Duration(seconds: state.plan!.restDurationSeconds),
        );
        state = state.copyWith(
          status: WorkoutSessionStatus.resting,
          session: session,
          currentSet: set,
          restEndsAt: restEndsAt,
          phase: SquatPhase.paused,
        );
        await _saveJournal(WorkoutSessionStatus.resting);
        _enqueueCoach(
          CoachMessageType.rest,
          _messages!.restStart(state.plan!.restDurationSeconds),
          'rest_start_${state.currentSetIndex}',
        );
      }
    } finally {
      _finishingSet = false;
    }
  }

  Future<void> _finishCompleted(WorkoutSession session, WorkoutSet set) async {
    final endedAt = DateTime.now();
    _totalStopwatch.stop();
    _ticker?.cancel();
    var completed = session.copyWith(
      endedAt: endedAt,
      completed: true,
      interrupted: false,
      activeDurationSeconds: _activeElapsed.inSeconds,
      restDurationSeconds: _restAccumulated.inSeconds,
      totalDurationSeconds: _totalElapsed.inSeconds,
    );
    completed = await _finalizeWorkoutVideo(completed);
    if (!WorkoutSessionPolicy.canSendWorkoutCompleted(completed)) {
      throw StateError(
        'A zero-rep or interrupted workout cannot be completed.',
      );
    }
    state = state.copyWith(saveState: WorkoutSaveState.saving);
    await ref.read(workoutRepositoryProvider).finishSession(completed, set);
    try {
      unawaited(
        ref
            .read(notificationServiceProvider)
            .cancelStreakRiskReminder()
            .catchError((Object _) {}),
      );
    } on Object {
      // Completion is persisted; the app-level refresh retries notification sync.
    }
    await _journalChain;
    await ref.read(workoutRepositoryProvider).clearWorkoutJournal(session.id);
    await _pausePoseEngineSafely();
    state = state.copyWith(
      status: WorkoutSessionStatus.completed,
      session: completed,
      currentSet: set,
      saveState: WorkoutSaveState.saved,
      activeElapsed: _activeElapsed,
      restElapsed: _restAccumulated,
      totalElapsed: _totalElapsed,
      clearRestEndsAt: true,
    );
    unawaited(_setDiagnosticState('workout_state', 'completed'));
    unawaited(_diagnosticLog('workout_completed'));
    ref
        .read(analyticsServiceProvider)
        .workoutComplete(
          reps: completed.totalReps,
          sets: completed.completedSetCount,
          durationSeconds: completed.totalDurationSeconds,
        );
    unawaited(_logCompletionMilestone());
    _logDetectionSummary(completed: true);
    ref
      ..invalidate(allSessionsProvider)
      ..invalidate(todaySessionsProvider);
    _enqueueCoach(
      CoachMessageType.completion,
      _messages!.workoutComplete(completed.totalReps),
      'workout_complete',
    );
  }

  Future<void> startNextSet({bool skipped = false}) async {
    if (state.status != WorkoutSessionStatus.resting || _startingNextSet) {
      return;
    }
    _startingNextSet = true;
    final restAccumulatedBeforeAttempt = _restAccumulated;
    try {
      state = state.copyWith(saveState: WorkoutSaveState.saving);
      final now = DateTime.now();
      final effectiveRestEnd = _earlierDate(now, state.restEndsAt ?? now);
      final restSegment = _restStartedAt == null
          ? Duration.zero
          : effectiveRestEnd.difference(_restStartedAt!);
      if (_restStartedAt != null) {
        _restAccumulated += restSegment.isNegative
            ? Duration.zero
            : restSegment;
      }
      final previousSet = state.currentSet!.copyWith(
        restDurationAfterSeconds: restSegment.inSeconds.clamp(0, 3600).toInt(),
      );
      final nextIndex = state.currentSetIndex + 1;
      final nextSet = WorkoutSet(
        id: _uuid.v7(),
        sessionId: state.session!.id,
        setIndex: nextIndex,
        startedAt: now,
        targetReps: state.plan!.targetRepsPerSet,
        completedReps: 0,
        activeDurationSeconds: 0,
        restDurationAfterSeconds: 0,
      );
      final session = state.session!.copyWith(
        restDurationSeconds: _restAccumulated.inSeconds,
        totalDurationSeconds: _totalElapsed.inSeconds,
      );
      await ref
          .read(workoutRepositoryProvider)
          .advanceSet(
            completedSet: previousSet,
            nextSet: nextSet,
            session: session,
          );
      _restStartedAt = null;
      final needsCalibration = _calibrationRequired;
      state = state.copyWith(
        status: needsCalibration
            ? WorkoutSessionStatus.calibrating
            : WorkoutSessionStatus.active,
        currentSet: nextSet,
        currentSetIndex: nextIndex,
        currentSetReps: 0,
        session: session,
        restElapsed: _restAccumulated,
        clearRestEndsAt: true,
        phase: needsCalibration
            ? SquatPhase.calibrating
            : SquatPhase.trackingLost,
        saveState: WorkoutSaveState.saved,
      );
      try {
        _repDetector?.resume(_nowMonotonicUs());
        if (_poseEngine?.isRunning != true) await _poseEngine?.resume();
      } on PoseEngineException catch (error) {
        state = state.copyWith(
          status: WorkoutSessionStatus.error,
          phase: SquatPhase.paused,
          errorCode: error.code,
          saveState: WorkoutSaveState.saved,
        );
        await _saveJournal(WorkoutSessionStatus.error);
        return;
      } on Object {
        state = state.copyWith(
          status: WorkoutSessionStatus.error,
          phase: SquatPhase.paused,
          errorCode: 'camera_initialization_failed',
          saveState: WorkoutSaveState.saved,
        );
        await _saveJournal(WorkoutSessionStatus.error);
        return;
      }
      if (needsCalibration) {
        _beginCalibrationWindow();
      } else {
        _activeStopwatch.start();
        _setActiveStartedAt = _activeElapsed;
      }
      if (!needsCalibration) {
        _enqueueCoach(
          CoachMessageType.set,
          _messages!.setStart(nextIndex),
          'set_start_$nextIndex',
        );
      }
      await _saveJournal(state.status);
    } on Object {
      if (state.status != WorkoutSessionStatus.error) {
        if (state.status == WorkoutSessionStatus.resting) {
          _restAccumulated = restAccumulatedBeforeAttempt;
        }
        state = state.copyWith(saveState: WorkoutSaveState.failed);
      }
    } finally {
      _startingNextSet = false;
    }
  }

  void addRestTime() {
    if (state.status != WorkoutSessionStatus.resting ||
        state.restEndsAt == null) {
      return;
    }
    state = state.copyWith(
      restEndsAt: state.restEndsAt!.add(const Duration(seconds: 15)),
    );
    _saveJournalSafely(WorkoutSessionStatus.resting);
  }

  Future<void> pause({String? reason}) async {
    if (state.status != WorkoutSessionStatus.active &&
        state.status != WorkoutSessionStatus.calibrating) {
      return;
    }
    _pausedDuringCalibration = state.status == WorkoutSessionStatus.calibrating;
    if (_pausedDuringCalibration) {
      _captureUnfinishedCalibration();
      _repDetector?.reset();
    }
    _recordTrackingRecovered();
    _calibrationWindowStartedLocalUs = null;
    _lastCalibrationPromptLocalUs = null;
    _activeStopwatch.stop();
    _repDetector?.pause(_nowMonotonicUs());
    try {
      await _cancelWorkoutVideo(disableForSession: true);
      await _poseEngine?.pause();
    } on PoseEngineException catch (error, stackTrace) {
      unawaited(_recordCameraFailure(error, stackTrace, 'camera_pause'));
      state = state.copyWith(
        status: WorkoutSessionStatus.error,
        phase: SquatPhase.paused,
        errorCode: error.code,
      );
      await _saveJournal(WorkoutSessionStatus.error);
      return;
    } on Object catch (error, stackTrace) {
      unawaited(_recordCameraFailure(error, stackTrace, 'camera_pause'));
      state = state.copyWith(
        status: WorkoutSessionStatus.error,
        phase: SquatPhase.paused,
        errorCode: 'camera_pause_failed',
      );
      await _saveJournal(WorkoutSessionStatus.error);
      return;
    }
    state = state.copyWith(
      status: WorkoutSessionStatus.paused,
      phase: SquatPhase.paused,
      overlayLandmarks: const [],
      pauseReason: reason,
    );
    _resetOverlayTracking();
    await _checkpointProgress(WorkoutSessionStatus.paused);
  }

  Future<void> resume() async {
    if (state.status != WorkoutSessionStatus.paused) return;
    _resetOverlayTracking();
    try {
      _repDetector?.resume(_nowMonotonicUs());
      await _poseEngine?.resume();
    } on PoseEngineException catch (error, stackTrace) {
      unawaited(_recordCameraFailure(error, stackTrace, 'camera_resume'));
      state = state.copyWith(
        status: WorkoutSessionStatus.error,
        phase: SquatPhase.paused,
        errorCode: error.code,
      );
      await _saveJournal(WorkoutSessionStatus.error);
      return;
    } on Object catch (error, stackTrace) {
      unawaited(_recordCameraFailure(error, stackTrace, 'camera_resume'));
      state = state.copyWith(
        status: WorkoutSessionStatus.error,
        phase: SquatPhase.paused,
        errorCode: 'camera_initialization_failed',
      );
      await _saveJournal(WorkoutSessionStatus.error);
      return;
    }
    final resumesCalibration = _pausedDuringCalibration || _calibrationRequired;
    if (resumesCalibration) {
      _beginCalibrationWindow();
    } else {
      _activeStopwatch.start();
    }
    state = state.copyWith(
      status: resumesCalibration
          ? WorkoutSessionStatus.calibrating
          : WorkoutSessionStatus.active,
      phase: resumesCalibration
          ? SquatPhase.calibrating
          : SquatPhase.trackingLost,
      clearPauseReason: true,
    );
    _pausedDuringCalibration = false;
    await _saveJournal(state.status);
  }

  Future<void> retryCamera() async {
    final messages = _messages;
    if (state.status != WorkoutSessionStatus.error ||
        messages == null ||
        _cameraRetrying) {
      return;
    }
    _cameraRetrying = true;

    try {
      _ticker?.cancel();
      await _disposeEngineOnly();
      _calibrationRequired = true;
      _pausedDuringCalibration = false;
      state = state.copyWith(
        status: WorkoutSessionStatus.preparing,
        phase: SquatPhase.calibrating,
        calibrationProgress: 0,
        overlayLandmarks: const [],
        clearPreviewTextureId: true,
        clearError: true,
      );
      await _startEngines(messages);
      state = state.copyWith(
        status: WorkoutSessionStatus.calibrating,
        previewTextureId: _poseEngine?.previewTextureId,
        clearError: true,
      );
      _beginCalibrationWindow();
      _startTicker();
      await _saveJournal(WorkoutSessionStatus.calibrating);
    } on PoseEngineException catch (error, stackTrace) {
      unawaited(_recordCameraFailure(error, stackTrace, 'camera_retry'));
      state = state.copyWith(
        status: WorkoutSessionStatus.error,
        errorCode: error.code,
        clearPreviewTextureId: true,
      );
      _captureUnfinishedCalibration();
      await _disposeEngineOnly();
    } on Object catch (error, stackTrace) {
      unawaited(_recordCameraFailure(error, stackTrace, 'camera_retry'));
      state = state.copyWith(
        status: WorkoutSessionStatus.error,
        errorCode: 'camera_initialization_failed',
        clearPreviewTextureId: true,
      );
      _captureUnfinishedCalibration();
      await _disposeEngineOnly();
    } finally {
      _cameraRetrying = false;
    }
  }

  Future<bool> finishContinuousWorkout() async {
    if ((!state.isWorkoutInProgress &&
            state.status != WorkoutSessionStatus.error) ||
        state.session == null ||
        state.currentSet == null) {
      return false;
    }
    await _eventChain;
    if (_pendingRepSaves.isNotEmpty) {
      state = state.copyWith(saveState: WorkoutSaveState.failed);
      return false;
    }
    if (state.totalReps == 0) {
      return discardInvalidSession();
    }
    final now = DateTime.now();
    _activeStopwatch.stop();
    var session = state.session!.copyWith(
      completedSetCount: 0,
      activeDurationSeconds: _activeElapsed.inSeconds,
      restDurationSeconds: _restAccumulated.inSeconds,
      totalDurationSeconds: _totalElapsed.inSeconds,
    );
    session = await _finalizeWorkoutVideo(session);
    final set = state.currentSet!.copyWith(
      endedAt: now,
      completedReps: state.currentSetReps,
      activeDurationSeconds: (_activeElapsed - _setActiveStartedAt).inSeconds
          .clamp(0, 864000)
          .toInt(),
    );
    try {
      await _finishCompleted(session, set);
      return state.status == WorkoutSessionStatus.completed;
    } on Object {
      if (!_disposed) {
        state = state.copyWith(saveState: WorkoutSaveState.failed);
      }
      return false;
    }
  }

  Future<void> endInterrupted() async {
    if ((!state.isWorkoutInProgress &&
            state.status != WorkoutSessionStatus.error) ||
        state.session == null ||
        state.currentSet == null) {
      return;
    }
    if (!state.isValidWorkout) {
      await discardInvalidSession();
      return;
    }
    await _eventChain;
    if (state.status == WorkoutSessionStatus.completed ||
        state.status == WorkoutSessionStatus.interrupted) {
      return;
    }
    if (_pendingRepSaves.isNotEmpty) {
      state = state.copyWith(saveState: WorkoutSaveState.failed);
      return;
    }
    final previousStatus = state.status;
    final endedAt = DateTime.now();
    _activeStopwatch.stop();
    _totalStopwatch.stop();
    _ticker?.cancel();
    if (_restStartedAt != null) {
      final effectiveRestEnd = _earlierDate(
        endedAt,
        state.restEndsAt ?? endedAt,
      );
      final segment = effectiveRestEnd.difference(_restStartedAt!);
      if (!segment.isNegative) _restAccumulated += segment;
      _restStartedAt = null;
    }
    final session = state.session!.copyWith(
      endedAt: endedAt,
      completed: false,
      interrupted: true,
      activeDurationSeconds: _activeElapsed.inSeconds,
      restDurationSeconds: _restAccumulated.inSeconds,
      totalDurationSeconds: _totalElapsed.inSeconds,
    );
    final set = previousStatus == WorkoutSessionStatus.resting
        ? state.currentSet!.copyWith(
            restDurationAfterSeconds:
                (_restAccumulated.inSeconds -
                        state.session!.restDurationSeconds)
                    .clamp(0, 3600)
                    .toInt(),
          )
        : state.currentSet!.copyWith(
            endedAt: endedAt,
            completedReps: state.currentSetReps,
            activeDurationSeconds: (_activeElapsed - _setActiveStartedAt)
                .inSeconds
                .clamp(0, 864000)
                .toInt(),
          );
    state = state.copyWith(saveState: WorkoutSaveState.saving);
    try {
      await ref.read(workoutRepositoryProvider).finishSession(session, set);
      await _journalChain;
      await ref.read(workoutRepositoryProvider).clearWorkoutJournal(session.id);
      _captureUnfinishedCalibration();
      await _disposeEngineOnly();
      state = state.copyWith(
        status: WorkoutSessionStatus.interrupted,
        session: session,
        currentSet: set,
        saveState: WorkoutSaveState.saved,
        activeElapsed: _activeElapsed,
        restElapsed: _restAccumulated,
        totalElapsed: _totalElapsed,
        clearRestEndsAt: true,
      );
      ref
          .read(analyticsServiceProvider)
          .workoutCancelled(
            cancelStage: _cancelStage(previousStatus, session.totalReps),
            cancelReason: _cancelReason(previousStatus, state.errorCode),
            elapsed: _totalElapsed,
            detectedReps: session.totalReps,
            trackingLoss: Duration(microseconds: _trackingLostDurationUs),
          );
      _logDetectionSummary(completed: false);
      ref
        ..invalidate(allSessionsProvider)
        ..invalidate(todaySessionsProvider);
    } on Object {
      state = state.copyWith(saveState: WorkoutSaveState.failed);
    }
  }

  Future<bool> saveForLater() async {
    if ((!state.isWorkoutInProgress &&
            state.status != WorkoutSessionStatus.error) ||
        state.session == null ||
        state.currentSet == null) {
      return false;
    }
    if (!state.isValidWorkout) return discardInvalidSession();
    final detectedReps = state.totalReps;
    final completedSets = state.session?.completedSetCount ?? 0;
    final elapsed = _totalElapsed;
    await _eventChain;
    if (_pendingRepSaves.isNotEmpty) {
      state = state.copyWith(saveState: WorkoutSaveState.failed);
      return false;
    }

    final checkpointStatus = state.status == WorkoutSessionStatus.resting
        ? WorkoutSessionStatus.resting
        : WorkoutSessionStatus.paused;
    _activeStopwatch.stop();
    _totalStopwatch.stop();
    _ticker?.cancel();
    _ticker = null;
    _repDetector?.pause(_nowMonotonicUs());
    await _cancelWorkoutVideo(disableForSession: true);
    await _pausePoseEngineSafely();
    await _checkpointProgress(checkpointStatus);
    if (state.saveState == WorkoutSaveState.failed) return false;

    await _releaseRuntimeResources();
    state = WorkoutSessionState.idle();
    ref
        .read(analyticsServiceProvider)
        .workoutInterrupted(
          reps: detectedReps,
          sets: completedSets,
          durationSeconds: elapsed.inSeconds,
        );
    ref
      ..invalidate(recoverableSessionProvider)
      ..invalidate(allSessionsProvider)
      ..invalidate(todaySessionsProvider);
    return true;
  }

  Future<bool> discardInvalidSession() async {
    if (_finalizing || _finalized || state.isValidWorkout) return false;
    _finalizing = true;
    final previousStatus = state.status;
    final errorCode = state.errorCode;
    final elapsed = _totalElapsed;
    final sessionId = state.session?.id;
    try {
      _activeStopwatch.stop();
      _totalStopwatch.stop();
      _ticker?.cancel();
      _ticker = null;
      _captureUnfinishedCalibration();
      await _releaseRuntimeResources();
      if (sessionId != null) {
        await ref.read(workoutRepositoryProvider).discardSession(sessionId);
      }
      final analytics = ref.read(analyticsServiceProvider);
      if (errorCode != null) {
        if (_failureStage(previousStatus, errorCode) == 'calibration') {
          analytics.calibrationFailed(failureReason: _failureReason(errorCode));
        }
        analytics.workoutFailed(
          failureStage: _failureStage(previousStatus, errorCode),
          failureReason: _failureReason(errorCode),
          cameraState: 'failed',
          permissionState: 'granted',
          sessionState: previousStatus.name,
        );
      } else {
        analytics.workoutCancelled(
          cancelStage: _cancelStage(previousStatus, 0),
          cancelReason: 'user_exit',
          elapsed: elapsed,
          detectedReps: 0,
          trackingLoss: Duration(microseconds: _trackingLostDurationUs),
        );
      }
      state = WorkoutSessionState.idle();
      _finalized = true;
      ref
        ..invalidate(recoverableSessionProvider)
        ..invalidate(allSessionsProvider)
        ..invalidate(todaySessionsProvider);
      return true;
    } on Object {
      if (!_disposed) {
        state = state.copyWith(saveState: WorkoutSaveState.failed);
      }
      return false;
    } finally {
      _finalizing = false;
    }
  }

  Future<void> switchCamera() async {
    final preferences = ref.read(preferencesControllerProvider);
    final next = preferences.selectedCamera == CameraSelection.front
        ? CameraSelection.back
        : CameraSelection.front;
    try {
      await pause();
      if (state.status != WorkoutSessionStatus.paused) return;
      await ref.read(preferencesControllerProvider.notifier).setCamera(next);
      await _poseEngine?.switchCamera(next);
      _resetOverlayTracking();
      _repDetector?.reset();
      _calibrationRequired = true;
      _pausedDuringCalibration = false;
      _repDetector?.resume(_nowMonotonicUs());
      await _poseEngine?.resume();
      _beginCalibrationWindow();
      state = state.copyWith(
        status: WorkoutSessionStatus.calibrating,
        phase: SquatPhase.calibrating,
        calibrationProgress: 0,
        clearPauseReason: true,
        clearError: true,
      );
      await _saveJournal(WorkoutSessionStatus.calibrating);
    } on PoseEngineException catch (error) {
      await _restoreCameraPreference(preferences.selectedCamera);
      state = state.copyWith(
        status: WorkoutSessionStatus.error,
        errorCode: error.code,
      );
    } on Object {
      await _restoreCameraPreference(preferences.selectedCamera);
      state = state.copyWith(
        status: WorkoutSessionStatus.error,
        errorCode: 'camera_switch_failed',
      );
    }
  }

  Future<void> _restoreCameraPreference(CameraSelection camera) async {
    try {
      await ref.read(preferencesControllerProvider.notifier).setCamera(camera);
    } on Object {
      // The camera error remains primary; settings can be corrected later.
    }
  }

  void toggleSkeleton() =>
      state = state.copyWith(skeletonVisible: !state.skeletonVisible);

  void enableCoachDiagnostics() {
    if (kDebugMode) _coachQueue?.onDelivery = _recordCoachDelivery;
  }

  Future<void> retrySave() async {
    if (state.session == null || state.currentSet == null) return;
    state = state.copyWith(saveState: WorkoutSaveState.saving);
    if (_pendingRepSaves.isNotEmpty) {
      final pending = _pendingRepSaves.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      _eventChain = Future.value();
      for (final entry in pending) {
        final saved = await _persistCompletedRep(entry.value, entry.key);
        if (!saved) break;
      }
      return;
    }
    if (state.status == WorkoutSessionStatus.active &&
        state.currentSet!.completedReps >= state.currentSet!.targetReps) {
      try {
        await _completeCurrentSet();
      } on Object {
        state = state.copyWith(saveState: WorkoutSaveState.failed);
      }
      return;
    }
    await _checkpointProgress(state.status);
  }

  Future<void> clearCompletedSession() async {
    if (state.isWorkoutInProgress) return;
    await _releaseRuntimeResources();
    _activeStopwatch.reset();
    _activeBase = Duration.zero;
    _totalStopwatch.reset();
    _totalBase = Duration.zero;
    _restAccumulated = Duration.zero;
    _coachPolicy = CoachPolicy();
    _pendingRepSaves.clear();
    _coachDiagnostics.clear();
    state = WorkoutSessionState.idle();
  }

  void _resetTiming({bool preservePreparedRuntime = false}) {
    _activeStopwatch
      ..stop()
      ..reset();
    _totalStopwatch
      ..stop()
      ..reset();
    _activeBase = Duration.zero;
    _totalBase = Duration.zero;
    _restAccumulated = Duration.zero;
    _restStartedAt = null;
    _setActiveStartedAt = Duration.zero;
    if (!preservePreparedRuntime) {
      _lastPoseTimestampUs = null;
      _lastPoseReceivedLocalUs = null;
      _lastRenderablePoseReceivedLocalUs = null;
    }
    _eventChain = Future.value();
    _journalChain = Future.value();
    _coachPolicy = CoachPolicy();
    _finishingSet = false;
    _startingNextSet = false;
    _pendingRepSaves.clear();
    _coachDiagnostics.clear();
    if (!preservePreparedRuntime) {
      _inferenceLatencies.clear();
      _activeModelQuality = PoseModelQuality.lite;
      _targetInferenceFps = 30;
      _performanceTuning = false;
    }
    _calibrationRequired = true;
    _pausedDuringCalibration = false;
    _calibrationWindowStartedLocalUs = null;
    _lastCalibrationPromptLocalUs = null;
    _trackingLostCount = 0;
    _trackingLostStartedLocalUs = null;
    _trackingLostDurationUs = 0;
    _calibrationDurationMilliseconds = 0;
    _calibrationRetryCount = 0;
    _shallowAttemptCount = 0;
    _confidenceTotal = 0;
    _confidenceSampleCount = 0;
    _detectionSummaryLogged = false;
    _calibrationCompletedLogged = false;
    _firstRepLogged = false;
    _workoutStartedLogged = false;
    _cameraRetrying = false;
    _finalizing = false;
    _finalized = false;
    _workoutTimelineOriginUs = null;
    _lastJournalCheckpointSecond = -1;
    if (!preservePreparedRuntime) _resetOverlayTracking();
  }

  void _resetOverlayTracking() {
    _overlaySmoother.reset();
    _lastRenderablePoseReceivedLocalUs = null;
  }

  void _observeInferenceLatency(int milliseconds) {
    if (milliseconds <= 0) return;
    _inferenceLatencies.add(milliseconds);
    if (_inferenceLatencies.length > 45) _inferenceLatencies.removeAt(0);
    if (_inferenceLatencies.length < 45 || _performanceTuning) return;
    final average =
        _inferenceLatencies.reduce((a, b) => a + b) /
        _inferenceLatencies.length;
    final desiredFps = average < 25
        ? 30
        : average < 40
        ? 24
        : average < 65
        ? 20
        : 15;
    if (desiredFps == _targetInferenceFps) return;
    unawaited(_applyPerformancePolicy(targetFps: desiredFps));
  }

  Future<void> _applyPerformancePolicy({required int targetFps}) async {
    final engine = _poseEngine;
    if (engine == null || _performanceTuning) return;
    _performanceTuning = true;
    try {
      if (targetFps != _targetInferenceFps) {
        await engine.setTargetInferenceFps(targetFps);
        _targetInferenceFps = targetFps;
      }
      _inferenceLatencies.clear();
    } on Object {
      // Keep the current engine configuration and detector state on failure.
    } finally {
      _performanceTuning = false;
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (_disposed || state.session == null) return;
      final now = DateTime.now();
      final tickEvents = _repDetector?.tick(_nowMonotonicUs()) ?? const [];
      if (tickEvents.isNotEmpty && _repDetector != null) {
        final snapshot = _repDetector!.snapshot;
        state = state.copyWith(phase: snapshot.phase);
        final trackingLostEvents = tickEvents.where(
          (event) => event.type == RepEventType.trackingLost,
        );
        if (trackingLostEvents.isNotEmpty) {
          final event = trackingLostEvents.first;
          _recordTrackingLost(
            elapsedBeforeReportUs: event.trackingLostDurationUs ?? 0,
          );
          _enqueueCoach(
            CoachMessageType.tracking,
            _messages!.tracking(snapshot.trackingState, state.totalReps % 2),
            'tracking_${snapshot.trackingState.name}',
          );
        }
      }
      state = state.copyWith(
        activeElapsed: _activeElapsed,
        restElapsed: _currentRestElapsed(now),
        totalElapsed: _totalElapsed,
      );
      _checkCalibrationPrompt();
      if (state.status == WorkoutSessionStatus.resting &&
          state.restRemaining == Duration.zero &&
          state.saveState != WorkoutSaveState.failed) {
        unawaited(startNextSet());
      }
      if (state.status == WorkoutSessionStatus.resting &&
          state.restRemaining.inSeconds == 10) {
        _enqueueCoach(
          CoachMessageType.rest,
          _messages!.restTenSeconds,
          'rest_ten_${state.currentSetIndex}',
        );
      }
      final checkpointSecond = _totalElapsed.inSeconds;
      if (state.isWorkoutInProgress &&
          checkpointSecond - _lastJournalCheckpointSecond >= 5) {
        _lastJournalCheckpointSecond = checkpointSecond;
        _saveJournalSafely(state.status);
      }
    });
  }

  Duration _currentRestElapsed(DateTime now) {
    if (_restStartedAt == null) return _restAccumulated;
    final effectiveEnd = _earlierDate(now, state.restEndsAt ?? now);
    final segment = effectiveEnd.difference(_restStartedAt!);
    return _restAccumulated + (segment.isNegative ? Duration.zero : segment);
  }

  Duration get _activeElapsed => _activeBase + _activeStopwatch.elapsed;

  Duration get _totalElapsed => _totalBase + _totalStopwatch.elapsed;

  Future<void> _saveJournal(WorkoutSessionStatus status) {
    final session = state.session;
    final currentSet = state.currentSet;
    if (session == null || currentSet == null) return Future.value();
    final currentSetActive = (_activeElapsed - _setActiveStartedAt).inSeconds
        .clamp(0, 864000);
    final journal = WorkoutJournal(
      sessionId: session.id,
      currentSetId: currentSet.id,
      status: status,
      activeDurationSeconds: _activeElapsed.inSeconds,
      currentSetActiveDurationSeconds: currentSetActive.toInt(),
      restDurationSeconds: _restAccumulated.inSeconds,
      totalDurationSeconds: _totalElapsed.inSeconds,
      restStartedAt: _restStartedAt,
      restEndsAt: state.restEndsAt,
      updatedAt: DateTime.now(),
    );
    final write = _journalChain.then(
      (_) => ref.read(workoutRepositoryProvider).saveWorkoutJournal(journal),
    );
    _journalChain = write.catchError((Object _) {});
    return write;
  }

  Future<void> _checkpointProgress(WorkoutSessionStatus status) async {
    final session = state.session;
    final currentSet = state.currentSet;
    if (session == null || currentSet == null) return;
    final now = DateTime.now();
    final updatedSession = session.copyWith(
      activeDurationSeconds: _activeElapsed.inSeconds,
      restDurationSeconds: status == WorkoutSessionStatus.resting
          ? _restAccumulated.inSeconds
          : _currentRestElapsed(now).inSeconds,
      totalDurationSeconds: _totalElapsed.inSeconds,
    );
    final updatedSet = status == WorkoutSessionStatus.resting
        ? currentSet.copyWith(
            restDurationAfterSeconds:
                (_currentRestElapsed(now).inSeconds -
                        session.restDurationSeconds)
                    .clamp(0, 3600)
                    .toInt(),
          )
        : currentSet.copyWith(
            completedReps: state.currentSetReps,
            activeDurationSeconds: (_activeElapsed - _setActiveStartedAt)
                .inSeconds
                .clamp(0, 864000)
                .toInt(),
          );
    try {
      await ref
          .read(workoutRepositoryProvider)
          .saveSetAndSession(updatedSet, updatedSession);
      if (_disposed) return;
      state = state.copyWith(
        session: updatedSession,
        currentSet: updatedSet,
        saveState: WorkoutSaveState.saved,
      );
      await _saveJournal(status);
    } on Object {
      if (!_disposed) {
        state = state.copyWith(saveState: WorkoutSaveState.failed);
      }
    }
  }

  void _saveJournalSafely(WorkoutSessionStatus status) {
    unawaited(
      _saveJournal(status).catchError((Object _) {
        if (!_disposed) {
          state = state.copyWith(saveState: WorkoutSaveState.failed);
        }
      }),
    );
  }

  void _beginCalibrationWindow() {
    _calibrationRequired = true;
    final nowUs = _localClock.elapsedMicroseconds;
    _calibrationWindowStartedLocalUs = nowUs;
    _lastCalibrationPromptLocalUs = nowUs;
    _enqueueCalibrationInstruction();
  }

  void _checkCalibrationPrompt() {
    final lastPromptAt = _lastCalibrationPromptLocalUs;
    if (state.status != WorkoutSessionStatus.calibrating ||
        lastPromptAt == null ||
        _localClock.elapsedMicroseconds - lastPromptAt <
            _calibrationPromptInterval.inMicroseconds) {
      return;
    }
    _lastCalibrationPromptLocalUs = _localClock.elapsedMicroseconds;
    _enqueueCoach(
      CoachMessageType.tracking,
      _messages!.tracking(state.trackingState, state.totalReps % 2),
      'calibration_wait_${state.trackingState.name}',
    );
  }

  DateTime _earlierDate(DateTime left, DateTime right) =>
      left.isBefore(right) ? left : right;

  String _workoutStartMessage() => _cumulativeChallenge
      ? _messages!.cumulativeChallengeStart(_spokenRepOffset, state.targetReps)
      : _sevenDayChallengeDay != null
      ? _messages!.sevenDayChallengeStart(_sevenDayChallengeDay!)
      : _messages!.setStart(state.currentSetIndex);

  bool get _isChallengeWorkout =>
      _cumulativeChallenge || _sevenDayChallengeDay != null;

  void _enqueueCoach(
    CoachMessageType type,
    String text,
    String key, {
    int? repSequence,
  }) {
    unawaited(
      _coachQueue?.enqueue(
            CoachMessage(
              type: type,
              text: text,
              deduplicationKey: key,
              createdAt: DateTime.now(),
              expiresAfter: type == CoachMessageType.form
                  ? const Duration(seconds: 8)
                  : const Duration(seconds: 4),
              repSequence: repSequence,
            ),
          ) ??
          Future.value(),
    );
  }

  void _recordCoachDelivery(String event, CoachMessage message) {
    if (event == 'failed' && !_disposed) {
      state = state.copyWith(voiceAvailable: false);
    }
    if (!kDebugMode || state.session == null) return;
    final now = DateTime.now();
    _coachDiagnostics.add({
      'sessionId': state.session!.id,
      'at': now.millisecondsSinceEpoch,
      'event': event,
      'type': message.type.name,
      'text': message.text,
      'repSequence': message.repSequence,
    });
    if (_coachDiagnostics.length > 40) _coachDiagnostics.removeAt(0);
    final encoded = jsonEncode(_coachDiagnostics);
    unawaited(() async {
      try {
        final database = await ref.read(appDatabaseProvider).database;
        await database.rawInsert(
          'INSERT OR REPLACE INTO app_state(key, value, updated_at) '
          'VALUES(?, ?, ?)',
          ['coach_debug_latest', encoded, now.millisecondsSinceEpoch],
        );
      } on Object {
        // Debug telemetry must never affect workout coaching.
      }
    }());
  }

  void _recordTrackingLost({int elapsedBeforeReportUs = 0}) {
    if (_trackingLostStartedLocalUs != null) return;
    _trackingLostCount++;
    if (elapsedBeforeReportUs > 0) {
      _trackingLostDurationUs += elapsedBeforeReportUs;
    }
    _trackingLostStartedLocalUs = _localClock.elapsedMicroseconds;
  }

  void _recordTrackingRecovered() {
    final startedAt = _trackingLostStartedLocalUs;
    if (startedAt == null) return;
    final duration = _localClock.elapsedMicroseconds - startedAt;
    if (duration > 0) _trackingLostDurationUs += duration;
    _trackingLostStartedLocalUs = null;
  }

  void _logDetectionSummary({required bool completed}) {
    if (_detectionSummaryLogged) return;
    _captureUnfinishedCalibration();
    _detectionSummaryLogged = true;
    _recordTrackingRecovered();
    ref
        .read(analyticsServiceProvider)
        .workoutDetectionSummary(
          completed: completed,
          trackingLostCount: _trackingLostCount,
          trackingLostMilliseconds: _trackingLostDurationUs ~/ 1000,
          calibrationMilliseconds: _calibrationDurationMilliseconds,
          calibrationRetries: _calibrationRetryCount,
          shallowAttemptCount: _shallowAttemptCount,
          averageConfidence: _confidenceSampleCount == 0
              ? 0
              : _confidenceTotal / _confidenceSampleCount,
        );
  }

  void _logCalibrationCompleted() {
    if (_calibrationCompletedLogged) return;
    _calibrationCompletedLogged = true;
    final plan = state.plan;
    final analytics = ref.read(analyticsServiceProvider);
    analytics
      ..calibrationCompleted(
        elapsed: Duration(milliseconds: _calibrationDurationMilliseconds),
      )
      ..screenView('active_workout');
    if (plan != null && !_workoutStartedLogged) {
      _workoutStartedLogged = true;
      analytics.workoutStarted(
        plannedSets: plan.setCount,
        plannedRepsPerSet: plan.targetRepsPerSet,
      );
    }
  }

  void _logFirstRep() {
    if (!_firstRepLogged) {
      _firstRepLogged = true;
      ref
          .read(analyticsServiceProvider)
          .firstRepDetected(elapsed: _totalElapsed);
    }
    state = state.copyWith(workoutStarted: true);
  }

  Future<void> _logCompletionMilestone() async {
    try {
      final sessions = await ref.read(workoutRepositoryProvider).loadSessions();
      final completedCount = sessions
          .where(
            (details) =>
                details.session.completed && !details.session.interrupted,
          )
          .length;
      if (completedCount == 2) {
        ref.read(analyticsServiceProvider).secondWorkoutCompleted();
      }
    } on Object {
      // Milestone analytics must not affect workout completion.
    }
  }

  String _cancelStage(WorkoutSessionStatus status, int reps) =>
      switch (status) {
        WorkoutSessionStatus.preparing => 'camera_initialization',
        WorkoutSessionStatus.calibrating => 'calibration',
        WorkoutSessionStatus.resting => 'rest',
        WorkoutSessionStatus.completed => 'summary',
        WorkoutSessionStatus.active || WorkoutSessionStatus.paused =>
          reps == 0 ? 'before_first_rep' : 'during_set',
        WorkoutSessionStatus.error =>
          reps == 0 ? 'before_first_rep' : 'during_set',
        _ => 'unknown',
      };

  String _cancelReason(WorkoutSessionStatus status, String? errorCode) {
    if (status != WorkoutSessionStatus.error) return 'user_exit';
    if (errorCode == 'camera_initialization_failed' ||
        errorCode == 'start_failed') {
      return 'camera_initialization_failed';
    }
    if (errorCode == 'calibration_failed') return 'calibration_failed';
    return 'app_error';
  }

  String _failureStage(WorkoutSessionStatus status, String errorCode) {
    if (status == WorkoutSessionStatus.calibrating ||
        errorCode == 'calibration_failed') {
      return 'calibration';
    }
    if (errorCode.startsWith('model_') || errorCode == 'inference_failed') {
      return 'pose_engine_initialization';
    }
    if (status == WorkoutSessionStatus.active || state.totalReps > 0) {
      return 'active_workout';
    }
    return 'camera_initialization';
  }

  String _failureReason(String errorCode) => switch (errorCode) {
    'camera_unavailable' || 'no_camera' => 'camera_unavailable',
    'initialization_timeout' || 'camera_timeout' => 'initialization_timeout',
    'model_load_failed' ||
    'model_initialization_failed' ||
    'model_unavailable' ||
    'inference_failed' => 'pose_engine_error',
    'calibration_failed' => 'calibration_timeout',
    'camera_initialization_failed' || 'start_failed' => 'controller_error',
    _ => 'unknown',
  };

  void _enqueueCalibrationInstruction() {
    final messages = _messages;
    if (messages == null) return;
    _enqueueCoach(
      CoachMessageType.tracking,
      messages.calibration,
      'calibration_instruction',
    );
  }

  void _adoptPreparedCalibration(RepDetectorSnapshot snapshot) {
    if (snapshot.calibrationProgress < 1 ||
        _calibrationDurationMilliseconds > 0) {
      return;
    }
    _calibrationDurationMilliseconds = snapshot.calibrationElapsedUs ~/ 1000;
    _calibrationRetryCount = snapshot.calibrationRetries;
  }

  void _captureUnfinishedCalibration() {
    final snapshot = _repDetector?.snapshot;
    if (snapshot == null || snapshot.calibrationProgress >= 1) return;
    final startedAt = _calibrationWindowStartedLocalUs;
    final localElapsedUs = startedAt == null
        ? 0
        : _localClock.elapsedMicroseconds - startedAt;
    final detectorElapsedUs = snapshot.calibrationElapsedUs;
    final elapsedUs = localElapsedUs > detectorElapsedUs
        ? localElapsedUs
        : detectorElapsedUs;
    if (elapsedUs > 0) {
      _calibrationDurationMilliseconds += elapsedUs ~/ 1000;
    }
    _calibrationRetryCount += snapshot.calibrationRetries;
    _calibrationWindowStartedLocalUs = null;
    _lastCalibrationPromptLocalUs = null;
  }

  int _averageRepDuration(int currentAverage, int currentCount, int next) {
    if (currentCount <= 0) return next;
    return ((currentAverage * currentCount + next) / (currentCount + 1))
        .round();
  }

  RepQuality _repQuality(FormAnalysisResult analysis, FormMetricType metric) =>
      switch (analysis.metrics[metric]?.status) {
        FormMetricStatus.passed => RepQuality.good,
        FormMetricStatus.needsAttention => RepQuality.needsImprovement,
        _ => RepQuality.unavailable,
      };

  Future<void> _startWorkoutVideoIfAvailable(String sessionId) async {
    if (!_videoReviewRequested || _videoRecordingActive) return;
    final engine = _poseEngine;
    final RecordablePoseEngine? recorder = engine is RecordablePoseEngine
        ? engine as RecordablePoseEngine
        : null;
    if (recorder == null || !recorder.recordingSupported) return;
    try {
      await recorder.startVideoRecording(sessionId);
      _videoRecordingActive = true;
    } on Object catch (error, stackTrace) {
      _videoReviewRequested = false;
      unawaited(_recordNonFatal(error, stackTrace, 'video_recording_start'));
      try {
        await recorder.cancelVideoRecording();
      } on Object {
        // Recording is optional; pose detection remains authoritative.
      }
    }
  }

  Future<WorkoutSession> _finalizeWorkoutVideo(WorkoutSession session) async {
    final finalized = _finalizedWorkoutVideo;
    if (!_videoRecordingActive && finalized != null) {
      return session.copyWith(
        videoPath: finalized.path,
        videoDurationMilliseconds: finalized.durationMilliseconds,
      );
    }
    if (!_videoRecordingActive) return session;
    _videoRecordingActive = false;
    final engine = _poseEngine;
    final RecordablePoseEngine? recorder = engine is RecordablePoseEngine
        ? engine as RecordablePoseEngine
        : null;
    if (recorder == null) return session;
    try {
      final result = await recorder.stopVideoRecording();
      if (result.path.isEmpty || result.durationMilliseconds <= 0) {
        throw StateError('Native recorder returned an empty workout video.');
      }
      final updated = session.copyWith(
        videoPath: result.path,
        videoDurationMilliseconds: result.durationMilliseconds,
      );
      try {
        await ref
            .read(workoutRepositoryProvider)
            .saveWorkoutVideo(
              sessionId: session.id,
              path: result.path,
              durationMilliseconds: result.durationMilliseconds,
            );
      } on Object {
        final file = File(result.path);
        if (await file.exists()) await file.delete();
        rethrow;
      }
      _finalizedWorkoutVideo = result;
      if (!_disposed && state.session?.id == session.id) {
        state = state.copyWith(session: updated);
      }
      return updated;
    } on Object catch (error, stackTrace) {
      _finalizedWorkoutVideo = null;
      unawaited(_recordNonFatal(error, stackTrace, 'video_recording_stop'));
      try {
        await recorder.cancelVideoRecording();
      } on Object {
        // Failed video finalization must not fail the workout record.
      }
      return session;
    }
  }

  Future<void> _cancelWorkoutVideo({bool disableForSession = false}) async {
    if (disableForSession) _videoReviewRequested = false;
    if (!_videoRecordingActive) return;
    _videoRecordingActive = false;
    _finalizedWorkoutVideo = null;
    final engine = _poseEngine;
    final RecordablePoseEngine? recorder = engine is RecordablePoseEngine
        ? engine as RecordablePoseEngine
        : null;
    if (recorder == null) return;
    try {
      await recorder.cancelVideoRecording();
    } on Object {
      // Cancellation is best-effort; native dispose also removes partials.
    }
  }

  int _nowMonotonicUs() {
    final poseTime = _lastPoseTimestampUs;
    final receivedAt = _lastPoseReceivedLocalUs;
    if (poseTime == null || receivedAt == null) {
      return _localClock.elapsedMicroseconds;
    }
    return poseTime + (_localClock.elapsedMicroseconds - receivedAt);
  }

  void _onPoseError(Object error, StackTrace stackTrace) {
    final errorCode = switch (error) {
      PoseEngineException(:final code) => code,
      PlatformException(:final code) => code,
      _ => 'pose_stream_failed',
    };
    if (errorCode == 'inference_failed') {
      if (!_inferenceFailureReported) {
        _inferenceFailureReported = true;
        unawaited(_recordNonFatal(error, stackTrace, 'pose_inference'));
      }
      _resetOverlayTracking();
      state = state.copyWith(
        trackingState: TrackingState.lost,
        overlayLandmarks: const [],
        phase: state.status == WorkoutSessionStatus.calibrating
            ? SquatPhase.calibrating
            : SquatPhase.trackingLost,
        poseFeedbackLevel: PoseFeedbackLevel.unavailable,
      );
      return;
    }
    unawaited(_recordCameraFailure(error, stackTrace, 'pose_stream'));
    _activeStopwatch.stop();
    if (state.status == WorkoutSessionStatus.calibrating) {
      _captureUnfinishedCalibration();
      _repDetector?.reset();
    }
    _recordTrackingRecovered();
    _calibrationWindowStartedLocalUs = null;
    _lastCalibrationPromptLocalUs = null;
    _repDetector?.pause(_nowMonotonicUs());
    state = state.copyWith(
      status: WorkoutSessionStatus.error,
      phase: SquatPhase.paused,
      errorCode: errorCode,
    );
    unawaited(_pausePoseEngineSafely());
    _saveJournalSafely(WorkoutSessionStatus.error);
  }

  Future<void> _recordCameraFailure(
    Object error,
    StackTrace stackTrace,
    String reason,
  ) async {
    final reporting = ref.read(crashReportingServiceProvider);
    final failureReason = switch (error) {
      PoseEngineException(:final code) => _failureReason(code),
      PlatformException(:final code) => _failureReason(code),
      _ => 'unknown',
    };
    if (reason == 'workout_start' ||
        reason == 'workout_recovery' ||
        reason == 'camera_retry') {
      ref
          .read(analyticsServiceProvider)
          .cameraInitializationFailed(
            failureReason: failureReason,
            sessionState: state.status.name,
          );
    }
    await reporting.setCustomKey('camera_state', 'failed');
    await reporting.recordNonFatal(error, stackTrace, reason: reason);
  }

  Future<void> _recordNonFatal(
    Object error,
    StackTrace stackTrace,
    String reason,
  ) => ref
      .read(crashReportingServiceProvider)
      .recordNonFatal(error, stackTrace, reason: reason);

  Future<void> _setDiagnosticState(String key, String value) =>
      ref.read(crashReportingServiceProvider).setCustomKey(key, value);

  Future<void> _diagnosticLog(String message) =>
      ref.read(crashReportingServiceProvider).log(message);

  Future<void> _disposeEngineOnly() async {
    _prewarming = false;
    _resetOverlayTracking();
    await _cancelWorkoutVideo(disableForSession: true);
    try {
      await _poseSubscription?.cancel();
    } on Object {
      // Continue releasing the native engine.
    }
    _poseSubscription = null;
    try {
      await _poseEngine?.dispose();
    } on Object {
      // Disposal is best-effort after progress has been checkpointed.
    }
    _poseEngine = null;
    _repDetector = null;
    _engineVideoCapabilityRequested = false;
  }

  Future<void> _pausePoseEngineSafely() async {
    try {
      await _poseEngine?.pause();
    } on Object {
      // Terminal and error states remain authoritative if native pause fails.
    }
  }

  Future<void> _disposeResources() async {
    _disposed = true;
    await _releaseRuntimeResources();
  }

  Future<void> _releaseRuntimeResources() async {
    _ticker?.cancel();
    _ticker = null;
    try {
      await _eventChain;
    } on Object {
      // Continue cleanup; failed progress remains recoverable from the journal.
    }
    try {
      await _journalChain;
    } on Object {
      // A newer session can still start after a failed auxiliary checkpoint.
    }
    try {
      await _subtitleSubscription?.cancel();
    } on Object {
      // Continue releasing the remaining session resources.
    }
    _subtitleSubscription = null;
    await _disposeEngineOnly();
    try {
      await _coachQueue?.dispose();
    } on Object {
      // TTS cleanup cannot block a new or completed workout session.
    }
    _coachQueue = null;
  }
}
