import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

abstract interface class CrashReportingBackend {
  Future<void> setCollectionEnabled(bool enabled);

  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    required bool fatal,
    String? reason,
  });

  Future<void> recordFlutterFatalError(FlutterErrorDetails details);

  Future<void> setCustomKey(String key, Object value);

  Future<void> log(String message);
}

class FirebaseCrashReportingBackend implements CrashReportingBackend {
  FirebaseCrashlytics get _instance => FirebaseCrashlytics.instance;

  @override
  Future<void> setCollectionEnabled(bool enabled) =>
      _instance.setCrashlyticsCollectionEnabled(enabled);

  @override
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    required bool fatal,
    String? reason,
  }) => _instance.recordError(
    error,
    stackTrace,
    fatal: fatal,
    reason: reason,
    printDetails: false,
  );

  @override
  Future<void> recordFlutterFatalError(FlutterErrorDetails details) =>
      _instance.recordFlutterFatalError(details);

  @override
  Future<void> setCustomKey(String key, Object value) =>
      _instance.setCustomKey(key, value);

  @override
  Future<void> log(String message) => _instance.log(message);
}

class CrashAppInfo {
  const CrashAppInfo({
    required this.version,
    required this.buildNumber,
    this.applicationId = 'unknown',
  });

  final String version;
  final String buildNumber;
  final String applicationId;
}

class CrashReportingService {
  CrashReportingService({
    CrashReportingBackend? backend,
    Future<void> Function()? firebaseInitializer,
    Future<CrashAppInfo> Function()? appInfoLoader,
    bool? collectionEnabled,
    bool? supported,
  }) : _backend = backend ?? FirebaseCrashReportingBackend(),
       _firebaseInitializer = firebaseInitializer ?? _initializeFirebase,
       _appInfoLoader = appInfoLoader ?? _loadAppInfo,
       _collectionEnabled = collectionEnabled ?? !kDebugMode,
       _supported = supported ?? _isSupportedPlatform;

  final CrashReportingBackend _backend;
  final Future<void> Function() _firebaseInitializer;
  final Future<CrashAppInfo> Function() _appInfoLoader;
  final bool _collectionEnabled;
  final bool _supported;

  Future<bool>? _initialization;
  bool _available = false;

  bool get isAvailable => _available;
  bool get collectionEnabled => _available && _collectionEnabled;

  Future<bool> initialize() {
    final pending = _initialization;
    if (pending != null) return pending;
    final operation = _initialize();
    _initialization = operation;
    return operation;
  }

  Future<bool> _initialize() async {
    if (!_supported) return false;
    try {
      await _firebaseInitializer();
      await _backend.setCollectionEnabled(_collectionEnabled);
      _available = true;

      CrashAppInfo appInfo;
      try {
        appInfo = await _appInfoLoader();
      } on Object catch (error, stackTrace) {
        appInfo = const CrashAppInfo(
          version: 'unknown',
          buildNumber: 'unknown',
        );
        await _recordSafely(
          error,
          stackTrace,
          fatal: false,
          reason: 'package_info_initialization',
        );
      }

      final initialKeys = <String, Object>{
        'app_version': appInfo.version,
        'build_number': appInfo.buildNumber,
        'application_id': appInfo.applicationId,
        'build_identifier':
            '${appInfo.applicationId}:${appInfo.version}+${appInfo.buildNumber}',
        'platform': _platformName,
        'device_category': _deviceCategory,
        'current_screen': 'startup',
        'camera_state': 'idle',
        'workout_state': 'idle',
        'ad_state': 'idle',
        'notification_state': 'idle',
        'challenge_state': 'idle',
      };
      for (final entry in initialKeys.entries) {
        await _setCustomKeySafely(entry.key, entry.value);
      }
      await _logSafely('app_start');
      await _logSafely('firebase_initialized');
      return true;
    } on Object catch (error, stackTrace) {
      _available = false;
      debugPrint('[Crashlytics] initialization failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }

  Future<void> recordFlutterFatalError(FlutterErrorDetails details) async {
    if (!_available) {
      FlutterError.presentError(details);
      return;
    }
    try {
      await _backend.recordFlutterFatalError(details);
    } on Object catch (error, stackTrace) {
      debugPrint('[Crashlytics] Flutter error recording failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    required bool fatal,
    String? reason,
  }) => _recordSafely(error, stackTrace, fatal: fatal, reason: reason);

  Future<void> recordNonFatal(
    Object error,
    StackTrace stackTrace, {
    String? reason,
  }) => _recordSafely(error, stackTrace, fatal: false, reason: reason);

  Future<void> _recordSafely(
    Object error,
    StackTrace stackTrace, {
    required bool fatal,
    String? reason,
  }) async {
    if (!_available) return;
    try {
      await _backend.recordError(
        error,
        stackTrace,
        fatal: fatal,
        reason: reason,
      );
    } on Object catch (recordingError, recordingStackTrace) {
      debugPrint('[Crashlytics] error recording failed: $recordingError');
      debugPrintStack(stackTrace: recordingStackTrace);
    }
  }

  Future<void> setCustomKey(String key, Object value) =>
      _setCustomKeySafely(key, value);

  Future<void> _setCustomKeySafely(String key, Object value) async {
    if (!_available) return;
    try {
      await _backend.setCustomKey(key, value);
    } on Object catch (error, stackTrace) {
      debugPrint('[Crashlytics] custom key failed: $key: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> log(String message) => _logSafely(message);

  Future<void> _logSafely(String message) async {
    if (!_available) return;
    try {
      await _backend.log(message);
    } on Object catch (error, stackTrace) {
      debugPrint('[Crashlytics] log failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  static Future<void> _initializeFirebase() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  }

  static Future<CrashAppInfo> _loadAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    return CrashAppInfo(
      version: info.version,
      buildNumber: info.buildNumber,
      applicationId: info.packageName,
    );
  }

  static bool get _isSupportedPlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static String get _platformName => switch (defaultTargetPlatform) {
    TargetPlatform.android => 'android',
    TargetPlatform.iOS => 'ios',
    TargetPlatform.macOS => 'macos',
    TargetPlatform.windows => 'windows',
    TargetPlatform.linux => 'linux',
    TargetPlatform.fuchsia => 'fuchsia',
  };

  static String get _deviceCategory {
    final views = PlatformDispatcher.instance.views;
    if (views.isEmpty) return 'unknown';
    final view = views.first;
    final shortestSide = view.physicalSize.shortestSide / view.devicePixelRatio;
    return shortestSide >= 600 ? 'tablet' : 'phone';
  }
}
