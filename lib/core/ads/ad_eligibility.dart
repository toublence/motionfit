abstract final class AdEligibility {
  // Motion Fit 3 shows the persistent native ad from the first app session.
  static const minimumNativeCompletedWorkouts = 0;
  static const minimumInterstitialCompletedWorkouts = 3;
  static const interstitialCooldown = Duration(minutes: 10);

  static bool canShowNative({required int completedWorkoutCount}) =>
      completedWorkoutCount >= minimumNativeCompletedWorkouts;

  static bool canShowInterstitial({required int completedWorkoutCount}) =>
      completedWorkoutCount >= minimumInterstitialCompletedWorkouts;

  static bool isInterstitialCooldownElapsed({
    required DateTime? lastShownAt,
    required DateTime now,
  }) {
    if (lastShownAt == null) return true;
    final elapsed = now.difference(lastShownAt);
    return !elapsed.isNegative && elapsed >= interstitialCooldown;
  }
}
