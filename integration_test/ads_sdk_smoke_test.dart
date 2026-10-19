import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:motionfit_squat/core/ads/ad_sdk.dart';
import 'package:motionfit_squat/core/ads/ad_service.dart';
import 'package:motionfit_squat/core/ads/ad_slot.dart';
import 'package:motionfit_squat/core/ads/ad_unit_ids.dart';
import 'package:motionfit_squat/core/analytics/analytics_service.dart';
import 'package:motionfit_squat/core/providers.dart';

// Run in an isolated validation application ID. Never replace an installed
// MotionFit app or its workout data. No Firebase events are sent by this host.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  registerAdSdkSmokeTests();
}

void registerAdSdkSmokeTests({bool includeInterstitial = true}) {
  for (final format in [AdFormat.banner, AdFormat.native]) {
    testWidgets(
      'real Google SDK ${format.name} test ad loads and records an impression',
      (tester) async {
        final sink = _Events();
        final ads = AdService(
          analytics: AnalyticsService(sink: sink),
          unitResolver: (format) => MotionFitAdUnits.resolve(
            format,
            platform: defaultTargetPlatform,
            isWeb: false,
            useTestAds: true,
          ),
        );
        addTearDown(ads.dispose);
        final ready = await ads.initialize();
        expect(
          ready,
          true,
          reason:
              'UMP or SDK did not become ready; network/consent must be checked.',
        );
        await tester.pumpWidget(
          ProviderScope(
            overrides: [adServiceProvider.overrideWithValue(ads)],
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    const Text('MotionFit Ads Validation'),
                    AdSlot(format: format, placement: 'device_validation'),
                  ],
                ),
              ),
            ),
          ),
        );
        for (var second = 0; second < 45; second++) {
          await tester.pump(const Duration(seconds: 1));
          if (sink.has('mf2_ad_impression_callback', format)) break;
        }
        expect(sink.has('mf2_ad_load_result', format, result: 'loaded'), true);
        expect(
          sink.has('mf2_ad_impression_callback', format),
          true,
          reason: 'No real SDK impression within the observation window.',
        );
        await tester.pumpWidget(const SizedBox());
        await tester.pump();
      },
      timeout: const Timeout(Duration(minutes: 3)),
    );
  }
  if (!includeInterstitial) return;
  testWidgets(
    'real Google SDK interstitial shows and dismisses once',
    (tester) async {
      final sink = _Events();
      final ads = AdService(
        analytics: AnalyticsService(sink: sink),
        unitResolver: (format) => MotionFitAdUnits.resolve(
          format,
          platform: defaultTargetPlatform,
          isWeb: false,
          useTestAds: true,
        ),
      );
      addTearDown(ads.dispose);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Text('MotionFit Interstitial Validation')),
        ),
      );
      ads.updatePolicyContext(
        onboardingCompleted: true,
        completedWorkoutCount: 2,
      );
      expect(await ads.initialize(), true);
      for (var second = 0; second < 45; second++) {
        await tester.pump(const Duration(seconds: 1));
        if (sink.has(
          'mf2_ad_load_result',
          AdFormat.interstitial,
          result: 'loaded',
        )) {
          break;
        }
      }
      expect(
        sink.has('mf2_ad_load_result', AdFormat.interstitial, result: 'loaded'),
        true,
      );
      bool? completed;
      ads
          .showInterstitialIfAvailable(
            lastInterstitialShownAt: null,
            completedWorkoutCount: 2,
          )
          .then((value) => completed = value);
      // The operator/ADB test harness closes the official test ad via its
      // visible close control. Never simulate or count a show callback.
      for (var second = 0; second < 90 && completed == null; second++) {
        await tester.pump(const Duration(seconds: 1));
      }
      expect(completed, true);
      expect(
        sink.has('mf2_ad_show_result', AdFormat.interstitial, result: 'showed'),
        true,
      );
      expect(
        sink.has('mf2_ad_impression_callback', AdFormat.interstitial),
        true,
      );
      expect(
        sink.events.where((e) => e.name == 'mf2_ad_show_attempted').length,
        1,
      );
      await tester.pumpWidget(const SizedBox());
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}

class _Events implements AnalyticsSink {
  final events = <({String name, Map<String, Object> fields})>[];
  bool has(String name, AdFormat format, {String? result}) => events.any(
    (e) =>
        e.name == name &&
        e.fields['ad_format'] == format.name &&
        (result == null || e.fields['result'] == result),
  );
  @override
  Future<void> logEvent(String name, Map<String, Object> parameters) async {
    events.add((name: name, fields: parameters));
    // Device logs retain the actual failure category without sending Firebase.
    // ignore: avoid_print
    print('$name $parameters');
  }

  @override
  Future<void> logScreenView(String name) async {}
}
