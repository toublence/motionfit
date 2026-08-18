import 'dart:async';

import 'package:motionfit_pose/motionfit_pose.dart';
import 'package:motionfit_squat/features/squat/domain/models/pose_frame.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_enums.dart';
import 'package:motionfit_squat/features/squat/domain/services/pose_engine.dart';

class NativePoseEngine implements PoseEngine, RecordablePoseEngine {
  NativePoseEngine({MotionfitPose? plugin})
    : _plugin = plugin ?? MotionfitPose();

  final MotionfitPose _plugin;
  Stream<PoseFrame>? _frames;
  bool _running = false;

  @override
  Stream<PoseFrame> get frames => _frames ??= _plugin.frames.map(_convertFrame);

  @override
  int? get previewTextureId => _plugin.textureId;

  @override
  bool get isRunning => _running;

  @override
  bool get recordingSupported => _plugin.recordingSupported;

  @override
  Future<void> start(PoseEngineConfig config) async {
    try {
      await _plugin.start(
        camera: _camera(config.camera),
        model: _model(config.preferredQuality),
        targetFps: config.targetInferenceFps,
        enableVideoRecording: config.enableVideoRecording,
      );
      _running = true;
    } on MotionfitPoseException catch (error) {
      throw PoseEngineException(error.code, error.message);
    }
  }

  @override
  Future<void> pause() async {
    await _translate(_plugin.pause);
    _running = false;
  }

  @override
  Future<void> resume() async {
    await _translate(_plugin.resume);
    _running = true;
  }

  @override
  Future<void> switchCamera(CameraSelection camera) =>
      _translate(() => _plugin.switchCamera(_camera(camera)));

  @override
  Future<void> setModelQuality(PoseModelQuality quality) =>
      _translate(() => _plugin.setModel(_model(quality)));

  @override
  Future<void> setTargetInferenceFps(int fps) =>
      _translate(() => _plugin.setTargetFps(fps));

  @override
  Future<void> startVideoRecording(String sessionId) => _translate(() async {
    await _plugin.startVideoRecording(sessionId);
  });

  @override
  Future<PoseVideoRecordingResult> stopVideoRecording() async {
    try {
      final result = await _plugin.stopVideoRecording();
      return PoseVideoRecordingResult(
        path: result.path,
        durationMilliseconds: result.durationMilliseconds,
      );
    } on MotionfitPoseException catch (error) {
      throw PoseEngineException(error.code, error.message);
    }
  }

  @override
  Future<void> cancelVideoRecording() =>
      _translate(_plugin.cancelVideoRecording);

  @override
  Future<void> dispose() async {
    _running = false;
    await _translate(_plugin.dispose);
  }

  Future<void> _translate(Future<void> Function() operation) async {
    try {
      await operation();
    } on MotionfitPoseException catch (error) {
      throw PoseEngineException(error.code, error.message);
    }
  }

  PoseFrame _convertFrame(MotionfitPoseFrame frame) {
    List<PoseLandmark> landmarks(List<double> values) {
      if (values.length < 33 * 5) return const [];
      return List.generate(33, (index) {
        final offset = index * 5;
        return PoseLandmark(
          x: values[offset],
          y: values[offset + 1],
          z: values[offset + 2],
          visibility: values[offset + 3],
          presence: values[offset + 4],
        );
      }, growable: false);
    }

    return PoseFrame(
      sequenceId: frame.frameId,
      timestampUs: frame.timestampUs,
      videoElapsedUs: frame.videoElapsedUs,
      landmarks: landmarks(frame.normalizedLandmarks),
      worldLandmarks: landmarks(frame.worldLandmarks),
      trackingState: TrackingState.values.byName(frame.trackingState.name),
      peopleCount: frame.personCount,
      mirrored: frame.mirrored,
      rotationDegrees: frame.rotationDegrees,
      inputWidth: frame.inputWidth,
      inputHeight: frame.inputHeight,
      inferenceLatencyMilliseconds: frame.inferenceLatencyMilliseconds,
      previewTransform: frame.previewTransform,
      previewHandlesCropAndRotation: frame.previewHandlesCropAndRotation,
    );
  }

  MotionfitCamera _camera(CameraSelection camera) =>
      camera == CameraSelection.front
      ? MotionfitCamera.front
      : MotionfitCamera.back;

  MotionfitPoseModel _model(PoseModelQuality quality) => switch (quality) {
    PoseModelQuality.lite => MotionfitPoseModel.lite,
    PoseModelQuality.full => MotionfitPoseModel.full,
    PoseModelQuality.heavy => MotionfitPoseModel.heavy,
  };
}
