import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_failure.dart';
import '../diagnostics/crash_reporting_service.dart';

enum AdFormat { interstitial, native, banner, appOpen }

class AdCallbacks {
  const AdCallbacks({
    required this.loaded,
    required this.failed,
    required this.impression,
    required this.clicked,
    required this.isActive,
  });
  final bool Function() isActive;
  final VoidCallback loaded;
  final void Function(AdFailure) failed;
  final VoidCallback impression;
  final VoidCallback clicked;
}

class AdShowCallbacks {
  const AdShowCallbacks({
    required this.showed,
    required this.dismissed,
    required this.failed,
  });
  final VoidCallback showed;
  final VoidCallback dismissed;
  final void Function(AdFailure) failed;
}

abstract interface class AdHandle {
  Future<void> load();
  Future<void> dispose();
  Future<void> show(AdShowCallbacks callbacks);
  Widget buildWidget();
}

abstract interface class AdSdk {
  Future<void> initialize();
  Future<AdSize?> bannerSize(int width);
  AdHandle create({
    required AdFormat format,
    required String unitId,
    required AdCallbacks callbacks,
    AdSize? size,
    NativeTemplateStyle? templateStyle,
  });
}

class GoogleAdSdk implements AdSdk {
  GoogleAdSdk({CrashReportingService? crashReporting})
    : _crash = crashReporting;
  final CrashReportingService? _crash;
  @override
  Future<void> initialize() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      try {
        await const MethodChannel(
          'fit.motionfit.app/meta_ads_privacy',
        ).invokeMethod<void>('syncTrackingAuthorization');
      } on Object catch (error, stack) {
        unawaited(
          _crash?.recordNonFatal(error, stack, reason: 'meta_ads_privacy_sync'),
        );
      }
    }
    await MobileAds.instance.initialize();
  }

  @override
  Future<AdSize?> bannerSize(int width) =>
      // Keep the existing banner height; the large replacement changes layout.
      // ignore: deprecated_member_use
      AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
  @override
  AdHandle create({
    required AdFormat format,
    required String unitId,
    required AdCallbacks callbacks,
    AdSize? size,
    NativeTemplateStyle? templateStyle,
  }) => _GoogleAdHandle(format, unitId, callbacks, size, templateStyle);
}

class _GoogleAdHandle implements AdHandle {
  _GoogleAdHandle(
    this.format,
    this.unit,
    this.callbacks,
    AdSize? size,
    NativeTemplateStyle? style,
  ) {
    if (format == AdFormat.native) {
      _view = NativeAd(
        adUnitId: unit,
        request: const AdRequest(),
        nativeTemplateStyle: style,
        listener: NativeAdListener(
          onAdLoaded: _loaded,
          onAdFailedToLoad: (_, e) => callbacks.failed(AdFailure.sdk(e)),
          onAdImpression: (_) => callbacks.impression(),
          onAdClicked: (_) => callbacks.clicked(),
        ),
      );
    } else if (format == AdFormat.banner) {
      _view = BannerAd(
        adUnitId: unit,
        size: size!,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: _loaded,
          onAdFailedToLoad: (_, e) => callbacks.failed(AdFailure.sdk(e)),
          onAdImpression: (_) => callbacks.impression(),
          onAdClicked: (_) => callbacks.clicked(),
        ),
      );
    }
  }
  final AdFormat format;
  final String unit;
  final AdCallbacks callbacks;
  AdWithView? _view;
  InterstitialAd? _interstitial;
  AppOpenAd? _appOpen;
  bool _disposed = false;
  void _loaded(Ad ad) {
    if (_disposed) {
      unawaited(ad.dispose());
      return;
    }
    callbacks.loaded();
  }

  @override
  Future<void> load() {
    if (format == AdFormat.appOpen) {
      return AppOpenAd.load(
        adUnitId: unit,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            if (_disposed) {
              unawaited(ad.dispose());
              return;
            }
            _appOpen = ad;
            _loaded(ad);
          },
          onAdFailedToLoad: (e) => callbacks.failed(AdFailure.sdk(e)),
        ),
      );
    }
    if (format != AdFormat.interstitial) return _view!.load();
    return InterstitialAd.load(
      adUnitId: unit,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          if (_disposed) {
            unawaited(ad.dispose());
            return;
          }
          _interstitial = ad;
          _loaded(ad);
        },
        onAdFailedToLoad: (e) => callbacks.failed(AdFailure.sdk(e)),
      ),
    );
  }

  @override
  Future<void> show(AdShowCallbacks events) {
    if (format == AdFormat.appOpen) {
      final ad = _appOpen;
      if (_disposed || ad == null)
        return Future.error(StateError('Ad not ready'));
      ad.fullScreenContentCallback = FullScreenContentCallback<AppOpenAd>(
        onAdShowedFullScreenContent: (_) => events.showed(),
        onAdDismissedFullScreenContent: (_) => events.dismissed(),
        onAdFailedToShowFullScreenContent: (_, e) =>
            events.failed(AdFailure.sdk(e)),
        onAdImpression: (_) => callbacks.impression(),
        onAdClicked: (_) => callbacks.clicked(),
      );
      return ad.show();
    }
    final ad = _interstitial;
    if (_disposed || ad == null) {
      return Future.error(StateError('Ad not ready'));
    }
    ad.fullScreenContentCallback = FullScreenContentCallback<InterstitialAd>(
      onAdShowedFullScreenContent: (_) => events.showed(),
      onAdDismissedFullScreenContent: (_) => events.dismissed(),
      onAdFailedToShowFullScreenContent: (_, e) =>
          events.failed(AdFailure.sdk(e)),
      onAdImpression: (_) => callbacks.impression(),
      onAdClicked: (_) => callbacks.clicked(),
    );
    return ad.show();
  }

  @override
  Widget buildWidget() => AdWidget(ad: _view!);
  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await (_view ?? _interstitial ?? _appOpen)?.dispose();
  }
}
