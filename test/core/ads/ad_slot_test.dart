import 'dart:async';
import 'package:fake_async/fake_async.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motionfit_squat/core/ads/ad_sdk.dart';
import 'package:motionfit_squat/core/ads/ad_service.dart';
import 'package:motionfit_squat/core/ads/ad_slot.dart';
import 'package:motionfit_squat/core/ads/ad_slot_controller.dart';
import 'package:motionfit_squat/core/ads/ad_unit_ids.dart';
import 'package:motionfit_squat/core/analytics/analytics_service.dart';
import 'package:motionfit_squat/core/privacy/privacy_consent_service.dart';
import 'package:motionfit_squat/core/providers.dart';
import 'support/fakes.dart';

AdService makeService(FakeSdk sdk, {EventSink? sink}) => AdService(
  analytics: AnalyticsService(sink: sink ?? EventSink()),
  sdk: sdk,
  consent: PrivacyConsentService(backend: FakeConsent()),
  unitResolver: (format) => MotionFitAdUnits.resolve(
    format,
    platform: TargetPlatform.iOS,
    isWeb: false,
    useTestAds: true,
  ),
);

void main() {
  test(
    'native timeout falls back after 60 seconds and ignores stale callbacks',
    () {
      fakeAsync((time) {
        final sdk = FakeSdk();
        final service = makeService(sdk);
        service.initialize();
        time.flushMicrotasks();
        final slot = AdSlotController(
          service: service,
          preferredFormat: AdFormat.native,
          placement: 'records',
        );
        slot.setWidth(320);
        slot.setActive(true);
        time.flushMicrotasks();
        final native = sdk.ads.single;
        time.elapse(const Duration(seconds: 60));
        expect(slot.format, AdFormat.banner);
        expect(sdk.ads.length, 2);
        expect(sdk.formats.last, AdFormat.banner);
        expect(native.disposals, 1);
        native.callbacks.loaded();
        expect(slot.ad, null);
        sdk.ads.last.callbacks.loaded();
        expect(slot.ad, sdk.ads.last);
        slot.dispose();
        service.dispose();
        time.flushMicrotasks();
      });
    },
  );
  test('slow native mediation fill past 15 seconds is kept', () {
    fakeAsync((time) {
      final sdk = FakeSdk();
      final service = makeService(sdk);
      service.initialize();
      time.flushMicrotasks();
      final slot = AdSlotController(
        service: service,
        preferredFormat: AdFormat.native,
        placement: 'records',
      );
      slot.setWidth(320);
      slot.setActive(true);
      time.flushMicrotasks();
      time.elapse(const Duration(seconds: 16));
      sdk.ads.single.callbacks.loaded();
      expect(slot.format, AdFormat.native);
      expect(slot.ad, sdk.ads.single);
      slot.dispose();
      service.dispose();
      time.flushMicrotasks();
    });
  });
  test('iOS inactive keeps a loaded banner; background hides it', () {
    fakeAsync((time) {
      final sdk = FakeSdk()
        ..configure = (ad) => ad.onLoad = () async => ad.callbacks.loaded();
      final service = makeService(sdk);
      service.initialize();
      time.flushMicrotasks();
      final slot = AdSlotController(
        service: service,
        preferredFormat: AdFormat.banner,
        placement: 'bottom',
      );
      slot.setWidth(320);
      slot.setActive(true);
      time.flushMicrotasks();
      final banner = slot.ad;
      expect(banner, isNotNull);
      service.setForeground(false, visible: true);
      time.flushMicrotasks();
      expect(slot.ad, banner);
      service.setForeground(false);
      expect(slot.ad, null);
      service.setForeground(true);
      time.flushMicrotasks();
      expect(slot.ad, banner);
      expect(sdk.ads.length, 1);
      slot.dispose();
      service.dispose();
      time.flushMicrotasks();
    });
  });
  test(
    'native invocation error uses banner; background holds pending retries',
    () {
      fakeAsync((time) {
        final sdk = FakeSdk()
          ..configure = (ad) =>
              ad.onLoad = () async => throw StateError('channel');
        final service = makeService(sdk);
        service.initialize();
        time.flushMicrotasks();
        final slot = AdSlotController(
          service: service,
          preferredFormat: AdFormat.native,
          placement: 'home',
        );
        slot.setWidth(320);
        slot.setActive(true);
        time.flushMicrotasks();
        expect(slot.format, AdFormat.banner);
        expect(sdk.ads.length, 2);
        service.setForeground(false);
        time.elapse(const Duration(minutes: 2));
        expect(sdk.ads.length, 2);
        sdk.configure = (ad) => ad.onLoad = () async => ad.callbacks.loaded();
        service.setForeground(true);
        time.flushMicrotasks();
        expect(sdk.ads.length, 3);
        expect(slot.ad, sdk.ads.last);
        slot.dispose();
        service.dispose();
        time.flushMicrotasks();
      });
    },
  );
  test(
    'adaptive size lookup timeout cannot strand loading or adopt a late size',
    () {
      fakeAsync((time) {
        final pending = Completer<AdSize?>();
        final sdk = FakeSdk()..onSize = (_) => pending.future;
        final service = makeService(sdk);
        service.initialize();
        time.flushMicrotasks();
        final slot = AdSlotController(
          service: service,
          preferredFormat: AdFormat.banner,
          placement: 'bottom',
        );
        slot.setWidth(320);
        slot.setActive(true);
        time.flushMicrotasks();
        time.elapse(const Duration(seconds: 15));
        expect(slot.loading, false);
        sdk.onSize = null;
        time.elapse(const Duration(seconds: 5));
        expect(sdk.ads.length, 1);
        pending.complete(AdSize.banner);
        time.flushMicrotasks();
        expect(sdk.ads.length, 1);
        slot.dispose();
        service.dispose();
        time.flushMicrotasks();
      });
    },
  );
  test(
    'release/test unit resolution is platform specific and owner confirmed',
    () {
      expect(
        MotionFitAdUnits.validateReleaseUnits(TargetPlatform.iOS),
        isEmpty,
      );
      expect(
        MotionFitAdUnits.validateReleaseUnits(TargetPlatform.android),
        isEmpty,
      );
      expect(
        MotionFitAdUnits.releaseUnits(TargetPlatform.iOS)['banner'],
        'ca-app-pub-6169297934919363/9696065805',
      );
      for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
        for (final format in AdFormat.values) {
          if (platform == TargetPlatform.android &&
              format == AdFormat.appOpen) {
            continue;
          }
          final test = MotionFitAdUnits.resolve(
            format,
            platform: platform,
            isWeb: false,
            useTestAds: true,
          )!;
          final production = MotionFitAdUnits.resolve(
            format,
            platform: platform,
            isWeb: false,
            useTestAds: false,
          )!;
          expect(test, startsWith('ca-app-pub-3940256099942544/'));
          expect(production, isNot(startsWith('ca-app-pub-3940256099942544/')));
        }
      }
      expect(
        MotionFitAdUnits.resolve(
          AdFormat.banner,
          platform: TargetPlatform.iOS,
          isWeb: true,
          useTestAds: true,
        ),
        null,
      );
    },
  );
  testWidgets(
    'width changes replace a banner once; inactive slots retain loaded ads',
    (tester) async {
      final sdk = FakeSdk()
        ..configure = (ad) => ad.onLoad = () async => ad.callbacks.loaded();
      final service = makeService(sdk);
      await service.initialize();
      final width = ValueNotifier<double>(320);
      final active = ValueNotifier<bool>(true);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [adServiceProvider.overrideWithValue(service)],
          child: MaterialApp(
            home: Scaffold(
              body: ValueListenableBuilder<double>(
                valueListenable: width,
                builder: (_, w, _) => Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: w,
                    child: ValueListenableBuilder<bool>(
                      valueListenable: active,
                      builder: (_, a, _) => AdSlot(
                        format: AdFormat.banner,
                        placement: 'bottom',
                        active: a,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(sdk.ads.length, 1);
      expect(find.byKey(const ValueKey('fake-ad')), findsOneWidget);
      active.value = false;
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('fake-ad')), findsNothing);
      active.value = true;
      await tester.pumpAndSettle();
      expect(sdk.ads.length, 1);
      width.value = 400;
      await tester.pumpAndSettle();
      expect(sdk.ads.length, 2);
      expect(sdk.ads.first.disposals, 1);
      expect(find.byKey(const ValueKey('fake-ad')), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      service.dispose();
      width.dispose();
      active.dispose();
    },
  );
  testWidgets(
    'offscreen native slot waits until its scroll position is near the viewport',
    (tester) async {
      final sdk = FakeSdk()
        ..configure = (ad) => ad.onLoad = () async => ad.callbacks.loaded();
      final service = makeService(sdk);
      await service.initialize();
      final scroll = ScrollController();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [adServiceProvider.overrideWithValue(service)],
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                controller: scroll,
                child: const Column(
                  children: [
                    SizedBox(height: 1400),
                    AdSlot(
                      format: AdFormat.native,
                      placement: 'records',
                      inline: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(sdk.ads, isEmpty);
      scroll.jumpTo(scroll.position.maxScrollExtent);
      await tester.pumpAndSettle();
      expect(sdk.ads.length, 1);
      expect(find.byKey(const ValueKey('fake-ad')), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      service.dispose();
      scroll.dispose();
    },
  );
}
