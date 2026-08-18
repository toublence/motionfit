export 'package:motionfit_squat/features/squat/domain/models/workout_enums.dart'
    show
        CameraAngle,
        CameraSelection,
        TrackingState,
        PoseFeedbackLevel,
        WorkoutSessionStatus,
        FormIssue,
        RepAnalysisResult,
        RepQuality,
        RecordViewMode,
        StatisticsRange,
        enumByName;

enum PushupPhase {
  calibrating,
  ready,
  descending,
  bottom,
  ascending,
  completed,
  trackingLost,
  paused,
}
