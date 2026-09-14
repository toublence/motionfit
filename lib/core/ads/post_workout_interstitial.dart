import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motionfit_squat/core/providers.dart';
import 'package:motionfit_squat/features/exercise/application/combined_workout_metrics.dart';
import 'package:motionfit_squat/features/settings/application/preferences_controller.dart';

/// Only an already-ready ad may interrupt a later completion transition.
/// Policy/consent/SDK preparation runs independently in MotionFitApp.
Future<bool> showPostWorkoutInterstitial(WidgetRef ref) async {
  final metrics = ref.read(combinedWorkoutMetricsProvider).value;
  // Unknown counts fail closed: never risk an ad on the first completion.
  if (metrics == null || metrics.completedWorkoutCount < 2) return false;
  final ads = ref.read(adServiceProvider);
  if (!ads.ready) return false;
  final preferences = ref.read(preferencesControllerProvider);
  final controller = ref.read(preferencesControllerProvider.notifier);
  final didShow = await ads.showInterstitialIfAvailable(
    lastInterstitialShownAt: preferences.lastInterstitialShownAt,
    completedWorkoutCount: metrics.completedWorkoutCount,
  );
  if (didShow) {
    // Persist the cooldown without holding up the destination screen.
    unawaited(controller.markInterstitialShown().catchError((Object _) {}));
  }
  return didShow;
}
