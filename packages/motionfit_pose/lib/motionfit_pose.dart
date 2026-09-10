import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

enum MotionfitCamera { front, back }

enum MotionfitPoseModel { lite, full, heavy }

enum MotionfitTrackingProfile { squat, pushup, plank }

enum MotionfitTrackingState {
  tracking,
  noPerson,
  partialBody,
  multiplePeople,
  lost,
  cameraUnavailable,
  modelUnavailable,
}

class MotionfitPoseFrame {
  const MotionfitPoseFrame({
    required this.frameId,
    required this.timestampUs,
    required this.trackingState,
    required this.personCount,
    required this.normalizedLandmarks,
    required this.worldLandmarks,
    required this.mirrored,
    required this.rotationDegrees,
    required this.inputWidth,
    required this.inputHeight,
    required this.inferenceLatencyMilliseconds,
    required this.model,
    this.videoElapsedUs,
    this.previewTransform = const <double>[1, 0, 0, 0, 1, 0, 0, 0, 1],
    this.previewHandlesCropAndRotation = true,
  });

  final int frameId;
  final int timestampUs;
  final MotionfitTrackingState trackingState;
  final int personCount;

  /// Flattened x, y, z, visibility, presence tuples for MediaPipe's 33 points.
  final Float32List normalizedLandmarks;
  final Float32List worldLandmarks;
  final bool mirrored;
  final int rotationDegrees;
  final int inputWidth;
  final int inputHeight;
  final int inferenceLatencyMilliseconds;
  final MotionfitPoseModel model;

  /// Position of this camera frame on the active workout video timeline.
  ///
  /// This is null when local recording is disabled or unavailable. Unlike
  /// [timestampUs], it excludes any gaps removed from the recorded media.
  final int? videoElapsedUs;
  final List<double> previewTransform;
  final bool previewHandlesCropAndRotation;

  factory MotionfitPoseFrame.fromMap(Map<Object?, Object?> map) {
    Float32List floats(Object? value) {
      if (value is Float32List) return value;
      if (value is List) {
        return Float32List.fromList(
          value.map((item) => (item as num).toDouble()).toList(),
        );
      }
      return Float32List(0);
    }

    T enumValue<T extends Enum>(Iterable<T> values, Object? name, T fallback) {
      for (final value in values) {
        if (value.name == name) return value;
      }
      return fallback;
    }

    final mirrored = map['mirrored'] as bool? ?? false;
    final transform = map['previewTransform'];
    final previewTransform = transform is List
        ? transform
              .map((item) => (item as num).toDouble())
              .toList(growable: false)
        : <double>[mirrored ? -1 : 1, 0, mirrored ? 1 : 0, 0, 1, 0, 0, 0, 1];
    return MotionfitPoseFrame(
      frameId: (map['frameId'] as num? ?? 0).toInt(),
      timestampUs: (map['timestampUs'] as num? ?? 0).toInt(),
      trackingState: enumValue(
        MotionfitTrackingState.values,
        map['trackingState'],
        MotionfitTrackingState.lost,
      ),
      personCount: (map['personCount'] as num? ?? 0).toInt(),
      normalizedLandmarks: floats(map['normalizedLandmarks']),
      worldLandmarks: floats(map['worldLandmarks']),
      mirrored: mirrored,
      rotationDegrees: (map['rotationDegrees'] as num? ?? 0).toInt(),
      inputWidth: (map['inputWidth'] as num? ?? 0).toInt(),
      inputHeight: (map['inputHeight'] as num? ?? 0).toInt(),
      inferenceLatencyMilliseconds:
          (map['inferenceLatencyMilliseconds'] as num? ?? 0).toInt(),
      model: enumValue(
        MotionfitPoseModel.values,
        map['model'],
        MotionfitPoseModel.lite,
      ),
      videoElapsedUs: (map['videoElapsedUs'] as num?)?.toInt(),
      previewTransform: previewTransform,
      previewHandlesCropAndRotation:
          map['previewHandlesCropAndRotation'] as bool? ?? true,
    );
  }
}

class MotionfitVideoRecordingStart {
  const MotionfitVideoRecordingStart({required this.timelineOriginUs});

  final int timelineOriginUs;
}

class MotionfitVideoRecordingResult {
  const MotionfitVideoRecordingResult({
    required this.path,
    required this.durationMilliseconds,
  });

  final String path;
  final int durationMilliseconds;
}

/// Live preview handle for the Body Progress still camera.
class MotionfitStillCaptureStart {
  const MotionfitStillCaptureStart({
    required this.textureId,
    required this.previewWidth,
    required this.previewHeight,
    required this.rotationDegrees,
    required this.handlesCropAndRotation,
    required this.mirrored,
  });

  final int textureId;

  /// Size of the preview buffer, before [rotationDegrees] is applied.
  final int previewWidth;
  final int previewHeight;

