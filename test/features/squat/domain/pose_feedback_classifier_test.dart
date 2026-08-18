import 'package:flutter_test/flutter_test.dart';
import 'package:motionfit_squat/features/squat/domain/models/squat_metrics.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_enums.dart';
import 'package:motionfit_squat/features/squat/domain/services/pose_feedback_classifier.dart';

void main() {
  const classifier = PoseFeedbackClassifier();

  test('uses green level for a confident pose inside live thresholds', () {
    expect(
      classifier.classify(
        _metrics(torsoLean: 20, heelLift: 0.01),
        trackingState: TrackingState.tracking,
      ),
      PoseFeedbackLevel.good,
    );
  });

  test('uses yellow level near a form threshold', () {
    expect(
      classifier.classify(
        _metrics(torsoLean: 36, heelLift: 0.01),
        trackingState: TrackingState.tracking,
      ),
      PoseFeedbackLevel.caution,
    );
  });

  test('uses red level for a severe or compound deviation', () {
    expect(
      classifier.classify(
        _metrics(torsoLean: 70, heelLift: 0.05),
        trackingState: TrackingState.tracking,
      ),
      PoseFeedbackLevel.poor,
    );
  });

  test('does not label an untracked body as good form', () {
    expect(
      classifier.classify(
        _metrics(torsoLean: 20, heelLift: 0.01),
        trackingState: TrackingState.noPerson,
      ),
      PoseFeedbackLevel.unavailable,
    );
  });
}

SquatMetrics _metrics({required double torsoLean, required double heelLift}) =>
    SquatMetrics(
      timestampUs: 1,
      confidence: 0.95,
      leftKneeAngle: 170,
      rightKneeAngle: 170,
      kneeAngle: 170,
      leftHipAngle: 170,
      rightHipAngle: 170,
      hipAngle: 170,
      hipY: 0.5,
      shoulderY: 0.25,
      bodyScale: 0.5,
      hipDrop: 0,
      hipVelocity: 0,
      shoulderHipRelativeMovement: 0,
      torsoLeanDegrees: torsoLean,
      leftHeelLift: heelLift,
      rightHeelLift: heelLift,
      kneeAlignmentDeviation: 0.02,
      balanceDeviation: 0.01,
      cameraAngle: CameraAngle.oblique,
    );
