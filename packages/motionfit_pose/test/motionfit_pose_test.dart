import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:motionfit_pose/motionfit_pose.dart';

void main() {
  test('decodes the numeric-only native frame contract', () {
    final frame = MotionfitPoseFrame.fromMap({
      'frameId': 7,
      'timestampUs': 123456,
      'trackingState': 'tracking',
      'personCount': 1,
      'normalizedLandmarks': Float32List(33 * 5),
      'worldLandmarks': Float32List(33 * 5),
      'mirrored': true,
      'rotationDegrees': 0,
      'inputWidth': 720,
      'inputHeight': 1280,
      'inferenceLatencyMilliseconds': 23,
      'model': 'heavy',
      'previewTransform': Float64List.fromList([-1, 0, 1, 0, 1, 0, 0, 0, 1]),
      'previewHandlesCropAndRotation': true,
    });

    expect(frame.frameId, 7);
    expect(frame.trackingState, MotionfitTrackingState.tracking);
    expect(frame.normalizedLandmarks, hasLength(165));
    expect(frame.previewTransform, hasLength(9));
    expect(frame.previewTransform.first, -1);
  });

  test('decodes the motion-fit3 realtime Lite model', () {
    final frame = MotionfitPoseFrame.fromMap({
      'normalizedLandmarks': Float32List(33 * 5),
      'worldLandmarks': Float32List(33 * 5),
      'model': 'lite',
    });

    expect(frame.model, MotionfitPoseModel.lite);
    expect(frame.normalizedLandmarks, hasLength(165));
  });
}
