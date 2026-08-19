import 'package:flutter_test/flutter_test.dart';
import 'package:motionfit_squat/core/reviews/review_prompt_policy.dart';

void main() {
  final now = DateTime(2026, 8, 4);

  ReviewEligibilityDecision evaluate({
    int workouts = 3,
    String version = '1.0.7',
    String? lastVersion,
    DateTime? lastAttempt,
  }) => ReviewPromptPolicy.evaluate(
    validWorkoutCount: workouts,
    appVersion: version,
    legacyReviewRequested: false,
    lastRequestAppVersion: lastVersion,
    lastRequestAttemptAt: lastAttempt,
    now: now,
  );

  test('first and second valid workouts do not request review', () {
    expect(
      evaluate(workouts: 1),
      ReviewEligibilityDecision.notEnoughValidWorkouts,
    );
    expect(
      evaluate(workouts: 2),
      ReviewEligibilityDecision.notEnoughValidWorkouts,
    );
  });

  test('third valid workout becomes eligible', () {
    expect(evaluate(), ReviewEligibilityDecision.eligible);
  });

  test('review is requested once per version', () {
    expect(
      evaluate(lastVersion: '1.0.7'),
      ReviewEligibilityDecision.alreadyRequestedThisVersion,
    );
  });

  test('review respects the 90 day cooldown across versions', () {
    expect(
      evaluate(
        version: '1.0.8',
        lastVersion: '1.0.7',
        lastAttempt: now.subtract(const Duration(days: 89)),
      ),
      ReviewEligibilityDecision.cooldownNotElapsed,
    );
    expect(
      evaluate(
        version: '1.0.8',
        lastVersion: '1.0.7',
        lastAttempt: now.subtract(const Duration(days: 90)),
      ),
      ReviewEligibilityDecision.eligible,
    );
  });
}
