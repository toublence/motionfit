abstract final class AdEligibility {
  // Keep the first three workouts focused on habit formation.
  static const minimumNativeCompletedWorkouts = 3;
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
