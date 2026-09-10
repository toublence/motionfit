import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motionfit_squat/core/permissions/permission_service.dart';
import 'package:motionfit_squat/core/providers.dart';
import 'package:motionfit_squat/features/body_progress/application/body_progress_providers.dart';
import 'package:motionfit_squat/features/body_progress/data/body_progress_camera.dart';
import 'package:motionfit_squat/features/body_progress/domain/body_progress_photo.dart';
import 'package:motionfit_squat/features/settings/application/preferences_controller.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_enums.dart';
import 'package:uuid/uuid.dart';

enum BodyProgressCaptureStatus {
  idle,
  requestingPermission,
  permissionDenied,
  permissionPermanentlyDenied,
  starting,
  ready,
  capturing,
  saved,
  failed,
}

class BodyProgressCaptureState {
  const BodyProgressCaptureState({
    required this.status,
    required this.bodyView,
    required this.camera,
    required this.textureId,
    required this.previewWidth,
    required this.previewHeight,
    required this.rotationDegrees,
    required this.handlesCropAndRotation,
    required this.mirrored,
    required this.ghostPhoto,
    required this.ghostOpacity,
    required this.guidesVisible,
    required this.errorCode,
  });

  factory BodyProgressCaptureState.initial(BodyView bodyView) =>
      BodyProgressCaptureState(
        status: BodyProgressCaptureStatus.idle,
        bodyView: bodyView,
        camera: CameraSelection.front,
        textureId: null,
        previewWidth: 0,
        previewHeight: 0,
        rotationDegrees: 0,
        handlesCropAndRotation: true,
        mirrored: false,
        ghostPhoto: null,
        ghostOpacity: 0.35,
        guidesVisible: true,
        errorCode: null,
      );

  final BodyProgressCaptureStatus status;
  final BodyView bodyView;
  final CameraSelection camera;
  final int? textureId;

  /// Preview buffer size, before [rotationDegrees] is applied.
  final int previewWidth;
  final int previewHeight;

  /// How far the texture has to be turned to sit upright.
  final int rotationDegrees;

  /// True when the platform texture already applies rotation and cropping.
  final bool handlesCropAndRotation;

  /// True when the platform already mirrored the preview.
  final bool mirrored;

  /// True when the preview still needs a horizontal flip in the widget layer.
  ///
  /// Android hands over an unmirrored front-camera stream, so the flip belongs
  /// here; iOS mirrors it on the capture connection and needs none.
  bool get mirrorInFlutter => camera == CameraSelection.front && !mirrored;

  /// Most recent photo of the same view, drawn under the live preview so the
  /// next shot can be framed the same way.
  final BodyProgressPhoto? ghostPhoto;
  final double ghostOpacity;
  final bool guidesVisible;
  final String? errorCode;

  bool get isPreviewLive =>
      textureId != null &&
      (status == BodyProgressCaptureStatus.ready ||
          status == BodyProgressCaptureStatus.capturing ||
          status == BodyProgressCaptureStatus.saved);

  bool get canCapture => status == BodyProgressCaptureStatus.ready;

  BodyProgressCaptureState copyWith({
    BodyProgressCaptureStatus? status,
    BodyView? bodyView,
    CameraSelection? camera,
    int? textureId,
    bool clearTextureId = false,
    int? previewWidth,
    int? previewHeight,
    int? rotationDegrees,
    bool? handlesCropAndRotation,
    bool? mirrored,
    BodyProgressPhoto? ghostPhoto,
    bool clearGhostPhoto = false,
    double? ghostOpacity,
    bool? guidesVisible,
    String? errorCode,
    bool clearErrorCode = false,
  }) => BodyProgressCaptureState(
    status: status ?? this.status,
    bodyView: bodyView ?? this.bodyView,
    camera: camera ?? this.camera,
    textureId: clearTextureId ? null : textureId ?? this.textureId,
    previewWidth: previewWidth ?? this.previewWidth,
    previewHeight: previewHeight ?? this.previewHeight,
    rotationDegrees: rotationDegrees ?? this.rotationDegrees,
    handlesCropAndRotation:
        handlesCropAndRotation ?? this.handlesCropAndRotation,
    mirrored: mirrored ?? this.mirrored,
    ghostPhoto: clearGhostPhoto ? null : ghostPhoto ?? this.ghostPhoto,
    ghostOpacity: ghostOpacity ?? this.ghostOpacity,
    guidesVisible: guidesVisible ?? this.guidesVisible,
    errorCode: clearErrorCode ? null : errorCode ?? this.errorCode,
  );
}

final bodyProgressCaptureControllerProvider =
    NotifierProvider<BodyProgressCaptureController, BodyProgressCaptureState>(
      BodyProgressCaptureController.new,
    );

class BodyProgressCaptureController extends Notifier<BodyProgressCaptureState> {
  static const _uuid = Uuid();

  bool _disposed = false;

  @override
  BodyProgressCaptureState build() {
    ref.onDispose(() {
      _disposed = true;
      unawaited(_camera.stop());
    });
    return BodyProgressCaptureState.initial(BodyView.front);
  }

  BodyProgressCamera get _camera => ref.read(bodyProgressCameraProvider);

  Future<void> open(BodyView bodyView) async {
    state = BodyProgressCaptureState.initial(
      bodyView,
    ).copyWith(camera: ref.read(preferencesControllerProvider).selectedCamera);
    await _loadGhost(bodyView);
    await _ensurePermissionAndStart();
  }

