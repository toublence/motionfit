import 'package:motionfit_squat/core/analytics/calibration_feedback.dart';

/// Reuses each exercise's translated instructions. Never infer distance from
/// missing joints alone: moving farther back can make low confidence worse.
String preparationFeedbackText(
  CalibrationFeedback feedback, {
  required String camera,
  required String noPerson,
  required String partialBody,
  required String angle,
  required String hold,
  required String ready,
}) => switch (feedback) {
  CalibrationFeedback.connecting => camera,
  CalibrationFeedback.noPerson || CalibrationFeedback.trackingLost => noPerson,
  CalibrationFeedback.partialBody ||
  CalibrationFeedback.lowConfidence => partialBody,
  CalibrationFeedback.invalidAngle => angle,
  CalibrationFeedback.unstablePose ||
  CalibrationFeedback.insufficientValidFrames ||
  CalibrationFeedback.temporaryTrackingLoss => hold,
  CalibrationFeedback.ready => ready,
};
