import 'dart:async';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motionfit_squat/core/ads/ad_bootstrap.dart';
import 'package:motionfit_squat/core/ads/ad_failure.dart';
import 'package:motionfit_squat/core/ads/ad_loader.dart';
import 'package:motionfit_squat/core/ads/ad_sdk.dart';
import 'package:motionfit_squat/core/ads/ad_service.dart';
import 'package:motionfit_squat/core/analytics/analytics_service.dart';
import 'package:motionfit_squat/core/privacy/privacy_consent_service.dart';
import 'package:motionfit_squat/features/exercise/application/combined_workout_metrics.dart';
import 'support/fakes.dart';

void main() {
  for (final mode in ['error', 'pending']) {
    test('production bootstrap initializes ads despite DB $mode', () {
      fakeAsync((time) {
        final sdk = FakeSdk();
        final sink = EventSink();
        final ads = AdService(
          analytics: AnalyticsService(sink: sink),
          sdk: sdk,
          consent: PrivacyConsentService(backend: FakeConsent()),
          unitResolver: (_) => 'ca-app-pub-3940256099942544/4411468910',
        );
        final database = Completer<CombinedWorkoutMetrics>();
        prepareAds(
          ads,
          onboardingCompleted: true,
          readMetrics: () => mode == 'error'
              ? Future.error(StateError('DB unavailable'))
              : database.future,
          isMounted: () => true,
        );
        time.flushMicrotasks();
        expect(ads.ready, true);
        expect(sdk.initializations, 1);
        expect(
          sdk.ads.length,
          1,
        ); // revenue_v1 preloads independently of the workout DB.
        if (mode == 'error') {
          expect(
            sink.events.any(
              (e) =>
                  e.parameters['skip_reason'] == 'workout_metrics_unavailable',
            ),
            true,
          );
        } else {
          database.complete(
            const CombinedWorkoutMetrics(
              currentStreak: 0,
              streakAtRisk: false,
              completedWorkoutCount: 0,
              distinctWorkoutDays: 0,
            ),
          );
          time.flushMicrotasks();
        }
        ads.dispose();
        time.flushMicrotasks();
      });
    });
  }
  test(
    'foreground retries consent even while the workout DB never answers',
    () {
      fakeAsync((time) {
        final backend = FakeConsent()..allowed = false;
        backend.update = () async {
          if (backend.updates == 1) throw StateError('offline');
          backend.allowed = true;
        };
        final sdk = FakeSdk();
        final ads = AdService(
          analytics: AnalyticsService(sink: EventSink()),
          sdk: sdk,
          consent: PrivacyConsentService(backend: backend),
        );
        final database = Completer<CombinedWorkoutMetrics>();
        prepareAds(
          ads,
          onboardingCompleted: true,
          readMetrics: () => database.future,
          isMounted: () => true,
        );
        time.flushMicrotasks();
        expect(ads.ready, false);
        ads.setForeground(false);
        time.elapse(const Duration(seconds: 10));
        expect(backend.updates, 1);
        ads.setForeground(true);
        time.flushMicrotasks();
        expect(ads.ready, true);
        expect(sdk.initializations, 1);
        expect(ads.completedWorkoutCount, null);
        ads.dispose();
        time.flushMicrotasks();
      });
    },
  );
  test(
    'SDK initialization timeout can retry and ignores the late first answer',
    () {
      fakeAsync((time) {
        final pending = Completer<void>();
        final sdk = FakeSdk()..onInitialize = () => pending.future;
        final ads = AdService(
          analytics: AnalyticsService(sink: EventSink()),
          sdk: sdk,
          consent: PrivacyConsentService(backend: FakeConsent()),
        );
        ads.initialize();
        time.flushMicrotasks();
        time.elapse(const Duration(seconds: 20));
        expect(ads.ready, false);
        sdk.onInitialize = null;
        time.elapse(const Duration(seconds: 5));
        expect(ads.ready, true);
        expect(sdk.initializations, 2);
        pending.complete();
        time.flushMicrotasks();
        expect(sdk.initializations, 2);
        ads.dispose();
        time.flushMicrotasks();
      });
    },
  );
  test(
    'UMP transient error automatically retries and initializes SDK only once',
    () {
      fakeAsync((time) {
        final backend = FakeConsent()..allowed = false;
        backend.update = () async {
          if (backend.updates == 1) throw StateError('offline');
          backend.allowed = true;
        };
        final sdk = FakeSdk();
        final ads = AdService(
          analytics: AnalyticsService(sink: EventSink()),
          sdk: sdk,
          consent: PrivacyConsentService(backend: backend),
        );
        ads.initialize();
        time.flushMicrotasks();
        expect(ads.ready, false);
        time.elapse(const Duration(seconds: 5));
        expect(ads.ready, true);
        ads.initialize();
        time.flushMicrotasks();
        expect(sdk.initializations, 1);
        ads.dispose();
        time.flushMicrotasks();
      });
    },
  );
  test(
    'cached normal choice reflects changed SDK permission without another modal',
    () {
      fakeAsync((time) {
        final backend = FakeConsent()..allowed = false;
        final consent = PrivacyConsentService(backend: backend);
        consent.requestTrackingAndConsent();
        time.flushMicrotasks();
        backend.allowed = true;
        ConsentResult? result;
        consent.requestTrackingAndConsent().then((r) => result = r);
        time.flushMicrotasks();
        expect(result!.allowed, true);
        expect(backend.forms, 1);
      });
    },
  );
  test('late factory result is disposed without ever starting an SDK load', () {
    fakeAsync((time) {
      final pending = Completer<AdHandle>();
      FakeAd? ad;
      final loader = AdLoader(
        format: AdFormat.banner,
        placement: 'test',
        unitId: 'ca-app-pub-3940256099942544/2934735716',
        retry: false,
        telemetry: (_, _) {},
        create: (callbacks) {
          ad = FakeAd(callbacks);
          return pending.future;
        },
      );
      loader.setEnabled(true);
      time.flushMicrotasks();
      time.elapse(const Duration(seconds: 15));
      expect(loader.loading, false);
      pending.complete(ad!);
      time.flushMicrotasks();
      expect(ad!.loads, 0);
      expect(ad!.disposals, 1);
      expect(loader.ad, null);
      loader.dispose();
      time.flushMicrotasks();
    });
  });
  test('ATT channel failure does not block the onboarding caller', () async {
    final backend = FakeConsent()
      ..tracking = () async => throw StateError('ATT channel');
    final consent = PrivacyConsentService(backend: backend);
    await expectLater(consent.requestTrackingAuthorization(), completes);
    backend.tracking = null;
    final result = await consent.requestTrackingAndConsent();
    expect(result.allowed, true);
    expect(backend.trackingRequests, 2);
  });
  test('unresolved ATT status waits for resume without polling', () {
    fakeAsync((time) {
      final backend = FakeConsent()..allowed = false;
      backend.tracking = () async {
        if (backend.trackingRequests == 1) {
          throw const AdFailure('att_pending');
        }
        backend.allowed = true;
      };
      final ads = AdService(
        analytics: AnalyticsService(sink: EventSink()),
        sdk: FakeSdk(),
        consent: PrivacyConsentService(backend: backend),
      );
      ads.initialize();
      time.flushMicrotasks();
      expect(ads.ready, false);
      time.elapse(const Duration(seconds: 5));
      expect(ads.ready, false);
      expect(backend.trackingRequests, 1);
      ads.updateOnboardingContext(true);
      ads.setForeground(false);
      ads.setForeground(true);
      time.flushMicrotasks();
      expect(ads.ready, true);
      expect(backend.trackingRequests, 2);
      ads.dispose();
      time.flushMicrotasks();
    });
  });
  test(
    'completed ATT invocation does not cache an unresolved OS status',
    () async {
      final backend = FakeConsent();
      final consent = PrivacyConsentService(backend: backend);
      await consent.requestTrackingAuthorization();
      await consent.requestTrackingAuthorization();
      // The real backend rechecks the OS status before requesting a prompt.
      expect(backend.trackingRequests, 2);
    },
  );
}
