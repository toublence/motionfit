import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motionfit_squat/app/app.dart';
import 'package:motionfit_squat/core/analytics/analytics_service.dart';
import 'package:motionfit_squat/core/database/app_database.dart';
import 'package:motionfit_squat/core/diagnostics/crash_reporting_service.dart';
import 'package:motionfit_squat/core/migration/legacy_capacitor_migration.dart';
import 'package:motionfit_squat/core/notifications/notification_service.dart';
import 'package:motionfit_squat/core/providers.dart';
import 'package:motionfit_squat/features/settings/data/preferences_service.dart';
import 'package:motionfit_squat/features/settings/domain/user_preferences.dart';
import 'package:motionfit_squat/features/plank/providers.dart'
    as plank_providers;
import 'package:motionfit_squat/features/plank/workout/data/sqlite_workout_repository.dart'
    as plank_data;
import 'package:motionfit_squat/features/pushup/data/sqlite_workout_repository.dart'
    as pushup_data;
import 'package:motionfit_squat/features/pushup/providers.dart'
    as pushup_providers;
import 'package:motionfit_squat/features/squat/data/sqlite_workout_repository.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

Future<void> main() async {
  final crashReporting = CrashReportingService();
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      if (Platform.isAndroid || Platform.isIOS) {
        await Firebase.initializeApp();
      }
      await crashReporting.initialize();
      _registerGlobalErrorHandlers(crashReporting);
      await _startApp(crashReporting);
    },
    (error, stackTrace) {
      unawaited(
        crashReporting.recordError(
          error,
          stackTrace,
          fatal: true,
          reason: 'runZonedGuarded',
        ),
      );
    },
  );
}

void _registerGlobalErrorHandlers(CrashReportingService crashReporting) {
  FlutterError.onError = (details) {
    unawaited(crashReporting.recordFlutterFatalError(details));
  };
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    unawaited(
      crashReporting.recordError(
        error,
        stackTrace,
        fatal: true,
        reason: 'PlatformDispatcher.onError',
      ),
    );
    return true;
  };
}

Future<void> _startApp(CrashReportingService crashReporting) async {
  final preferencesService = PreferencesService();
  try {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    if (Platform.isAndroid) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  } on Object catch (error, stackTrace) {
    await crashReporting.recordNonFatal(
      error,
      stackTrace,
      reason: 'preferred_orientation_initialization',
    );
  }

  final databaseDirectory = await getDatabasesPath();
  final database = AppDatabase(path: p.join(databaseDirectory, 'motionfit.db'));
  final pushupDatabase = AppDatabase(
    path: p.join(databaseDirectory, 'motionfit_pushup.db'),
  );
  final plankDatabase = AppDatabase(
    path: p.join(databaseDirectory, 'motionfit_plank.db'),
  );
  final repository = SqliteWorkoutRepository(
    database,
    onError: (error, stackTrace, reason) {
      unawaited(
        crashReporting.recordNonFatal(error, stackTrace, reason: reason),
      );
    },
  );
  final pushupRepository = pushup_data.SqliteWorkoutRepository(
    pushupDatabase,
    onError: (error, stackTrace, reason) {
      unawaited(
        crashReporting.recordNonFatal(error, stackTrace, reason: reason),
      );
    },
  );
  final plankRepository = plank_data.SqliteWorkoutRepository(
    plankDatabase,
    onError: (error, stackTrace, reason) {
      unawaited(
        crashReporting.recordNonFatal(error, stackTrace, reason: reason),
      );
    },
  );
  final notificationService = NotificationService(
    crashReporting: crashReporting,
  );
  try {
    await LegacyCapacitorMigration(
      squatDatabase: database,
      pushupDatabase: pushupDatabase,
      plankDatabase: plankDatabase,
      preferencesService: preferencesService,
      notificationService: notificationService,
    ).run();
  } on Object catch (error, stackTrace) {
    // Do not mark or delete the legacy data on failure. A later launch retries
    // the idempotent import while the app remains usable with current storage.
    await crashReporting.recordNonFatal(
      error,
      stackTrace,
      reason: 'legacy_capacitor_migration',
    );
  }
  final analyticsService = AnalyticsService(crashReporting: crashReporting);
  final preferences = await _loadPreferencesSafely(
    preferencesService,
    crashReporting,
  );
  await analyticsService.initialize();
  await analyticsService.appOpened(
    source: 'flutter_bootstrap',
    initialPath: '/',
  );

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        workoutRepositoryProvider.overrideWithValue(repository),
        pushup_providers.appDatabaseProvider.overrideWithValue(pushupDatabase),
        pushup_providers.workoutRepositoryProvider.overrideWithValue(
          pushupRepository,
        ),
        plank_providers.appDatabaseProvider.overrideWithValue(plankDatabase),
        plank_providers.workoutRepositoryProvider.overrideWithValue(
          plankRepository,
        ),
        preferencesServiceProvider.overrideWithValue(preferencesService),
        notificationServiceProvider.overrideWithValue(notificationService),
        analyticsServiceProvider.overrideWithValue(analyticsService),
        crashReportingServiceProvider.overrideWithValue(crashReporting),
        initialPreferencesProvider.overrideWithValue(preferences),
      ],
      child: const MotionFitApp(),
    ),
  );
}

Future<UserPreferences> _loadPreferencesSafely(
  PreferencesService service,
  CrashReportingService crashReporting,
) async {
  try {
    return await service.load();
  } on Object catch (error, stackTrace) {
    await crashReporting.recordNonFatal(
      error,
      stackTrace,
      reason: 'preferences_initialization',
    );
    return UserPreferences.defaults();
  }
}
