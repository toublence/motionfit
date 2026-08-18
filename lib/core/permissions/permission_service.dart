import 'dart:async';

import 'package:permission_handler/permission_handler.dart';
import 'package:motionfit_squat/core/diagnostics/crash_reporting_service.dart';

enum AppPermissionState { granted, denied, permanentlyDenied, restricted }

class PermissionService {
  const PermissionService(this._crashReporting);

  final CrashReportingService _crashReporting;

  Future<AppPermissionState> cameraStatus() async {
    try {
      return _map(await Permission.camera.status);
    } on Object catch (error, stackTrace) {
      unawaited(
        _crashReporting.recordNonFatal(
          error,
          stackTrace,
          reason: 'camera_permission_status',
        ),
      );
      rethrow;
    }
  }

  Future<AppPermissionState> requestCamera() async {
    try {
      final result = _map(await Permission.camera.request());
      unawaited(
        _crashReporting.setCustomKey(
          'camera_state',
          'permission_${result.name}',
        ),
      );
      unawaited(_crashReporting.log('camera_permission_result'));
      return result;
    } on Object catch (error, stackTrace) {
      unawaited(
        _crashReporting.recordNonFatal(
          error,
          stackTrace,
          reason: 'camera_permission_request',
        ),
      );
      rethrow;
    }
  }

  Future<bool> openSettings() => openAppSettings();

  AppPermissionState _map(PermissionStatus status) {
    if (status.isGranted || status.isLimited) {
      return AppPermissionState.granted;
    }
    if (status.isPermanentlyDenied) {
      return AppPermissionState.permanentlyDenied;
    }
    if (status.isRestricted) return AppPermissionState.restricted;
    return AppPermissionState.denied;
  }
}
