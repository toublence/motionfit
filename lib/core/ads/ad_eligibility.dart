abstract final class AdEligibility {
  // Business settings, not platform-mandated time limits. Fullscreen ads stay
  // at natural breaks; app-open uses real app entries rather than workout DB.
  static const policyVersion = 'revenue_v1';
  static const minimumAppOpenVisits = 3;
  static bool canShowAppOpen({required int appEntryCount}) =>
      appEntryCount >= minimumAppOpenVisits;

  static const minimumBannerCompletedWorkouts = 0;
  static const minimumNativeCompletedWorkouts = 0;
  static const minimumInterstitialCompletedWorkouts = 1;
  static const interstitialCooldown = Duration(seconds: 120);

  static bool canShowBanner({required int completedWorkoutCount}) =>
      completedWorkoutCount >= minimumBannerCompletedWorkouts;

  static bool canShowNative({required int completedWorkoutCount}) =>
      completedWorkoutCount >= minimumNativeCompletedWorkouts;

  static bool canPreloadInterstitial({required int completedWorkoutCount}) =>
      completedWorkoutCount >= minimumInterstitialCompletedWorkouts - 1;

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
