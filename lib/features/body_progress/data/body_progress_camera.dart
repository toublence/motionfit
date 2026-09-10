import 'dart:io';

import 'package:motionfit_pose/motionfit_pose.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_enums.dart';

class BodyProgressCameraException implements Exception {
  const BodyProgressCameraException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'BodyProgressCameraException($code, $message)';
}

class BodyProgressPreview {
  const BodyProgressPreview({
    required this.textureId,
    required this.width,
    required this.height,
    required this.rotationDegrees,
    required this.handlesCropAndRotation,
    required this.mirrored,
  });

  final int textureId;

  /// Preview buffer size, before [rotationDegrees] is applied.
  final int width;
  final int height;

  /// How far the texture has to be turned to sit upright, when the platform
  /// does not do it itself.
  final int rotationDegrees;
  final bool handlesCropAndRotation;

  /// True when the platform already mirrored the preview.
  final bool mirrored;
}

class BodyProgressCapturedImage {
  const BodyProgressCapturedImage({
    required this.directory,
    required this.fileName,
    required this.width,
    required this.height,
  });

  final String directory;
  final String fileName;
  final int width;
  final int height;

  File get file => File('$directory${Platform.pathSeparator}$fileName');
}

/// Body Progress camera, backed by the native still capture session.
///
/// The workout pose engine and this session both hold the device camera, so the
/// platform rejects a start while the other is live. Callers surface that as a
/// `camera_busy` error rather than retrying.
class BodyProgressCamera {
  BodyProgressCamera({MotionfitPose? plugin}) : _plugin = plugin ?? MotionfitPose();

  final MotionfitPose _plugin;
  bool _running = false;

  bool get isRunning => _running;

  Future<BodyProgressPreview> start(CameraSelection camera) async {
    final start = await _translate(
      () => _plugin.startStillCapture(camera: _camera(camera)),
    );
    _running = true;
    return _preview(start);
  }

  Future<BodyProgressPreview> switchCamera(CameraSelection camera) async {
    final start = await _translate(
      () => _plugin.switchStillCamera(_camera(camera)),
    );
    return _preview(start);
  }

  Future<BodyProgressCapturedImage> capture() async {
    final photo = await _translate(_plugin.captureStill);
    return BodyProgressCapturedImage(
      directory: photo.directory,
      fileName: photo.fileName,
      width: photo.width,
      height: photo.height,
    );
  }

  /// Directory that holds every stored Body Progress image.
  ///
  /// Resolved on demand because iOS may hand the application container a new
  /// absolute path after a restore.
  Future<Directory> directory() async {
    final path = await _translate(_plugin.stillCaptureDirectory);
    return Directory(path);
  }

  Future<void> stop() async {
    if (!_running) return;
    _running = false;
    await _translate(_plugin.stopStillCapture);
  }

  BodyProgressPreview _preview(MotionfitStillCaptureStart start) =>
      BodyProgressPreview(
        textureId: start.textureId,
        width: start.previewWidth,
        height: start.previewHeight,
        rotationDegrees: start.rotationDegrees,
        handlesCropAndRotation: start.handlesCropAndRotation,
        mirrored: start.mirrored,
      );

  MotionfitCamera _camera(CameraSelection camera) => switch (camera) {
    CameraSelection.front => MotionfitCamera.front,
    CameraSelection.back => MotionfitCamera.back,
  };

  Future<T> _translate<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on MotionfitPoseException catch (error) {
      throw BodyProgressCameraException(error.code, error.message);
    }
  }
}
