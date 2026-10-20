import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:motionfit_squat/core/ads/ad_service.dart';
import 'package:motionfit_squat/core/ads/ad_unit_ids.dart';
import 'package:motionfit_squat/core/ads/post_workout_interstitial.dart';
import 'package:motionfit_squat/core/analytics/analytics_service.dart';
import 'package:motionfit_squat/core/providers.dart';
import 'package:motionfit_squat/features/settings/data/preferences_service.dart';
import 'package:motionfit_squat/features/settings/domain/user_preferences.dart';

import '../benchmark/ios/evaluate_replays.dart' as replay;
import 'ads_sdk_smoke_test.dart' as sdk_tests;

// Run only in the separate fit.motionfit.app.adsvalidation application.
// Video data was inferred on the iPad, then transferred into this test host.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late String documents;
  List<dynamic>? videoCases;
  testWidgets(
    'real video landmarks pass through production detectors on iOS',
    (tester) async {
      expect(defaultTargetPlatform, TargetPlatform.iOS);
      final response = await const MethodChannel(
        'motionfit_pose/methods',
      ).invokeMapMethod<String, Object?>('stillCaptureDirectory');
      final support = response!['directory'] as String;
      final container = support.substring(0, support.lastIndexOf('/Library/'));
      documents = '$container/Documents';
      final input = Directory('$documents/VideoReplays');
      // Allows the host to copy evidence after the isolated app is installed.
      for (var second = 0; second < 120; second++) {
        if (File('${input.path}/squat_fast_10.json.gz').existsSync()) break;
        if (second == 0) debugPrint('WAITING_FOR_VIDEO_REPLAYS ${input.path}');
        await tester.pump(const Duration(seconds: 1));
      }
      expect(
        input.existsSync(),
        true,
        reason: 'Native iPad evidence not copied',
      );
      replay.main([input.path, '$documents/ios_detector_results.json']);
      final result =
          jsonDecode(
                File('$documents/ios_detector_results.json').readAsStringSync(),
              )
              as Map;
      videoCases = result['cases'] as List;
      expect(videoCases!.length, 6);
      expect(videoCases!.every((c) => c['nonIncreasingTimestamps'] == 0), true);
      expect(videoCases!.every((c) => c['nonFiniteLandmarkValues'] == 0), true);
      // These assertions validate data processing, not exercise accuracy.
      // checks.json separately records the actual failed recognition scenarios.
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );

  sdk_tests.registerAdSdkSmokeTests(includeInterstitial: false);

  testWidgets(
    'video completion reaches real iOS post-workout ad and cooldown',
    (tester) async {
      final actual = videoCases!.singleWhere((c) => c['id'] == 'squat_fast_10');
      expect(actual['calibrated'], true);
      expect(actual['count'], 10);
      final sink = _Events();
      final ads = AdService(
        analytics: AnalyticsService(sink: sink),
        unitResolver: (format) => MotionFitAdUnits.resolve(
          format,
          platform: TargetPlatform.iOS,
          isWeb: false,
          useTestAds: true,
        ),
      );
      addTearDown(() {
        File('$documents/ios_ads_trace.json').writeAsStringSync(
          const JsonEncoder.withIndent('  ').convert(sink.events),
        );
        ads.dispose();
      });
      // One historical completion is an explicit test fixture. The second
      // completion comes from the real ten-repetition video result above.
      ads.updatePolicyContext(
        onboardingCompleted: true,
        completedWorkoutCount: 1,
        completedSessionIds: {'squat:prior_saved_fixture'},
      );
      expect(await ads.initialize(), true);
      for (var second = 0; second < 45; second++) {
        if (sink.has('mf2_ad_load_result', result: 'loaded')) break;
        await tester.pump(const Duration(seconds: 1));
      }
      expect(sink.has('mf2_ad_load_result', result: 'loaded'), true);
      expect(
        await ads.showInterstitialIfAvailable(
          lastInterstitialShownAt: null,
          completedWorkoutCount: 0,
        ),
        false,
      );
      expect(
        sink.has('mf2_ad_decision', skipReason: 'no_completed_workout'),
        true,
      );
      final preferences = PreferencesService();
      final initial = UserPreferences.defaults().copyWith(
        onboardingCompleted: true,
      );
      WidgetRef? hostRef;
      var finished = false;
      bool? displayed;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adServiceProvider.overrideWithValue(ads),
            initialPreferencesProvider.overrideWithValue(initial),
            preferencesServiceProvider.overrideWithValue(preferences),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  hostRef = ref;
                  return TextButton(
                    onPressed: () async {
                      displayed = await showPostWorkoutInterstitial(
                        ref,
                        workoutSessionId: 'squat:squat_fast_10',
                        isOpportunityValid: () => context.mounted,
                      );
                      finished = true;
                    },
                    child: const Text('Complete verified 10-repetition video'),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Complete verified 10-repetition video'));
      for (var second = 0; second < 120 && !finished; second++) {
        await tester.pump(const Duration(seconds: 1));
      }
      expect(
        finished,
        true,
        reason: 'Close the official test ad to verify dismissal',
      );
      expect(displayed, true);
      expect(sink.has('mf2_ad_show_result', result: 'showed'), true);
      expect(sink.has('mf2_ad_impression_callback'), true);
      await tester.pump(const Duration(seconds: 1));
      expect((await preferences.load()).lastInterstitialShownAt, isNotNull);
      expect(
        await showPostWorkoutInterstitial(
          hostRef!,
          workoutSessionId: 'squat:squat_fast_10',
        ),
        false,
      );
      expect(
        sink.has('mf2_ad_decision', skipReason: 'workout_already_monetized'),
        true,
      );
      expect(
        sink.events.where((e) => e['name'] == 'mf2_ad_show_attempted').length,
        1,
      );
      File('$documents/ios_video_ad_completion.json').writeAsStringSync(
        jsonEncode({
          'video': actual['id'],
          'detected_repetitions': actual['count'],
          'prior_completion_fixture': 1,
          'showed': displayed,
          'impression_callback': true,
          'dismissed': finished,
          'cooldown_persisted': true,
          'duplicate_show_calls': 0,
          'full_workout_repository_ui_test': false,
        }),
      );
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    },
    timeout: const Timeout(Duration(minutes: 4)),
  );
}

class _Events implements AnalyticsSink {
  final events = <Map<String, Object>>[];
  bool has(String name, {String? result, String? skipReason}) => events.any(
    (e) =>
        e['name'] == name &&
        (result == null || e['result'] == result) &&
        (skipReason == null || e['skip_reason'] == skipReason),
  );
  @override
  Future<void> logEvent(String name, Map<String, Object> parameters) async {
    events.add({'name': name, ...parameters});
    debugPrint('IOS_VIDEO_AD $name $parameters');
  }

  @override
  Future<void> logScreenView(String name) async {}
}
