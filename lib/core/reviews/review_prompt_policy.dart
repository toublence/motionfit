enum ReviewEligibilityDecision {
  eligible,
  notEnoughValidWorkouts,
  notEnoughWorkoutDays,
  alreadyRequestedThisVersion,
  cooldownNotElapsed,
  legacyRequestNeedsMigration,
}

abstract final class ReviewPromptPolicy {
  static const minimumValidWorkouts = 3;
  static const minimumDistinctWorkoutDays = 2;
  static const cooldown = Duration(days: 120);

  static ReviewEligibilityDecision evaluate({
    required int validWorkoutCount,
    required int distinctWorkoutDays,
    required String appVersion,
    required bool legacyReviewRequested,
    required String? lastRequestAppVersion,
    required DateTime? lastRequestAttemptAt,
    required DateTime now,
  }) {
    if (validWorkoutCount < minimumValidWorkouts) {
      return ReviewEligibilityDecision.notEnoughValidWorkouts;
    }
    if (distinctWorkoutDays < minimumDistinctWorkoutDays) {
      return ReviewEligibilityDecision.notEnoughWorkoutDays;
    }
    if (lastRequestAppVersion == appVersion) {
      return ReviewEligibilityDecision.alreadyRequestedThisVersion;
    }
    if (lastRequestAttemptAt != null &&
        now.difference(lastRequestAttemptAt) < cooldown) {
      return ReviewEligibilityDecision.cooldownNotElapsed;
    }
    if (legacyReviewRequested &&
        lastRequestAppVersion == null &&
        lastRequestAttemptAt == null) {
      return ReviewEligibilityDecision.legacyRequestNeedsMigration;
    }
    return ReviewEligibilityDecision.eligible;
  }
}
