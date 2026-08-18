import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motionfit_squat/core/ads/ad_service.dart';
import 'package:motionfit_squat/core/analytics/analytics_service.dart';
import 'package:motionfit_squat/core/database/app_database.dart';
import 'package:motionfit_squat/core/diagnostics/crash_reporting_service.dart';
import 'package:motionfit_squat/core/notifications/notification_service.dart';
import 'package:motionfit_squat/core/permissions/permission_service.dart';
import 'package:motionfit_squat/core/privacy/privacy_consent_service.dart';
import 'package:motionfit_squat/features/challenges/data/challenge_repository.dart';
import 'package:motionfit_squat/features/settings/data/preferences_service.dart';
import 'package:motionfit_squat/features/settings/domain/user_preferences.dart';
import 'package:motionfit_squat/features/squat/domain/services/workout_repository.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw StateError('AppDatabase was not initialized.');
});

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  throw StateError('WorkoutRepository was not initialized.');
});

final challengeRepositoryProvider = Provider<ChallengeRepository>((ref) {
  return ChallengeRepository(
    ref.watch(appDatabaseProvider),
    onError: (error, stackTrace, reason) {
      ref
          .read(crashReportingServiceProvider)
          .recordNonFatal(error, stackTrace, reason: reason);
    },
  );
});

final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  throw StateError('PreferencesService was not initialized.');
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  throw StateError('NotificationService was not initialized.');
});

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService(ref.watch(crashReportingServiceProvider));
});

final privacyConsentServiceProvider = Provider<PrivacyConsentService>((ref) {
  return PrivacyConsentService(ref.watch(crashReportingServiceProvider));
});

final crashReportingServiceProvider = Provider<CrashReportingService>((ref) {
  throw StateError('CrashReportingService was not initialized.');
});

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

final adServiceProvider = Provider<AdService>((ref) {
  final service = AdService(
    analytics: ref.watch(analyticsServiceProvider),
    crashReporting: ref.watch(crashReportingServiceProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

final initialPreferencesProvider = Provider<UserPreferences>((ref) {
  throw StateError('UserPreferences were not initialized.');
});
