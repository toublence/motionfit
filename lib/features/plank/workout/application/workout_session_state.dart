import 'package:motionfit_squat/features/plank/workout/domain/models/workout_enums.dart';
import 'package:motionfit_squat/features/plank/workout/domain/models/pose_frame.dart';
import 'package:motionfit_squat/features/plank/workout/domain/models/workout_plan.dart';
import 'package:motionfit_squat/features/plank/workout/domain/models/workout_session.dart';
import 'package:motionfit_squat/features/plank/workout/domain/models/workout_set.dart';
import 'package:motionfit_squat/features/plank/workout/domain/services/form_analyzer.dart';
import 'package:motionfit_squat/features/plank/workout/domain/services/workout_session_policy.dart';

enum WorkoutSaveState { idle, saving, saved, failed }

class WorkoutSessionState {
  const WorkoutSessionState({
    required this.status,
    required this.plan,
    required this.session,
    required this.currentSet,
    required this.currentSetIndex,
    required this.currentSetReps,
    required this.totalReps,
    required this.phase,
    required this.trackingState,
    required this.calibrationProgress,
    required this.activeElapsed,
    required this.restElapsed,
    required this.totalElapsed,
    required this.restEndsAt,
    required this.subtitle,
    required this.previewTextureId,
    required this.overlayLandmarks,
    required this.previewTransform,
    required this.previewMirrored,
    required this.previewRotationDegrees,
    required this.previewHandlesCropAndRotation,
    required this.previewInputWidth,
    required this.previewInputHeight,
    required this.poseFeedbackLevel,
    required this.formAnalyses,
    required this.saveState,
    required this.errorCode,
    required this.skeletonVisible,
    required this.voiceAvailable,
    required this.pauseReason,
    required this.workoutStarted,
  });

  factory WorkoutSessionState.idle() => const WorkoutSessionState(
    status: WorkoutSessionStatus.idle,
    plan: null,
    session: null,
    currentSet: null,
    currentSetIndex: 0,
    currentSetReps: 0,
    totalReps: 0,
    phase: SquatPhase.calibrating,
    trackingState: TrackingState.lost,
    calibrationProgress: 0,
    activeElapsed: Duration.zero,
    restElapsed: Duration.zero,
    totalElapsed: Duration.zero,
    restEndsAt: null,
    subtitle: null,
    previewTextureId: null,
    overlayLandmarks: [],
    previewTransform: [1, 0, 0, 0, 1, 0, 0, 0, 1],
    previewMirrored: false,
    previewRotationDegrees: 0,
    previewHandlesCropAndRotation: true,
    previewInputWidth: 0,
    previewInputHeight: 0,
    poseFeedbackLevel: PoseFeedbackLevel.unavailable,
    formAnalyses: [],
    saveState: WorkoutSaveState.idle,
    errorCode: null,
    skeletonVisible: true,
    voiceAvailable: true,
    pauseReason: null,
    workoutStarted: false,
  );

  final WorkoutSessionStatus status;
  final WorkoutPlan? plan;
  final WorkoutSession? session;
  final WorkoutSet? currentSet;
  final int currentSetIndex;
  final int currentSetReps;
  final int totalReps;
  final SquatPhase phase;
  final TrackingState trackingState;
  final double calibrationProgress;
  final Duration activeElapsed;
  final Duration restElapsed;
  final Duration totalElapsed;
  final DateTime? restEndsAt;
  final String? subtitle;
  final int? previewTextureId;
  final List<PoseLandmark> overlayLandmarks;
  final List<double> previewTransform;
  final bool previewMirrored;
  final int previewRotationDegrees;
  final bool previewHandlesCropAndRotation;
  final int previewInputWidth;
  final int previewInputHeight;
  final PoseFeedbackLevel poseFeedbackLevel;
  final List<FormAnalysisResult> formAnalyses;
  final WorkoutSaveState saveState;
  final String? errorCode;
  final bool skeletonVisible;
  final bool voiceAvailable;
  final String? pauseReason;
  final bool workoutStarted;

  bool get isValidWorkout => WorkoutSessionPolicy.isValidRecord(
    workoutStarted: workoutStarted,
    detectedReps: totalReps,
  );

