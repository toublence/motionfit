enum CameraAngle { front, side, oblique, uncertain }

enum CameraSelection { front, back }

enum TrackingState {
  tracking,
  noPerson,
  partialBody,
  multiplePeople,
  lost,
  cameraUnavailable,
  modelUnavailable,
}

enum PoseFeedbackLevel { good, caution, poor, unavailable }

enum SquatPhase {
  calibrating,
  ready,
  descending,
  bottom,
  ascending,
  completed,
  trackingLost,
  paused,
}

enum WorkoutSessionStatus {
  idle,
  preparing,
  calibrating,
  active,
  paused,
  resting,
  completed,
  interrupted,
  error,
}

enum FormIssue {
  insufficientDepth,
  excessiveTorsoLean,
  heelLift,
  kneeAlignment,
  leftRightImbalance,
  descentTooFast,
  descentTooSlow,
  ascentTooFast,
  ascentTooSlow,
  unstableControl,
  incompleteLockout,
}

enum RepAnalysisResult { good, needsImprovement, improved, notAssessed }

enum RepQuality { good, needsImprovement, unavailable }

enum RecordViewMode { calendar, list, statistics }

enum StatisticsRange { sevenDays, thirtyDays, thisMonth, all, custom }

T enumByName<T extends Enum>(Iterable<T> values, String? name, T fallback) {
  if (name == null) return fallback;
  for (final value in values) {
    if (value.name == name) return value;
  }
  return fallback;
}
