import 'package:flutter_test/flutter_test.dart';
import 'package:motionfit_squat/features/squat/domain/models/pose_frame.dart';
import 'package:motionfit_squat/features/squat/domain/services/pose_landmark_smoother.dart';

void main() {
  List<PoseLandmark> pose({required double x, double confidence = 0.9}) =>
      List<PoseLandmark>.generate(
        33,
        (_) => PoseLandmark(
          x: x,
          y: 0.5,
          z: 0,
          visibility: confidence,
          presence: confidence,
        ),
        growable: false,
      );

  test('smooths jitter and resets after a long frame gap', () {
    final smoother = PoseLandmarkSmoother();

    final first = smoother.smooth(pose(x: 0.4), 1000000);
    final jittered = smoother.smooth(pose(x: 0.42), 1040000);
    final reacquired = smoother.smooth(pose(x: 0.8), 1400000);

    expect(first.first.x, 0.4);
    expect(jittered.first.x, greaterThan(0.4));
    expect(jittered.first.x, lessThan(0.42));
    expect(reacquired.first.x, 0.8);
  });

  test('holds a reliable coordinate while confidence briefly drops', () {
    final smoother = PoseLandmarkSmoother();

    smoother.smooth(pose(x: 0.4), 1000000);
    final lowConfidence = smoother.smooth(
      pose(x: 0.9, confidence: 0.05),
      1040000,
    );

    expect(lowConfidence.first.x, 0.4);
    expect(lowConfidence.first.confidence, lessThan(0.9));
  });
}