  bool get isWorkoutInProgress => switch (status) {
    WorkoutSessionStatus.preparing ||
    WorkoutSessionStatus.calibrating ||
    WorkoutSessionStatus.active ||
    WorkoutSessionStatus.paused ||
    WorkoutSessionStatus.resting => true,
    _ => false,
  };

  int get targetReps => plan?.targetRepsPerSet ?? 0;
  int get totalSets => plan?.setCount ?? 0;

  Duration get restRemaining {
    if (restEndsAt == null) return Duration.zero;
    final remaining = restEndsAt!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  WorkoutSessionState copyWith({
    WorkoutSessionStatus? status,
    WorkoutPlan? plan,
    WorkoutSession? session,
    WorkoutSet? currentSet,
    int? currentSetIndex,
    int? currentSetReps,
    int? totalReps,
    SquatPhase? phase,
    TrackingState? trackingState,
    double? calibrationProgress,
    Duration? activeElapsed,
    Duration? restElapsed,
    Duration? totalElapsed,
    DateTime? restEndsAt,
    bool clearRestEndsAt = false,
    String? subtitle,
    bool clearSubtitle = false,
    int? previewTextureId,
    bool clearPreviewTextureId = false,
    List<PoseLandmark>? overlayLandmarks,
    List<double>? previewTransform,
    bool? previewMirrored,
    int? previewRotationDegrees,
    bool? previewHandlesCropAndRotation,
    int? previewInputWidth,
    int? previewInputHeight,
    PoseFeedbackLevel? poseFeedbackLevel,
    List<FormAnalysisResult>? formAnalyses,
    WorkoutSaveState? saveState,
    String? errorCode,
    bool clearError = false,
    bool? skeletonVisible,
    bool? voiceAvailable,
    String? pauseReason,
    bool clearPauseReason = false,
    bool? workoutStarted,
  }) {
    return WorkoutSessionState(
      status: status ?? this.status,
      plan: plan ?? this.plan,
      session: session ?? this.session,
      currentSet: currentSet ?? this.currentSet,
      currentSetIndex: currentSetIndex ?? this.currentSetIndex,
      currentSetReps: currentSetReps ?? this.currentSetReps,
      totalReps: totalReps ?? this.totalReps,
      phase: phase ?? this.phase,
      trackingState: trackingState ?? this.trackingState,
      calibrationProgress: calibrationProgress ?? this.calibrationProgress,
      activeElapsed: activeElapsed ?? this.activeElapsed,
      restElapsed: restElapsed ?? this.restElapsed,
      totalElapsed: totalElapsed ?? this.totalElapsed,
      restEndsAt: clearRestEndsAt ? null : restEndsAt ?? this.restEndsAt,
      subtitle: clearSubtitle ? null : subtitle ?? this.subtitle,
      previewTextureId: clearPreviewTextureId
          ? null
          : previewTextureId ?? this.previewTextureId,
      overlayLandmarks: overlayLandmarks ?? this.overlayLandmarks,
      previewTransform: previewTransform ?? this.previewTransform,
      previewMirrored: previewMirrored ?? this.previewMirrored,
      previewRotationDegrees:
          previewRotationDegrees ?? this.previewRotationDegrees,
      previewHandlesCropAndRotation:
          previewHandlesCropAndRotation ?? this.previewHandlesCropAndRotation,
      previewInputWidth: previewInputWidth ?? this.previewInputWidth,
      previewInputHeight: previewInputHeight ?? this.previewInputHeight,
      poseFeedbackLevel: poseFeedbackLevel ?? this.poseFeedbackLevel,
      formAnalyses: formAnalyses ?? this.formAnalyses,
      saveState: saveState ?? this.saveState,
      errorCode: clearError ? null : errorCode ?? this.errorCode,
      skeletonVisible: skeletonVisible ?? this.skeletonVisible,
      voiceAvailable: voiceAvailable ?? this.voiceAvailable,
      pauseReason: clearPauseReason ? null : pauseReason ?? this.pauseReason,
      workoutStarted: workoutStarted ?? this.workoutStarted,
    );
  }
}