  /// How far the preview buffer has to be turned to sit upright.
  ///
  /// Only meaningful when [handlesCropAndRotation] is false; otherwise the
  /// platform has already applied it.
  final int rotationDegrees;

  /// True when the platform texture already applies rotation and cropping.
  ///
  /// Flutter's Android `SurfaceProducer` does not always honour CameraX
  /// orientation metadata, and the caller has to rotate the texture itself.
  final bool handlesCropAndRotation;

  /// True when the preview is already horizontally mirrored by the platform.
  final bool mirrored;

  double get previewAspectRatio =>
      previewWidth > 0 && previewHeight > 0
      ? previewWidth / previewHeight
      : 3 / 4;
}

/// A photo written to the private Body Progress directory.
class MotionfitStillPhoto {
  const MotionfitStillPhoto({
    required this.directory,
    required this.fileName,
    required this.width,
    required this.height,
  });

  final String directory;
  final String fileName;
  final int width;
  final int height;
}

class MotionfitPoseException implements Exception {
  const MotionfitPoseException(this.code, this.message, [this.details]);

  final String code;
  final String message;
  final Object? details;

  @override
  String toString() => 'MotionfitPoseException($code, $message)';
}

class MotionfitPose {
  MotionfitPose({MethodChannel? methodChannel, EventChannel? eventChannel})
    : _methodChannel =
          methodChannel ?? const MethodChannel('motionfit_pose/methods'),
      _eventChannel =
          eventChannel ?? const EventChannel('motionfit_pose/events');

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;
  Stream<MotionfitPoseFrame>? _frames;
  int? _textureId;
  bool _recordingSupported = false;

  int? get textureId => _textureId;
  bool get recordingSupported => _recordingSupported;

  Stream<MotionfitPoseFrame> get frames =>
      _frames ??= _eventChannel.receiveBroadcastStream().map(
        (event) =>
            MotionfitPoseFrame.fromMap((event as Map).cast<Object?, Object?>()),
      );

  Future<int> start({
    MotionfitCamera camera = MotionfitCamera.front,
    MotionfitPoseModel model = MotionfitPoseModel.lite,
    MotionfitTrackingProfile trackingProfile = MotionfitTrackingProfile.squat,
    int targetFps = 30,
    bool enableVideoRecording = false,
  }) async {
    try {
      final response = await _methodChannel
          .invokeMapMethod<Object?, Object?>('start', {
            'camera': camera.name,
            'model': model.name,
            'trackingProfile': trackingProfile.name,
            'targetFps': targetFps.clamp(15, 30),
            'enableVideoRecording': enableVideoRecording,
          });
      final textureId = (response?['textureId'] as num?)?.toInt();
      if (textureId == null) {
        throw const MotionfitPoseException(
          'invalid_response',
          'Native pose engine did not return a texture ID.',
        );
      }
      _recordingSupported = response?['recordingSupported'] as bool? ?? false;
      return _textureId = textureId;
    } on PlatformException catch (error) {
      throw MotionfitPoseException(
        error.code,
        error.message ?? 'Native pose engine failed to start.',
        error.details,
      );
    }
  }

  Future<void> pause() => _invokeVoid('pause');

  Future<void> resume() => _invokeVoid('resume');

  Future<void> switchCamera(MotionfitCamera camera) =>
      _invokeVoid('switchCamera', {'camera': camera.name});

  Future<void> setModel(MotionfitPoseModel model) =>
      _invokeVoid('setModel', {'model': model.name});

  Future<void> setTargetFps(int targetFps) =>
      _invokeVoid('setTargetFps', {'targetFps': targetFps.clamp(15, 30)});

  Future<MotionfitVideoRecordingStart> startVideoRecording(
    String sessionId,
  ) async {
    final response = await _invokeMap('startVideoRecording', {
      'sessionId': sessionId,
    });
    final timelineOriginUs = (response['timelineOriginUs'] as num?)?.toInt();
    if (timelineOriginUs == null) {
      throw const MotionfitPoseException(
        'invalid_response',
        'Native pose engine did not return a video timeline origin.',
      );
    }
    return MotionfitVideoRecordingStart(timelineOriginUs: timelineOriginUs);
  }

  Future<MotionfitVideoRecordingResult> stopVideoRecording() async {
    final response = await _invokeMap('stopVideoRecording');
    final path = response['path'] as String?;
    final durationMilliseconds = (response['durationMilliseconds'] as num?)
        ?.toInt();
    if (path == null || durationMilliseconds == null) {
      throw const MotionfitPoseException(
        'invalid_response',
        'Native pose engine did not return a finalized video.',
      );
    }
    return MotionfitVideoRecordingResult(
      path: path,
      durationMilliseconds: durationMilliseconds,
    );
  }

  Future<void> cancelVideoRecording() => _invokeVoid('cancelVideoRecording');

