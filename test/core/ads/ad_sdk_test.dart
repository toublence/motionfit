import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_mobile_ads/src/ad_instance_manager.dart';
import 'package:motionfit_squat/core/ads/ad_sdk.dart';
import 'package:motionfit_squat/core/ads/ad_service.dart';
import 'package:motionfit_squat/core/analytics/analytics_service.dart';
import 'package:motionfit_squat/core/diagnostics/crash_reporting_service.dart';
import 'package:motionfit_squat/core/privacy/privacy_consent_service.dart';
import 'support/fakes.dart';

class RecordingCrashService extends CrashReportingService {
  final errors = <Object>[];
  final reasons = <String?>[];
  @override
  Future<void> recordNonFatal(
    Object error,
    StackTrace stackTrace, {
    String? reason,
  }) async {
    errors.add(error);
    reasons.add(reason);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const meta = MethodChannel('fit.motionfit.app/meta_ads_privacy');
  final ads = MethodChannel(
    'plugins.flutter.io/google_mobile_ads',
    StandardMethodCodec(AdMessageCodec()),
  );
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    messenger.setMockMethodCallHandler(meta, null);
    messenger.setMockMethodCallHandler(ads, null);
  });
  for (final missing in [true, false]) {
    test(
      'Meta ${missing ? 'missing plugin' : 'channel failure'} records nonfatal and reaches ready',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        var initialized = 0;
        messenger.setMockMethodCallHandler(meta, (_) async {
          if (missing) throw MissingPluginException('meta');
          throw PlatformException(code: 'sync_failed');
        });
        messenger.setMockMethodCallHandler(ads, (call) async {
          if (call.method == 'MobileAds#initialize') {
            initialized++;
            return InitializationStatus(<String, AdapterStatus>{});
          }
          return null;
        });
        final crash = RecordingCrashService();
        final service = AdService(
          analytics: AnalyticsService(sink: EventSink()),
          crashReporting: crash,
          sdk: GoogleAdSdk(crashReporting: crash),
          consent: PrivacyConsentService(backend: FakeConsent()),
          unitResolver: (_) => null,
        );
        expect(await service.initialize(), true);
        expect(service.ready, true);
        expect(initialized, 1);
        expect(
          crash.errors.single,
          missing ? isA<MissingPluginException>() : isA<PlatformException>(),
        );
        expect(crash.reasons.single, 'meta_ads_privacy_sync');
        service.dispose();
      },
    );
  }
}
