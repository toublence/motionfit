import 'dart:async';
import '../../features/exercise/application/combined_workout_metrics.dart';
import 'ad_service.dart';

Future<void> prepareAds(
  AdService ads, {
  required bool onboardingCompleted,
  required Future<CombinedWorkoutMetrics> Function() readMetrics,
  required bool Function() isMounted,
}) async {
  ads.updateOnboardingContext(onboardingCompleted);
  if (!onboardingCompleted) return;
  // SDK/consent work starts independently even if the DB never answers.
  unawaited(ads.initialize());
  try {
    final metrics = await readMetrics();
    if (!isMounted()) return;
    ads.updatePolicyContext(
      onboardingCompleted: onboardingCompleted,
      completedWorkoutCount: metrics.completedWorkoutCount,
      completedSessionIds: metrics.completedSessionIds,
    );
  } on Object {
    if (!isMounted()) return;
    ads.record('mf2_ad_decision', {
      'result': 'skipped',
      'skip_reason': 'workout_metrics_unavailable',
      'ad_format': 'interstitial',
      'ad_placement': 'app_initialization',
    });
  }
}
