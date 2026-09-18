import 'package:flutter_test/flutter_test.dart';
import 'package:motionfit_squat/core/ads/ad_eligibility.dart';

void main() {
  test('banner and native ads are available while interstitials stay initially gated', () {
    expect(AdEligibility.canShowBanner(completedWorkoutCount: 0), isTrue);
    expect(AdEligibility.canShowNative(completedWorkoutCount: 0), isTrue);
    expect(
      AdEligibility.canShowInterstitial(completedWorkoutCount: 0),
      isFalse,
    );
  });

  test('first workout is protected; interstitials start at the second', () {
    expect(AdEligibility.canShowNative(completedWorkoutCount: 1), isTrue);
    expect(
      AdEligibility.canShowInterstitial(completedWorkoutCount: 0),
      isFalse,
    );
    expect(
      AdEligibility.canShowInterstitial(completedWorkoutCount: 1),
      isFalse,
    );
    expect(AdEligibility.canShowInterstitial(completedWorkoutCount: 2), isTrue);
  });

  test('interstitial cooldown is ten minutes from the last impression', () {
    final lastShownAt = DateTime(2026, 8, 11, 12);

    expect(
      AdEligibility.isInterstitialCooldownElapsed(
        lastShownAt: lastShownAt,
        now: lastShownAt.add(const Duration(minutes: 9, seconds: 59)),
      ),
      isFalse,
    );
    expect(
      AdEligibility.isInterstitialCooldownElapsed(
        lastShownAt: lastShownAt,
        now: lastShownAt.add(const Duration(minutes: 10)),
      ),
      isTrue,
    );
  });
}
