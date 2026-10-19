import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motionfit_squat/core/ads/ad_failure.dart';
import 'package:motionfit_squat/core/ads/ad_service.dart';
import 'package:motionfit_squat/core/analytics/analytics_service.dart';
import 'package:motionfit_squat/core/privacy/privacy_consent_service.dart';
import 'support/fakes.dart';

void main() {
  void scenario(
    void Function(FakeAsync, AdService, FakeSdk, EventSink) run, {
    int count = 2,
    bool autoLoad = true,
  }) {
    fakeAsync((time) {
      final sdk = FakeSdk();
      if (autoLoad) {
        sdk.configure = (ad) => ad.onLoad = () async => ad.callbacks.loaded();
      }
      final sink = EventSink();
      final service = AdService(
        analytics: AnalyticsService(sink: sink),
        sdk: sdk,
        consent: PrivacyConsentService(backend: FakeConsent()),
        clock: time.getClock(DateTime(2026, 10, 17)).now,
        unitResolver: (_) => 'ca-app-pub-3940256099942544/1033173712',
      );
      service.updatePolicyContext(
        onboardingCompleted: true,
        completedWorkoutCount: count,
      );
      service.initialize();
      time.flushMicrotasks();
      run(time, service, sdk, sink);
      service.dispose();
      time.flushMicrotasks();
    });
  }

  test(
    'ready eligible opportunity shows exactly once; success is callback based',
    () {
      scenario((time, service, sdk, sink) {
        bool? first;
        bool? second;
        var persisted = 0;
        service
            .showInterstitialIfAvailable(
              lastInterstitialShownAt: null,
              completedWorkoutCount: 2,
              onShown: (_) => persisted++,
            )
            .then((r) => first = r);
        service
            .showInterstitialIfAvailable(
              lastInterstitialShownAt: null,
              completedWorkoutCount: 2,
            )
            .then((r) => second = r);
        time.flushMicrotasks();
        final ad = sdk.ads.first;
        expect(ad.shows, 1);
        expect(second, false);
        expect(first, null);
        expect(service.lastInterstitialShownAt, null);
        ad.showCallbacks!.showed();
        ad.showCallbacks!.showed();
        expect(persisted, 1);
        expect(service.lastInterstitialShownAt, isNotNull);
        ad.showCallbacks!.dismissed();
        ad.showCallbacks!.dismissed();
        time.flushMicrotasks();
        expect(first, true);
        expect(ad.disposals, 1);
        expect(service.fullScreenShowing, false);
        expect(
          sink.events.where((e) => e.name == 'mf2_ad_show_attempted').length,
          1,
        );
      });
    },
  );
  test(
    'first completion stays protected while next completion is preloaded',
    () {
      scenario((time, service, sdk, sink) {
        expect(sdk.ads.length, 1);
        bool? result;
        service
            .showInterstitialIfAvailable(
              lastInterstitialShownAt: null,
              completedWorkoutCount: 1,
            )
            .then((r) => result = r);
        time.flushMicrotasks();
        expect(result, false);
        expect(sdk.ads.single.shows, 0);
        expect(
          sink.events.any(
            (e) => e.parameters['skip_reason'] == 'first_workout_protected',
          ),
          true,
        );
      }, count: 1);
    },
  );
  test('saved completion snapshot is reconciled without double counting', () {
    scenario((time, service, sdk, sink) {
      service.updatePolicyContext(
        onboardingCompleted: true,
        completedWorkoutCount: 1,
        completedSessionIds: {'squat:first'},
      );
      service.workoutCompleted('squat:second');
      service.workoutCompleted('squat:second');
      expect(service.completedWorkoutCount, 2);
      service.updatePolicyContext(
        onboardingCompleted: true,
        completedWorkoutCount: 2,
        completedSessionIds: {'squat:first', 'squat:second'},
      );
      expect(service.completedWorkoutCount, 2);
    }, count: 1);
  });
  test('55 minute expiry discards old cache and prepares a new ad', () {
    scenario((time, service, sdk, sink) {
      final old = sdk.ads.single;
      time.elapse(AdService.interstitialMaxAge);
      expect(old.disposals, 1);
      expect(sdk.ads.length, 2);
      expect(sink.events.any((e) => e.parameters['reason'] == 'expired'), true);
    });
  });
  for (final mode in ['invocation', 'callback', 'race']) {
    test(
      'show $mode failure completes navigation once and releases ownership',
      () {
        scenario((time, service, sdk, sink) {
          final ad = sdk.ads.first;
          if (mode == 'invocation') {
            ad.onShow = () async => throw StateError('show channel');
          }
          var completions = 0;
          service
              .showInterstitialIfAvailable(
                lastInterstitialShownAt: null,
                completedWorkoutCount: 2,
              )
              .then((r) {
                expect(r, false);
                completions++;
              });
          time.flushMicrotasks();
          if (mode != 'invocation') {
            ad.showCallbacks!.failed(const AdFailure('sdk_error'));
            if (mode == 'race') {
              ad.showCallbacks!.showed();
              ad.showCallbacks!.dismissed();
            }
          }
          time.flushMicrotasks();
          expect(completions, 1);
          expect(service.fullScreenShowing, false);
          expect(service.lastInterstitialShownAt, null);
          expect(ad.disposals, 1);
          expect(sdk.ads.length, 2);
        });
      },
    );
  }
  test('inactive opportunity never invokes show and explains the skip', () {
    scenario((time, service, sdk, sink) {
      service.showInterstitialIfAvailable(
        lastInterstitialShownAt: null,
        completedWorkoutCount: 2,
        isOpportunityValid: () => false,
      );
      time.flushMicrotasks();
      expect(sdk.ads.first.shows, 0);
      expect(
        sink.events.any(
          (e) => e.parameters['skip_reason'] == 'inactive_opportunity',
        ),
        true,
      );
    });
  });
  test('pending load is explained; completion does not cause a late show', () {
    scenario((time, service, sdk, sink) {
      bool? result;
      service
          .showInterstitialIfAvailable(
            lastInterstitialShownAt: null,
            completedWorkoutCount: 2,
          )
          .then((r) => result = r);
      time.flushMicrotasks();
      expect(result, false);
      sdk.ads.single.callbacks.loaded();
      time.flushMicrotasks();
      expect(sdk.ads.single.shows, 0);
      expect(
        sink.events.any((e) => e.parameters['skip_reason'] == 'load_pending'),
        true,
      );
    }, autoLoad: false);
  });
  test('cooldown starts at actual show callback and remains ten minutes', () {
    scenario((time, service, sdk, sink) {
      service.showInterstitialIfAvailable(
        lastInterstitialShownAt: null,
        completedWorkoutCount: 2,
      );
      time.flushMicrotasks();
      final ad = sdk.ads.first;
      ad.showCallbacks!.showed();
      ad.showCallbacks!.dismissed();
      time.flushMicrotasks();
      service.showInterstitialIfAvailable(
        lastInterstitialShownAt: null,
        completedWorkoutCount: 2,
      );
      time.flushMicrotasks();
      expect(sdk.ads.last.shows, 0);
      time.elapse(const Duration(minutes: 10));
      service.showInterstitialIfAvailable(
        lastInterstitialShownAt: null,
        completedWorkoutCount: 2,
      );
      time.flushMicrotasks();
      expect(sdk.ads.last.shows, 1);
      sdk.ads.last.showCallbacks!.failed(const AdFailure('sdk_error'));
    });
  });
  test(
    'unconfirmed native show releases navigation but cannot overlap a late show',
    () {
      scenario((time, service, sdk, sink) {
        bool? result;
        service
            .showInterstitialIfAvailable(
              lastInterstitialShownAt: null,
              completedWorkoutCount: 2,
            )
            .then((r) => result = r);
        time.flushMicrotasks();
        final ad = sdk.ads.first;
        time.elapse(const Duration(seconds: 30));
        expect(result, false);
        expect(service.fullScreenShowing, true);
        service.showInterstitialIfAvailable(
          lastInterstitialShownAt: null,
          completedWorkoutCount: 2,
        );
        time.flushMicrotasks();
        expect(ad.shows, 1);
        ad.showCallbacks!.showed();
        ad.showCallbacks!.dismissed();
        time.flushMicrotasks();
        expect(service.fullScreenShowing, false);
        expect(service.lastInterstitialShownAt, isNotNull);
      });
    },
  );
}
