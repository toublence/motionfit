import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motionfit_squat/core/ads/ad_failure.dart';
import 'package:motionfit_squat/core/ads/ad_sdk.dart';
import 'package:motionfit_squat/core/ads/ad_slot_controller.dart';
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
  test('first completion shows the preloaded interstitial', () {
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
      expect(result, null);
      final shown = sdk.ads.first;
      expect(shown.shows, 1);
      // The next interstitial preloads while this one is on screen.
      expect(sdk.ads.length, 2);
      shown.showCallbacks!.showed();
      shown.showCallbacks!.dismissed();
      time.flushMicrotasks();
      expect(result, true);
      expect(
        sink.events.any(
          (e) =>
              e.name == 'mf2_ad_show_result' &&
              e.parameters['result'] == 'showed',
        ),
        true,
      );
    }, count: 1);
  });
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
  test('iOS inactive keeps an interstitial load running', () {
    scenario((time, service, sdk, sink) {
      expect(service.interstitialLoading, true);
      service.setForeground(false, visible: true);
      time.flushMicrotasks();
      expect(service.interstitialLoading, true);
      service.setForeground(true);
      sdk.ads.single.callbacks.loaded();
      time.flushMicrotasks();
      expect(sdk.ads.length, 1);
      service.setForeground(false);
      expect(service.interstitialLoading, false);
    }, autoLoad: false);
  });
  test('presentation pausing the Flutter view keeps the next loads alive', () {
    scenario((time, service, sdk, sink) {
      final first = sdk.ads.single;
      first.callbacks.loaded();
      final slot = AdSlotController(
        service: service,
        preferredFormat: AdFormat.banner,
        placement: 'bottom',
      );
      slot.setWidth(320);
      slot.setActive(true);
      time.flushMicrotasks();
      service.showInterstitialIfAvailable(
        lastInterstitialShownAt: null,
        completedWorkoutCount: 2,
      );
      time.flushMicrotasks();
      expect(first.shows, 1);
      first.showCallbacks!.showed();
      // iOS while the ad covers the view: inactive → hidden → paused.
      service.setForeground(false, visible: true);
      service.setForeground(false);
      time.flushMicrotasks();
      expect(service.interstitialLoading, true);
      expect(slot.loading, true);
      expect(slot.ad, null);
      // Dismissal: inactive → resumed, then the SDK's dismissed callback.
      service.setForeground(false, visible: true);
      service.setForeground(true);
      first.showCallbacks!.dismissed();
      time.flushMicrotasks();
      expect(service.interstitialLoading, true);
      expect(slot.loading, true);
      expect(sdk.ads.length, 3);
      expect(
        sink.events.any((e) => e.parameters['result'] == 'cancelled'),
        false,
      );
      slot.dispose();
    }, autoLoad: false);
  });
  test('app-open presentation does not cancel the interstitial load', () {
    scenario((time, service, sdk, sink) {
      service.beginAppOpenOpportunity(
        trigger: 'foreground',
        appEntryCount: 3,
        lastFullScreenShownAt: null,
        isOpportunityValid: () => true,
        onShown: (_) {},
      );
      time.flushMicrotasks();
      final appOpen = sdk.ads[sdk.formats.indexOf(AdFormat.appOpen)];
      appOpen.callbacks.loaded();
      time.flushMicrotasks();
      expect(appOpen.shows, 1);
      expect(service.fullScreenShowing, true);
      expect(service.interstitialLoading, true);
      expect(
        sink.events.any((e) => e.parameters['result'] == 'cancelled'),
        false,
      );
      appOpen.showCallbacks!.showed();
      appOpen.showCallbacks!.dismissed();
      time.flushMicrotasks();
    }, autoLoad: false);
  });
  test('cooldown starts at actual show callback and remains 120 seconds', () {
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
      final next = sdk.ads[1];
      expect(next.shows, 0);
      time.elapse(const Duration(seconds: 120));
      service.showInterstitialIfAvailable(
        lastInterstitialShownAt: null,
        completedWorkoutCount: 2,
      );
      time.flushMicrotasks();
      expect(next.shows, 1);
      next.showCallbacks!.failed(const AdFailure('sdk_error'));
    });
  });
  test(
    'unconfirmed native show releases the session; a late show starts cooldown',
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
        final stuck = sdk.ads.first;
        time.elapse(const Duration(seconds: 30));
        expect(result, false);
        expect(service.fullScreenShowing, false);
        expect(
          sink.events.any(
            (e) =>
                e.name == 'mf2_ad_show_result' &&
                e.parameters['result'] == 'unconfirmed_timeout',
          ),
          true,
        );
        expect(stuck.disposals, 0);
        // The rest of the session can still present.
        final next = sdk.ads[1];
        service.showInterstitialIfAvailable(
          lastInterstitialShownAt: null,
          completedWorkoutCount: 2,
        );
        time.flushMicrotasks();
        expect(next.shows, 1);
        next.showCallbacks!.failed(const AdFailure('sdk_error'));
        time.flushMicrotasks();
        stuck.showCallbacks!.showed();
        time.flushMicrotasks();
        expect(service.lastInterstitialShownAt, isNotNull);
        expect(
          sink.events.any((e) => e.parameters['result'] == 'late_showed'),
          true,
        );
        stuck.showCallbacks!.dismissed();
        time.flushMicrotasks();
        expect(stuck.disposals, 1);
        expect(service.fullScreenShowing, false);
        service.showInterstitialIfAvailable(
          lastInterstitialShownAt: null,
          completedWorkoutCount: 2,
        );
        time.flushMicrotasks();
        expect(
          sink.events.last.parameters['skip_reason'],
          'fullscreen_cooldown',
        );
      });
    },
  );
}
