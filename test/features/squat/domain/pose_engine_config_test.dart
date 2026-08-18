import 'package:flutter_test/flutter_test.dart';
import 'package:motionfit_squat/features/squat/domain/services/pose_engine.dart';

void main() {
  test('defaults to the motion-fit3 realtime detector profile', () {
    const config = PoseEngineConfig();

    expect(config.preferredQuality, PoseModelQuality.lite);
    expect(config.targetInferenceFps, 30);
  });
}
