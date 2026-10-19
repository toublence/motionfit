import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:motionfit_squat/core/ads/ad_sdk.dart';
import 'package:motionfit_squat/core/analytics/analytics_service.dart';
import 'package:motionfit_squat/core/privacy/privacy_consent_service.dart';

class FakeConsent implements ConsentBackend {
  @override
  bool supported = true;
  bool allowed = true;
  int updates = 0;
  int forms = 0;
  int trackingRequests = 0;
  Future<void> Function()? update;
  Future<void> Function()? form;
  Future<void> Function()? tracking;
  @override
  Future<bool> canRequestAds() async => allowed;
  @override
  Future<void> updateConsentInfo() async {
    updates++;
    await update?.call();
  }

  @override
  Future<void> showRequiredForm() async {
    forms++;
    await form?.call();
  }

  @override
  Future<void> requestTrackingAuthorization() async {
    trackingRequests++;
    await tracking?.call();
  }
}

class FakeAd implements AdHandle {
  FakeAd(this.callbacks);
  final AdCallbacks callbacks;
  AdShowCallbacks? showCallbacks;
  int loads = 0;
  int shows = 0;
  int disposals = 0;
  Future<void> Function()? onLoad;
  Future<void> Function()? onShow;
  @override
  Future<void> load() async {
    loads++;
    await onLoad?.call();
  }

  @override
  Future<void> show(AdShowCallbacks callbacks) async {
    shows++;
    showCallbacks = callbacks;
    await onShow?.call();
  }

  @override
  Future<void> dispose() async {
    disposals++;
  }

  @override
  Widget buildWidget() => const SizedBox(key: ValueKey('fake-ad'), height: 50);
}

class FakeSdk implements AdSdk {
  int initializations = 0;
  final ads = <FakeAd>[];
  final formats = <AdFormat>[];
  Future<void> Function()? onInitialize;
  void Function(FakeAd)? configure;
  Future<AdSize?> Function(int)? onSize;
  @override
  Future<void> initialize() async {
    initializations++;
    await onInitialize?.call();
  }

  @override
  Future<AdSize?> bannerSize(int width) async =>
      onSize == null ? AdSize.banner : await onSize!(width);
  @override
  AdHandle create({
    required AdFormat format,
    required String unitId,
    required AdCallbacks callbacks,
    AdSize? size,
    NativeTemplateStyle? templateStyle,
  }) {
    final ad = FakeAd(callbacks);
    configure?.call(ad);
    ads.add(ad);
    formats.add(format);
    return ad;
  }
}

class EventSink implements AnalyticsSink {
  final events = <({String name, Map<String, Object> parameters})>[];
  @override
  Future<void> logEvent(String name, Map<String, Object> parameters) async {
    events.add((name: name, parameters: parameters));
  }

  @override
  Future<void> logScreenView(String screenName) async {}
}
