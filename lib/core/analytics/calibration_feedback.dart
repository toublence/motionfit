/// Diagnostic only: none of these states relax the detector's thresholds.
enum CalibrationFeedback {
  connecting,
  noPerson,
  partialBody,
  lowConfidence,
  unstablePose,
  invalidAngle,
  insufficientValidFrames,
  temporaryTrackingLoss,
  trackingLost,
  ready;

  String get analyticsName => switch (this) {
    connecting => 'connecting',
    noPerson => 'no_person',
    partialBody => 'partial_body',
    lowConfidence => 'low_confidence',
    unstablePose => 'unstable_pose',
    invalidAngle => 'invalid_angle',
    insufficientValidFrames => 'insufficient_valid_frames',
    temporaryTrackingLoss => 'temporary_tracking_loss',
    trackingLost => 'tracking_lost',
    ready => 'ready',
  };
}
