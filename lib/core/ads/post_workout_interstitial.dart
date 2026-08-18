import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motionfit_squat/core/providers.dart';
import 'package:motionfit_squat/features/exercise/application/combined_workout_metrics.dart';
import 'package:motionfit_squat/features/plank/records/application/records_providers.dart'
    as plank;
import 'package:motionfit_squat/features/pushup/records/application/records_providers.dart'
    as pushup;
import 'package:motionfit_squat/features/records/application/records_providers.dart'
    as squat;
import 'package:motionfit_squat/features/settings/application/preferences_controller.dart';

/// Shows the preloaded interstitial at a completed-workout transition.
///
/// Consent, initialization, and a short on-demand load wait are included so a
/// fast navigation cannot skip an ad that is still being prepared.
Future<bool> showPostWorkoutInterstitial(WidgetRef ref) async {
  ref
    ..invalidate(squat.allSessionsProvider)
    ..invalidate(pushup.allSessionsProvider)
    ..invalidate(plank.allSessionsProvider)
    ..invalidate(combinedWorkoutMetricsProvider);

  final metrics = await ref.read(combinedWorkoutMetricsProvider.future);
  final preferences = ref.read(preferencesControllerProvider);
  final ads = ref.read(adServiceProvider);
  ads.updatePolicyContext(
    onboardingCompleted: preferences.onboardingCompleted,
    completedWorkoutCount: metrics.completedWorkoutCount,
  );

  await ref.read(privacyConsentServiceProvider).requestTrackingAndConsent();
  if (!await ads.initialize()) return false;

  final didShow = await ads.showInterstitialIfAvailable(
    lastInterstitialShownAt: preferences.lastInterstitialShownAt,
    completedWorkoutCount: metrics.completedWorkoutCount,
  );
  if (didShow) {
    await ref
        .read(preferencesControllerProvider.notifier)
        .markInterstitialShown();
  }
  return didShow;
}
