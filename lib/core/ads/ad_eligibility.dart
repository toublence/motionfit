abstract final class AdEligibility {
  // Primary-screen native ads are available after onboarding. Interstitials
  // become eligible after the user's first completed workout.
  static const minimumNativeCompletedWorkouts = 0;
  static const minimumInterstitialCompletedWorkouts = 1;
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
