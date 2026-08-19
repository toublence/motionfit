enum ReviewEligibilityDecision {
  eligible,
  notEnoughValidWorkouts,
  alreadyRequestedThisVersion,
  cooldownNotElapsed,
  legacyRequestNeedsMigration,
}

abstract final class ReviewPromptPolicy {
  static const minimumValidWorkouts = 3;
  static const cooldown = Duration(days: 90);

  static ReviewEligibilityDecision evaluate({
    required int validWorkoutCount,
    required String appVersion,
    required bool legacyReviewRequested,
    required String? lastRequestAppVersion,
    required DateTime? lastRequestAttemptAt,
    required DateTime now,
  }) {
    if (validWorkoutCount < minimumValidWorkouts) {
      return ReviewEligibilityDecision.notEnoughValidWorkouts;
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