  /// Opens a photo-resolution camera session for Body Progress.
  ///
  /// This is a separate capture session from [start]. The pose engine runs a
  /// low resolution tuned for on-device inference, so the two cannot share one
  /// session and the platform refuses to run both at the same time.
  Future<MotionfitStillCaptureStart> startStillCapture({
    MotionfitCamera camera = MotionfitCamera.front,
  }) async {
    final response = await _invokeMap('startStillCapture', {
      'camera': camera.name,
    });
    final textureId = (response['textureId'] as num?)?.toInt();
    if (textureId == null) {
      throw const MotionfitPoseException(
        'invalid_response',
        'Native still capture did not return a texture ID.',
      );
    }
    return MotionfitStillCaptureStart(
      textureId: textureId,
      previewWidth: (response['previewWidth'] as num? ?? 0).toInt(),
      previewHeight: (response['previewHeight'] as num? ?? 0).toInt(),
      rotationDegrees: (response['rotationDegrees'] as num? ?? 0).toInt(),
      handlesCropAndRotation:
          response['handlesCropAndRotation'] as bool? ?? true,
      mirrored: response['mirrored'] as bool? ?? false,
    );
  }

  Future<MotionfitStillCaptureStart> switchStillCamera(
    MotionfitCamera camera,
  ) async {
    final response = await _invokeMap('switchStillCamera', {
      'camera': camera.name,
    });
    return MotionfitStillCaptureStart(
      textureId: (response['textureId'] as num? ?? 0).toInt(),
      previewWidth: (response['previewWidth'] as num? ?? 0).toInt(),
      previewHeight: (response['previewHeight'] as num? ?? 0).toInt(),
      rotationDegrees: (response['rotationDegrees'] as num? ?? 0).toInt(),
      handlesCropAndRotation:
          response['handlesCropAndRotation'] as bool? ?? true,
      mirrored: response['mirrored'] as bool? ?? false,
    );
  }

  Future<MotionfitStillPhoto> captureStill() async {
    final response = await _invokeMap('captureStill');
    final directory = response['directory'] as String?;
    final fileName = response['fileName'] as String?;
    if (directory == null || fileName == null) {
      throw const MotionfitPoseException(
        'invalid_response',
        'Native still capture did not return a written photo.',
      );
    }
    return MotionfitStillPhoto(
      directory: directory,
      fileName: fileName,
      width: (response['width'] as num? ?? 0).toInt(),
      height: (response['height'] as num? ?? 0).toInt(),
    );
  }

  /// Absolute path of the private directory that holds Body Progress photos.
  Future<String> stillCaptureDirectory() async {
    final response = await _invokeMap('stillCaptureDirectory');
    final directory = response['directory'] as String?;
    if (directory == null) {
      throw const MotionfitPoseException(
        'invalid_response',
        'Native still capture did not return a photo directory.',
      );
    }
    return directory;
  }

  Future<void> stopStillCapture() => _invokeVoid('stopStillCapture');

  /// Saves the next analyzed camera frame of the running workout as a JPEG.
  ///
  /// Body Progress records itself during a workout, and the pose session
  /// already owns the camera, so this reuses the analysis frame instead of
  /// opening a second capture session. The frame is the one calibration
  /// settled on, at the analysis resolution rather than full photo resolution.
  Future<MotionfitStillPhoto> captureWorkoutFrame() async {
    final response = await _invokeMap('captureWorkoutFrame');
    final directory = response['directory'] as String?;
    final fileName = response['fileName'] as String?;
    if (directory == null || fileName == null) {
      throw const MotionfitPoseException(
        'invalid_response',
        'Native pose engine did not return a written frame.',
      );
    }
    return MotionfitStillPhoto(
      directory: directory,
      fileName: fileName,
      width: (response['width'] as num? ?? 0).toInt(),
      height: (response['height'] as num? ?? 0).toInt(),
    );
  }

  Future<void> dispose() async {
    try {
      await _invokeVoid('dispose');
    } finally {
      _textureId = null;
      _recordingSupported = false;
    }
  }

  Future<Map<Object?, Object?>> _invokeMap(
    String method, [
    Object? arguments,
  ]) async {
    try {
      return await _methodChannel.invokeMapMethod<Object?, Object?>(
            method,
            arguments,
          ) ??
          const <Object?, Object?>{};
    } on PlatformException catch (error) {
      throw MotionfitPoseException(
        error.code,
        error.message ?? 'Native pose engine command failed.',
        error.details,
      );
    }
  }

  Future<void> _invokeVoid(String method, [Object? arguments]) async {
    try {
      await _methodChannel.invokeMethod<void>(method, arguments);
    } on PlatformException catch (error) {
      throw MotionfitPoseException(
        error.code,
        error.message ?? 'Native pose engine command failed.',
        error.details,
      );
    }
  }
}
