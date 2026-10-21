import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:motionfit_squat/core/ads/ad_failure.dart';
import 'package:motionfit_squat/core/ads/ad_sdk.dart';
import 'package:motionfit_squat/core/ads/ad_service.dart';
import 'package:motionfit_squat/core/ads/ad_slot_controller.dart';
import 'package:motionfit_squat/core/analytics/analytics_service.dart';
import 'package:motionfit_squat/core/privacy/privacy_consent_service.dart';
import 'support/fakes.dart';

void main() {
  test(
    'consent retries preserve caches and accumulate backoff until settled',
    () {
      fakeAsync((time) {
        final backend = FakeConsent()
          ..update = () async => throw StateError('offline');
        final sdk = FakeSdk()
          ..configure = (ad) => ad.onLoad = () async => ad.callbacks.loaded();
        final service = AdService(
          analytics: AnalyticsService(sink: EventSink()),
          sdk: sdk,
          consent: PrivacyConsentService(backend: backend),
          unitResolver: (_) => 'ca-app-pub-3940256099942544/4411468910',
        );
        service.updatePolicyContext(
          onboardingCompleted: true,
          completedWorkoutCount: 1,
        );
        service.initialize();
        time.flushMicrotasks();
        final slot =
            AdSlotController(
                service: service,
                preferredFormat: AdFormat.banner,
                placement: 'home',
              )
              ..setWidth(320)
              ..setActive(true);
        time.flushMicrotasks();
        final cached = List<FakeAd>.of(sdk.ads);
        expect(cached.length, 2);
        expect(slot.ad, cached.last);
        time.elapse(const Duration(seconds: 5));
        expect(backend.updates, 2);
        expect(service.ready, true);
        time.elapse(const Duration(seconds: 14));
        expect(backend.updates, 2);
        time.elapse(const Duration(seconds: 1));
        expect(backend.updates, 3);
        time.elapse(const Duration(seconds: 29));
        expect(backend.updates, 3);
        backend.update = null;
        time.elapse(const Duration(seconds: 1));
        expect(backend.updates, 4);
        expect(sdk.initializations, 1);
        expect(sdk.ads, cached);
        expect(cached.every((ad) => ad.disposals == 0), true);
        expect(slot.ad, cached.last);
        time.elapse(const Duration(minutes: 5));
        expect(backend.updates, 4);
        backend.allowed = false;
        service.initialize();
        time.flushMicrotasks();
        expect(service.ready, false);
        expect(cached.every((ad) => ad.disposals == 1), true);
        slot.dispose();
        service.dispose();
        time.flushMicrotasks();
      });
    },
  );

  test(
    'deferred ATT retries once on an allowed route event without polling',
    () {
      fakeAsync((time) {
        final backend = FakeConsent()
          ..tracking = () async => throw const AdFailure('att_pending');
        final service = AdService(
          analytics: AnalyticsService(sink: EventSink()),
          sdk: FakeSdk(),
          consent: PrivacyConsentService(backend: backend),
        )..updateOnboardingContext(true);
        service.initialize();
        time.flushMicrotasks();
        time.elapse(const Duration(minutes: 10));
        expect(backend.trackingRequests, 1);
        service.initialize();
        time.flushMicrotasks();
        expect(backend.trackingRequests, 1);
        backend.tracking = null;
        service.retryDeferredTrackingAuthorization();
        service.retryDeferredTrackingAuthorization();
        time.flushMicrotasks();
        expect(backend.trackingRequests, 2);
        service.retryDeferredTrackingAuthorization();
        time.flushMicrotasks();
        expect(backend.trackingRequests, 2);
        service.dispose();
        time.flushMicrotasks();
      });
    },
  );

  test(
    'iOS SDK configuration failure retries after five minutes with diagnostics',
    () {
      fakeAsync((time) {
        final sink = EventSink();
        final sdk = FakeSdk()
          ..configure = (ad) => ad.onLoad = () async {
            ad.callbacks.failed(
              AdFailure.sdk(
                LoadAdError(0, 'com.google.admob', 'configuration', null),
              ),
            );
          };
        final service =
            AdService(
              analytics: AnalyticsService(sink: sink),
              sdk: sdk,
              consent: PrivacyConsentService(backend: FakeConsent()),
              unitResolver: (_) => 'ca-app-pub-3940256099942544/4411468910',
            )..updatePolicyContext(
              onboardingCompleted: true,
              completedWorkoutCount: 1,
            );
        service.initialize();
        time.flushMicrotasks();
        final failure = sink.events.singleWhere(
          (e) =>
              e.name == 'mf2_ad_load_result' &&
              e.parameters['result'] == 'failed',
        );
        expect(failure.parameters['error_code'], 0);
        expect(failure.parameters['error_domain'], 'com.google.admob');
        time.elapse(const Duration(seconds: 299));
        expect(sdk.ads.length, 1);
        sdk.configure = (ad) => ad.onLoad = () async => ad.callbacks.loaded();
        time.elapse(const Duration(seconds: 1));
        expect(sdk.ads.length, 2);
        expect(sdk.ads.last.loads, 1);
        service.dispose();
        time.flushMicrotasks();
      });
    },
  );

  test('invalid unit is permanently blocked without requesting the SDK', () {
    fakeAsync((time) {
      final sdk = FakeSdk();
      final service =
          AdService(
            analytics: AnalyticsService(sink: EventSink()),
            sdk: sdk,
            consent: PrivacyConsentService(backend: FakeConsent()),
            unitResolver: (_) => 'invalid',
          )..updatePolicyContext(
            onboardingCompleted: true,
            completedWorkoutCount: 1,
          );
      service.initialize();
      time.flushMicrotasks();
      time.elapse(const Duration(minutes: 10));
      service.setForeground(false);
      service.setForeground(true);
      time.flushMicrotasks();
      expect(sdk.ads, isEmpty);
      service.dispose();
    });
  });
}
