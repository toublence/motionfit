import 'dart:async';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:motionfit_squat/core/ads/ad_failure.dart';
import 'package:motionfit_squat/core/ads/ad_loader.dart';
import 'package:motionfit_squat/core/ads/ad_sdk.dart';
import 'package:motionfit_squat/core/ads/ad_service.dart';
import 'package:motionfit_squat/core/analytics/analytics_service.dart';
import 'package:motionfit_squat/core/privacy/privacy_consent_service.dart';
import 'support/fakes.dart';

void main() {
  for (final stage in ['info', 'form']) {
    test('UMP $stage failure retries and recovers without restarting', () {
      fakeAsync((time) {
        final backend = FakeConsent()..allowed = false;
        Future<void> fail() async => throw StateError('offline');
        if (stage == 'info') {
          backend.update = fail;
        } else {
          backend.form = fail;
        }
        final consent = PrivacyConsentService(backend: backend);
        ConsentResult? result;
        consent.requestTrackingAndConsent().then((r) => result = r);
        time.flushMicrotasks();
        expect(result!.allowed, false);
        expect(result!.retryable, true);
        backend.update = null;
        backend.form = null;
        backend.allowed = true;
        consent.requestTrackingAndConsent().then((r) => result = r);
        time.flushMicrotasks();
        expect(result!.allowed, true);
        expect(backend.updates, 2);
      });
    });
  }
  test('UMP normal not-allowed result is not repeatedly prompted', () {
    fakeAsync((time) {
      final backend = FakeConsent()..allowed = false;
      final consent = PrivacyConsentService(backend: backend);
      consent.requestTrackingAndConsent();
      time.flushMicrotasks();
      consent.requestTrackingAndConsent();
      time.flushMicrotasks();
      expect(backend.updates, 1);
      expect(backend.forms, 1);
    });
  });
  test('ATT and UMP pending modals are never stacked after a deadline', () {
    fakeAsync((time) {
      final tracking = Completer<void>();
      final form = Completer<void>();
      final backend = FakeConsent()
        ..allowed = false
        ..tracking = (() => tracking.future)
        ..form = (() => form.future);
      final consent = PrivacyConsentService(backend: backend);
      consent.requestTrackingAndConsent();
      time.flushMicrotasks();
      time.elapse(const Duration(seconds: 20));
      consent.requestTrackingAndConsent();
      time.flushMicrotasks();
      expect(backend.trackingRequests, 1);
      expect(backend.forms, 0);
      tracking.complete();
      time.flushMicrotasks();
      time.elapse(const Duration(seconds: 20));
      consent.requestTrackingAndConsent();
      time.flushMicrotasks();
      expect(backend.forms, 1);
      backend.allowed = true;
      form.complete();
      time.flushMicrotasks();
    });
  });
  test('existing permitted consent remains usable after an update error', () {
    fakeAsync((time) {
      final backend = FakeConsent()
        ..update = () async => throw StateError('offline');
      ConsentResult? result;
      PrivacyConsentService(
        backend: backend,
      ).requestTrackingAndConsent().then((r) => result = r);
      time.flushMicrotasks();
      expect(result!.allowed, true);
      expect(result!.retryable, true);
    });
  });
  for (final format in AdFormat.values) {
    test('$format invocation error releases loading and retries once', () {
      fakeAsync((time) {
        final sdk = FakeSdk()
          ..configure = (ad) =>
              ad.onLoad = () async => throw StateError('channel');
        final events = <String>[];
        final loader = AdLoader(
          format: format,
          placement: 'test',
          unitId: 'ca-app-pub-3940256099942544/2934735716',
          telemetry: (n, _) => events.add(n),
          create: (c) =>
              sdk.create(format: format, unitId: 'test', callbacks: c),
        );
        loader.setEnabled(true);
        time.flushMicrotasks();
        expect(loader.loading, false);
        expect(sdk.ads.single.disposals, 1);
        sdk.configure = (ad) => ad.onLoad = () async => ad.callbacks.loaded();
        time.elapse(const Duration(seconds: 5));
        expect(sdk.ads.length, 2);
        expect(loader.ad, sdk.ads.last);
        expect(events.where((n) => n == 'mf2_ad_load_result').length, 2);
        loader.dispose();
        time.flushMicrotasks();
      });
    });
    test('$format timeout rejects old callbacks and recovers', () {
      fakeAsync((time) {
        final sdk = FakeSdk();
        final outcomes = <Map<String, Object>>[];
        final loader = AdLoader(
          format: format,
          placement: 'test',
          unitId: 'test',
          telemetry: (n, p) {
            if (n == 'mf2_ad_load_result') outcomes.add(p);
          },
          create: (c) =>
              sdk.create(format: format, unitId: 'test', callbacks: c),
        );
        loader.setEnabled(true);
        time.flushMicrotasks();
        final old = sdk.ads.single;
        time.elapse(const Duration(seconds: 15));
        expect(loader.loading, false);
        expect(old.disposals, 1);
        old.callbacks.loaded();
        old.callbacks.failed(const AdFailure('network'));
        expect(loader.ad, null);
        expect(outcomes.length, 1);
        time.elapse(const Duration(seconds: 5));
        sdk.ads.last.callbacks.loaded();
        expect(loader.ad, sdk.ads.last);
        expect(outcomes.length, 2);
        loader.dispose();
        time.flushMicrotasks();
      });
    });
  }
  test('no fill and invalid configuration remain distinct', () {
    expect(
      AdFailure.sdk(LoadAdError(1, 'com.google.admob', 'none', null)).kind,
      'no_fill',
    );
    expect(
      AdFailure.sdk(
        LoadAdError(3, 'com.google.android.gms.ads', 'none', null),
      ).kind,
      'no_fill',
    );
    expect(
      AdFailure.sdk(LoadAdError(1, 'other', 'unknown', null)).kind,
      'sdk_error',
    );
    expect(
      AdFailure.sdk(
        LoadAdError(0, 'com.google.admob', 'invalid', null),
      ).retryable,
      false,
    );
  });
  test(
    'SDK init retries after failure and consent false sends no ad requests',
    () {
      fakeAsync((time) {
        final sdk = FakeSdk()
          ..onInitialize = () async => throw StateError('channel');
        final backend = FakeConsent();
        final sink = EventSink();
        final service = AdService(
          analytics: AnalyticsService(sink: sink),
          sdk: sdk,
          consent: PrivacyConsentService(backend: backend),
          unitResolver: (_) => 'ca-app-pub-3940256099942544/1033173712',
        );
        service.updatePolicyContext(
          onboardingCompleted: true,
          completedWorkoutCount: 2,
        );
        service.initialize();
        time.flushMicrotasks();
        expect(service.ready, false);
        sdk.onInitialize = null;
        time.elapse(const Duration(seconds: 5));
        expect(service.ready, true);
        expect(sdk.initializations, 2);
        expect(sdk.ads.length, 1);
        service.dispose();
        time.flushMicrotasks();
        backend.allowed = false;
        final blocked = AdService(
          analytics: AnalyticsService(sink: sink),
          sdk: sdk,
          consent: PrivacyConsentService(backend: backend),
          unitResolver: (_) => 'ca-app-pub-3940256099942544/1033173712',
        );
        blocked.initialize();
        time.flushMicrotasks();
        expect(blocked.ready, false);
        expect(sdk.ads.length, 1);
        blocked.dispose();
      });
    },
  );
}
