import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motionfit_squat/core/ads/ad_service.dart';
import 'package:motionfit_squat/core/ads/post_workout_interstitial.dart';
import 'package:motionfit_squat/core/analytics/analytics_service.dart';
import 'package:motionfit_squat/core/privacy/privacy_consent_service.dart';
import 'package:motionfit_squat/core/providers.dart';
import 'package:motionfit_squat/features/settings/application/preferences_controller.dart';
import 'package:motionfit_squat/features/settings/domain/user_preferences.dart';
import 'support/fakes.dart';

class MemoryPreferencesController extends PreferencesController {
  @override
  UserPreferences build() => UserPreferences.defaults();
  @override
  Future<void> markInterstitialShown({DateTime? shownAt}) async {
    state = state.copyWith(lastInterstitialShownAt: shownAt);
  }
}

void main() {
  testWidgets('preload -> post workout show -> showed -> dismissed -> reload', (
    tester,
  ) async {
    final sdk = FakeSdk()
      ..configure = (ad) => ad.onLoad = () async => ad.callbacks.loaded();
    final service = AdService(
      analytics: AnalyticsService(sink: EventSink()),
      sdk: sdk,
      consent: PrivacyConsentService(backend: FakeConsent()),
      unitResolver: (_) => 'ca-app-pub-3940256099942544/4411468910',
    )..updatePolicyContext(onboardingCompleted: true, completedWorkoutCount: 0);
    await service.initialize();
    await tester.pump();
    expect(sdk.ads.single.loads, 1);
    final cached = sdk.ads.single;
    bool? result;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adServiceProvider.overrideWithValue(service),
          preferencesControllerProvider.overrideWith(
            MemoryPreferencesController.new,
          ),
        ],
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) => TextButton(
              onPressed: () async {
                result = await showPostWorkoutInterstitial(
                  ref,
                  workoutSessionId: 'squat:first',
                );
              },
              child: const Text('Done'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Done'));
    await tester.pump();
    expect(cached.shows, 1);
    expect(service.completedWorkoutCount, 1);
    expect(result, null);
    cached.showCallbacks!.showed();
    expect(service.lastInterstitialShownAt, isNotNull);
    cached.showCallbacks!.dismissed();
    await tester.pump();
    expect(result, true);
    expect(cached.disposals, 1);
    expect(sdk.ads.length, 2);
    expect(sdk.ads.last.loads, 1);
    await tester.pumpWidget(const SizedBox());
    service.dispose();
    await tester.pump();
  });
}
