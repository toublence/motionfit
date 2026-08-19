import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motionfit_squat/core/providers.dart';
import 'package:motionfit_squat/core/reviews/review_prompt_service.dart';
import 'package:motionfit_squat/features/exercise/application/combined_workout_metrics.dart';
import 'package:motionfit_squat/features/settings/application/preferences_controller.dart';
import 'package:package_info_plus/package_info_plus.dart';

final reviewPromptServiceProvider = Provider<ReviewPromptService>((ref) {
  return ReviewPromptService(
    gateway: SystemReviewGateway(),
    analytics: ref.watch(analyticsServiceProvider),
    crashReporting: ref.watch(crashReportingServiceProvider),
    automaticRequestsEnabled: kReleaseMode,
    loadContext: () async {
      final metrics = await ref.read(combinedWorkoutMetricsProvider.future);
      var preferences = ref.read(preferencesControllerProvider);
      if (preferences.completedWorkoutCount != metrics.completedWorkoutCount) {
        await ref
            .read(preferencesControllerProvider.notifier)
            .setCompletedWorkoutCount(metrics.completedWorkoutCount);
        preferences = ref.read(preferencesControllerProvider);
      }
      final packageInfo = await PackageInfo.fromPlatform();
      return ReviewPromptContext(
        validWorkoutCount: metrics.completedWorkoutCount,
        distinctWorkoutDays: metrics.distinctWorkoutDays,
        appVersion: packageInfo.version,
        installedAt: preferences.installedAt,
        legacyReviewRequested: preferences.reviewRequested,
        lastRequestAttemptAt: preferences.lastReviewRequestAttemptAt,
        lastRequestAppVersion: preferences.lastReviewRequestAppVersion,
      );
    },
    markAttempted: (version, attemptedAt) => ref
        .read(preferencesControllerProvider.notifier)
        .markReviewRequestAttempted(version, attemptedAt),
  );
});
