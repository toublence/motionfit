import 'dart:async';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:motionfit_squat/core/diagnostics/crash_reporting_service.dart';

class PrivacyConsentService {
  PrivacyConsentService(this._crashReporting);

  final CrashReportingService _crashReporting;
  Future<void>? _requestOperation;
  Future<void>? _trackingAuthorizationOperation;

  Future<void> requestTrackingAuthorization() =>
      _trackingAuthorizationOperation ??= _requestTrackingAuthorization();

  Future<void> requestTrackingAndConsent() =>
      _requestOperation ??= _requestTrackingAndConsent();

  Future<void> _requestTrackingAndConsent() async {
    await requestTrackingAuthorization();
    await refreshUmpConsent();
  }

  Future<void> _requestTrackingAuthorization() async {
    if (!Platform.isIOS) return;
    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    } on Object catch (error, stackTrace) {
      await _crashReporting.recordNonFatal(
        error,
        stackTrace,
        reason: 'att_permission_request',
      );
    }
  }

  Future<void> refreshUmpConsent() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    await _crashReporting.setCustomKey('ad_state', 'consent_started');
    await _crashReporting.log('consent_flow_started');
    final completer = Completer<void>();
    try {
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () => unawaited(_loadConsentForm(completer)),
        (error) => unawaited(
          _finishConsentFlow(
            completer,
            error: error,
            reason: 'ump_consent_info_update',
          ),
        ),
      );
      await completer.future.timeout(const Duration(seconds: 20));
    } on TimeoutException catch (error, stackTrace) {
      await _crashReporting.recordNonFatal(
        error,
        stackTrace,
        reason: 'ump_consent_timeout',
      );
      try {
        await _initializeAdsWhenAllowed();
      } on Object catch (initializationError, initializationStackTrace) {
        await _crashReporting.recordNonFatal(
          initializationError,
          initializationStackTrace,
          reason: 'mobile_ads_consent_timeout_initialization',
        );
      }
    } on Object catch (error, stackTrace) {
      await _crashReporting.recordNonFatal(
        error,
        stackTrace,
        reason: 'ump_consent_flow',
      );
    } finally {
      await _crashReporting.setCustomKey('ad_state', 'consent_completed');
      await _crashReporting.log('consent_flow_completed');
    }
  }

  Future<void> _loadConsentForm(Completer<void> completer) async {
    try {
      await ConsentForm.loadAndShowConsentFormIfRequired((error) {
        if (error != null) {
          unawaited(
            _crashReporting.recordNonFatal(
              error,
              StackTrace.current,
              reason: 'ump_consent_form_dismissed',
            ),
          );
        }
      });
      await _finishConsentFlow(completer);
    } on Object catch (error, stackTrace) {
      await _finishConsentFlow(
        completer,
        error: error,
        stackTrace: stackTrace,
        reason: 'ump_consent_form_load',
      );
    }
  }

  Future<void> _finishConsentFlow(
    Completer<void> completer, {
    Object? error,
    StackTrace? stackTrace,
    String? reason,
  }) async {
    if (error != null) {
      await _crashReporting.recordNonFatal(
        error,
        stackTrace ?? StackTrace.current,
        reason: reason,
      );
    }
    try {
      await _initializeAdsWhenAllowed();
    } on Object catch (initializationError, initializationStackTrace) {
      await _crashReporting.recordNonFatal(
        initializationError,
        initializationStackTrace,
        reason: 'mobile_ads_consent_initialization',
      );
    } finally {
      if (!completer.isCompleted) completer.complete();
    }
  }

  Future<void> _initializeAdsWhenAllowed() async {
    if (await ConsentInformation.instance.canRequestAds()) {
      await MobileAds.instance.initialize();
    }
  }
}
