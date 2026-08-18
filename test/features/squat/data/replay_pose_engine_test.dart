import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:motionfit_squat/features/squat/data/replay_pose_engine.dart';
import 'package:motionfit_squat/features/squat/domain/services/pose_engine.dart';

void main() {
  test(
    'replays landmark frames in source order without image payloads',
    () async {
      final source = await File(
        'test/fixtures/replay/no_image_smoke.json',
      ).readAsString();
      final decoded = jsonDecode(source) as Map<String, Object?>;
      final privacy = decoded['privacy']! as Map<String, Object?>;

      expect(privacy['containsImages'], isFalse);
      expect(_containsForbiddenImagePayload(decoded), isFalse);

      final engine = ReplayPoseEngine.fromJson(source, speed: 1000000);
      final received = engine.frames.take(2).toList();
      await engine.start(const PoseEngineConfig());

      final frames = await received.timeout(const Duration(seconds: 1));
      expect(frames.map((frame) => frame.sequenceId), [1, 2]);
      expect(frames.map((frame) => frame.timestampUs), [100000, 150000]);
      expect(frames.every((frame) => frame.landmarks.isEmpty), isTrue);
      expect(engine.previewTextureId, isNull);

      await Future<void>.delayed(Duration.zero);
      await engine.dispose();
    },
  );
}

bool _containsForbiddenImagePayload(Object? value) {
  const forbiddenKeys = {
    'image',
    'imagebytes',
    'pixels',
    'jpeg',
    'jpg',
    'png',
    'base64',
    'camera_frame',
  };
  if (value is Map) {
    for (final entry in value.entries) {
      if (forbiddenKeys.contains(entry.key.toString().toLowerCase())) {
        return true;
      }
      if (_containsForbiddenImagePayload(entry.value)) return true;
    }
  } else if (value is Iterable) {
    return value.any(_containsForbiddenImagePayload);
  }
  return false;
}
