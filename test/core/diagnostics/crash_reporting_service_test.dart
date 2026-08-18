import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motionfit_squat/core/diagnostics/crash_reporting_service.dart';

void main() {
  test(
    'concurrent initialization runs once and installs diagnostic context',
    () async {
      final backend = _FakeBackend();
      var firebaseInitializations = 0;
      final service = CrashReportingService(
        backend: backend,
        supported: true,
        collectionEnabled: true,
        firebaseInitializer: () async => firebaseInitializations++,
        appInfoLoader: () async => const CrashAppInfo(
          version: '1.0.6',
          buildNumber: '6',
          applicationId: 'nam.memento.app',
        ),
      );

      final results = await Future.wait([
        service.initialize(),
        service.initialize(),
      ]);

      expect(results, everyElement(isTrue));
      expect(firebaseInitializations, 1);
      expect(backend.collectionChanges, [true]);
      expect(backend.keys['app_version'], '1.0.6');
      expect(backend.keys['build_number'], '6');
      expect(backend.keys['application_id'], 'nam.memento.app');
      expect(backend.keys['build_identifier'], 'nam.memento.app:1.0.6+6');
      expect(
        backend.keys.keys,
        containsAll(<String>[
          'platform',
          'device_category',
          'current_screen',
          'camera_state',
          'workout_state',
          'ad_state',
          'notification_state',
          'challenge_state',
        ]),
      );
      expect(backend.logs, containsAll(['app_start', 'firebase_initialized']));
    },
  );

  test(
    'Firebase initialization failure never prevents app continuation',
    () async {
      final backend = _FakeBackend();
      var attempts = 0;
      final service = CrashReportingService(
        backend: backend,
        supported: true,
        firebaseInitializer: () async {
          attempts++;
          throw StateError('Firebase unavailable');
        },
      );

      expect(await service.initialize(), isFalse);
      expect(await service.initialize(), isFalse);
      await service.recordNonFatal(
        StateError('feature error'),
        StackTrace.current,
      );

      expect(attempts, 1);
      expect(service.isAvailable, isFalse);
      expect(backend.errors, isEmpty);
    },
  );
}

class _FakeBackend implements CrashReportingBackend {
  final collectionChanges = <bool>[];
  final errors = <Object>[];
  final keys = <String, Object>{};
  final logs = <String>[];

  @override
  Future<void> log(String message) async => logs.add(message);

  @override
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    required bool fatal,
    String? reason,
  }) async => errors.add(error);

  @override
  Future<void> recordFlutterFatalError(FlutterErrorDetails details) async =>
      errors.add(details.exception);

  @override
  Future<void> setCollectionEnabled(bool enabled) async =>
      collectionChanges.add(enabled);

  @override
  Future<void> setCustomKey(String key, Object value) async =>
      keys[key] = value;
}
