import 'package:motionfit_squat/features/plank/workout/domain/models/pose_frame.dart';
import 'package:motionfit_squat/features/plank/workout/domain/models/workout_enums.dart';

enum PoseModelQuality { lite, full, heavy }

class PoseEngineConfig {
  const PoseEngineConfig({
    this.camera = CameraSelection.front,
    this.preferredQuality = PoseModelQuality.lite,
    this.targetInferenceFps = 30,
    this.enableVideoRecording = false,
  });

  final CameraSelection camera;
  final PoseModelQuality preferredQuality;
  final int targetInferenceFps;
  final bool enableVideoRecording;
}

class PoseVideoRecordingResult {
  const PoseVideoRecordingResult({
    required this.path,
    required this.durationMilliseconds,
  });

  final String path;
  final int durationMilliseconds;
}

abstract interface class RecordablePoseEngine {
  bool get recordingSupported;

  Future<void> startVideoRecording(String sessionId);
  Future<PoseVideoRecordingResult> stopVideoRecording();
  Future<void> cancelVideoRecording();
}

abstract interface class PoseEngine {
  Stream<PoseFrame> get frames;
  int? get previewTextureId;
  bool get isRunning;

  Future<void> start(PoseEngineConfig config);
  Future<void> pause();
  Future<void> resume();
  Future<void> switchCamera(CameraSelection camera);
  Future<void> setModelQuality(PoseModelQuality quality);
  Future<void> setTargetInferenceFps(int fps);
  Future<void> dispose();
}

class PoseEngineException implements Exception {
  const PoseEngineException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'PoseEngineException($code, $message)';
}