  void setGhostOpacity(double opacity) {
    state = state.copyWith(ghostOpacity: opacity.clamp(0, 0.9).toDouble());
  }

  void toggleGuides() {
    state = state.copyWith(guidesVisible: !state.guidesVisible);
  }

  Future<void> switchCamera() async {
    if (!state.isPreviewLive) return;
    final next = state.camera == CameraSelection.front
        ? CameraSelection.back
        : CameraSelection.front;
    try {
      final preview = await _camera.switchCamera(next);
      if (_disposed) return;
      state = state.copyWith(
        camera: next,
        textureId: preview.textureId,
        previewWidth: preview.width,
        previewHeight: preview.height,
        rotationDegrees: preview.rotationDegrees,
        handlesCropAndRotation: preview.handlesCropAndRotation,
        mirrored: preview.mirrored,
      );
    } on BodyProgressCameraException catch (error) {
      if (_disposed) return;
      state = state.copyWith(errorCode: error.code);
    }
  }

  Future<void> retry() => _ensurePermissionAndStart();

  Future<bool> openSystemSettings() =>
      ref.read(permissionServiceProvider).openSettings();

  /// Captures the frame and stores it as today's representative photo for the
  /// selected view, replacing an earlier photo taken on the same day.
  Future<bool> capture() async {
    if (!state.canCapture) return false;
    state = state.copyWith(
      status: BodyProgressCaptureStatus.capturing,
      clearErrorCode: true,
    );
    try {
      final image = await _camera.capture();
      if (_disposed) return false;
      final now = DateTime.now();
      final photo = BodyProgressPhoto(
        id: _uuid.v4(),
        capturedAt: now,
        capturedOn: BodyProgressPhoto.dayKey(now),
        bodyView: state.bodyView,
        imageFile: image.fileName,
        imageWidth: image.width,
        imageHeight: image.height,
        createdAt: now,
      );
      await ref
          .read(bodyProgressRepositoryProvider)
          .savePhoto(photo, directory: image.file.parent);
      if (_disposed) return false;
      ref.invalidate(bodyProgressPhotosProvider);
      state = state.copyWith(
        status: BodyProgressCaptureStatus.saved,
        ghostPhoto: photo,
      );
      return true;
    } on BodyProgressCameraException catch (error) {
      if (_disposed) return false;
      state = state.copyWith(
        status: BodyProgressCaptureStatus.ready,
        errorCode: error.code,
      );
      return false;
    } on Object catch (error, stackTrace) {
      if (_disposed) return false;
      unawaited(
        ref
            .read(crashReportingServiceProvider)
            .recordNonFatal(error, stackTrace, reason: 'body_progress_capture'),
      );
      state = state.copyWith(
        status: BodyProgressCaptureStatus.ready,
        errorCode: 'capture_failed',
      );
      return false;
    }
  }

  Future<void> close() async {
    await _camera.stop();
    if (_disposed) return;
    state = state.copyWith(
      status: BodyProgressCaptureStatus.idle,
      clearTextureId: true,
    );
  }

  Future<void> _loadGhost(BodyView bodyView) async {
    try {
      final photos = await ref
          .read(bodyProgressRepositoryProvider)
          .loadPhotos(bodyView: bodyView);
      if (_disposed) return;
      state = state.copyWith(
        ghostPhoto: photos.isEmpty ? null : photos.last,
        clearGhostPhoto: photos.isEmpty,
      );
    } on Object {
      // A missing reference photo only removes the overlay, never the capture.
    }
  }

  Future<void> _ensurePermissionAndStart() async {
    state = state.copyWith(
      status: BodyProgressCaptureStatus.requestingPermission,
      clearErrorCode: true,
    );
    final permissions = ref.read(permissionServiceProvider);
    AppPermissionState permission;
    try {
      permission = await permissions.cameraStatus();
      if (permission != AppPermissionState.granted) {
        permission = await permissions.requestCamera();
      }
    } on Object {
      if (_disposed) return;
      state = state.copyWith(
        status: BodyProgressCaptureStatus.failed,
        errorCode: 'permission_unavailable',
      );
      return;
    }
    if (_disposed) return;
    switch (permission) {
      case AppPermissionState.granted:
        await _startPreview();
      case AppPermissionState.permanentlyDenied:
      case AppPermissionState.restricted:
        state = state.copyWith(
          status: BodyProgressCaptureStatus.permissionPermanentlyDenied,
        );
      case AppPermissionState.denied:
        state = state.copyWith(
          status: BodyProgressCaptureStatus.permissionDenied,
        );
    }
  }

  Future<void> _startPreview() async {
    state = state.copyWith(
      status: BodyProgressCaptureStatus.starting,
      clearErrorCode: true,
    );
    try {
      final preview = await _camera.start(state.camera);
      if (_disposed) return;
      state = state.copyWith(
        status: BodyProgressCaptureStatus.ready,
        textureId: preview.textureId,
        previewWidth: preview.width,
        previewHeight: preview.height,
        rotationDegrees: preview.rotationDegrees,
        handlesCropAndRotation: preview.handlesCropAndRotation,
        mirrored: preview.mirrored,
      );
    } on BodyProgressCameraException catch (error) {
      if (_disposed) return;
      state = state.copyWith(
        status: BodyProgressCaptureStatus.failed,
        errorCode: error.code,
        clearTextureId: true,
      );
    }
  }
}
