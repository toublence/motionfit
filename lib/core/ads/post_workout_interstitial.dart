import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motionfit_squat/core/providers.dart';
import 'package:motionfit_squat/features/settings/application/preferences_controller.dart';

Future<bool> showPostWorkoutInterstitial(
  WidgetRef ref, {
  required String workoutSessionId,
  bool Function()? isOpportunityValid,
}) async {
  final ads = ref.read(adServiceProvider);
  // This key is supplied only for an already saved, valid completion.
  ads.workoutCompleted(workoutSessionId);
  final count = ads.completedWorkoutCount;
  if (count == null) {
    ads.record('mf2_ad_decision', {
      'ad_format': 'interstitial',
      'ad_placement': 'workout_complete',
      'workout_session_id': workoutSessionId,
      'result': 'skipped',
      'skip_reason': 'workout_metrics_unavailable',
    });
    return false;
  }
  final preferences = ref.read(preferencesControllerProvider);
  final controller = ref.read(preferencesControllerProvider.notifier);
  return ads.showInterstitialIfAvailable(
    lastInterstitialShownAt: preferences.lastInterstitialShownAt,
    completedWorkoutCount: count,
    workoutSessionId: workoutSessionId,
    isOpportunityValid: isOpportunityValid,
    onShown: (at) => unawaited(
      controller
          .markInterstitialShown(shownAt: at)
          .catchError(
            (Object _) => ads.record('mf2_ad_cooldown_persist_failed', {}),
          ),
    ),
  );
}
