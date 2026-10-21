import 'dart:async';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../ads/ad_failure.dart';
import '../diagnostics/crash_reporting_service.dart';

abstract interface class ConsentBackend {
  bool get supported;
  Future<void> requestTrackingAuthorization();
  Future<void> updateConsentInfo();
  Future<void> showRequiredForm();
  Future<bool> canRequestAds();
}

class GoogleConsentBackend implements ConsentBackend {
  GoogleConsentBackend({this.beforeTrackingAuthorization});
  Future<bool> Function()? beforeTrackingAuthorization;
  bool _explainerAcknowledged = false;
  @override
  bool get supported =>
      !kIsWeb &&
      {
        TargetPlatform.android,
        TargetPlatform.iOS,
      }.contains(defaultTargetPlatform);
  @override
  Future<void> requestTrackingAuthorization() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return;
    if (await AppTrackingTransparency.trackingAuthorizationStatus ==
        TrackingStatus.notDetermined) {
      if (!_explainerAcknowledged) {
        final explain = beforeTrackingAuthorization;
        if (explain == null || !await explain()) {
          throw const AdFailure('att_pending');
        }
        _explainerAcknowledged = true;
      }
      // Settings may have changed while the explanation was open.
      if (await AppTrackingTransparency.trackingAuthorizationStatus !=
          TrackingStatus.notDetermined) {
        return;
      }
      final status =
          await AppTrackingTransparency.requestTrackingAuthorization();
      if (status == TrackingStatus.notDetermined) {
        throw const AdFailure('att_pending');
      }
    }
  }

  @override
  Future<void> updateConsentInfo() {
    final done = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () {
        if (!done.isCompleted) done.complete();
      },
      (e) {
        if (!done.isCompleted) {
          done.completeError(
            AdFailure('consent_error', code: e.errorCode, message: e.message),
          );
        }
      },
    );
    return done.future;
  }

  @override
  Future<void> showRequiredForm() async {
    await ConsentForm.loadAndShowConsentFormIfRequired((e) {
      if (e != null) {
        throw AdFailure('consent_error', code: e.errorCode, message: e.message);
      }
    });
  }

  @override
  Future<bool> canRequestAds() => ConsentInformation.instance.canRequestAds();
}

class ConsentResult {
  const ConsentResult({
    required this.allowed,
    required this.retryable,
    required this.stage,
    this.failure,
  });
  final bool allowed;
  final bool retryable;
  final String stage;
  final AdFailure? failure;
}

/// Consent only. AdService is the sole owner of MobileAds initialization.
class PrivacyConsentService {
  PrivacyConsentService({
    CrashReportingService? crashReporting,
    ConsentBackend? backend,
    this.timeout = const Duration(seconds: 20),
  }) : _backend = backend ?? GoogleConsentBackend(),
       _crash = crashReporting;
  final ConsentBackend _backend;
  final CrashReportingService? _crash;
  final Duration timeout;
  Future<ConsentResult>? _operation;
  ConsentResult? _settled;
  Future<void>? _tracking;
  Future<void>? _form;
  bool _foreground = true;
  Completer<void>? _resumed;
  bool get supported => _backend.supported;
  bool get trackingAuthorizationPending => _tracking != null;
  void setTrackingExplainer(Future<bool> Function()? explain) {
    final backend = _backend;
    if (backend is GoogleConsentBackend) {
      backend.beforeTrackingAuthorization = explain;
    }
  }

  void setForeground(bool value) {
    _foreground = value;
    if (value) {
      _resumed?.complete();
      _resumed = null;
    }
  }

  Future<void> _waitForResume() async {
    if (_foreground) return;
    final resumed = _resumed ??= Completer<void>();
    await resumed.future.timeout(
      const Duration(seconds: 2),
      onTimeout: () => throw const AdFailure('inactive'),
    );
  }

  void invalidate() => _settled = null;

  // Retain pending prompts after a caller's deadline; never stack native modals.
  Future<void> _requestTrackingAuthorization() =>
      _tracking ??= Future<void>.sync(
        _backend.requestTrackingAuthorization,
      ).whenComplete(() => _tracking = null);
  Future<void> requestTrackingAuthorization() async {
    try {
      await _requestTrackingAuthorization();
    } on Object catch (error, stack) {
      if (_crash != null) {
        unawaited(
          _crash.recordNonFatal(error, stack, reason: 'att_permission_request'),
        );
      }
    }
  }

  Future<bool> canRequestAds() => _backend.canRequestAds().timeout(timeout);
  Future<ConsentResult> requestTrackingAndConsent() {
    if (_settled != null) {
      return canRequestAds()
          .then(
            (allowed) => ConsentResult(
              allowed: allowed,
              retryable: false,
              stage: allowed ? 'allowed' : 'not_allowed',
            ),
          )
          .catchError((Object e) {
            _settled = null;
            return ConsentResult(
              allowed: false,
              retryable: true,
              stage: 'consent_check',
              failure: AdFailure('consent_error', message: e.toString()),
            );
          });
    }
    return _operation ??= Future<ConsentResult>.microtask(
      _request,
    ).whenComplete(() => _operation = null);
  }

  Future<ConsentResult> _request() async {
    if (!supported) {
      return const ConsentResult(
        allowed: false,
        retryable: false,
        stage: 'unsupported',
      );
    }
    var stage = 'consent_info';
    try {
      await _backend.updateConsentInfo().timeout(timeout);
      if (!_foreground) throw const AdFailure('inactive');
      stage = 'att';
      await _requestTrackingAuthorization().timeout(timeout);
      // ATT's completion can precede Flutter's resumed notification.
      await _waitForResume();
      stage = 'consent_form';
      _form ??= Future<void>.sync(
        _backend.showRequiredForm,
      ).whenComplete(() => _form = null);
      await _form!.timeout(timeout);
      final allowed = await canRequestAds();
      return _settled = ConsentResult(
        allowed: allowed,
        retryable: false,
        stage: allowed ? 'allowed' : 'not_allowed',
      );
    } on Object catch (error, stack) {
      final failure = error is AdFailure
          ? error
          : AdFailure(
              error is TimeoutException ? 'timeout' : 'consent_error',
              message: error.toString(),
            );
      if (_crash != null) {
        unawaited(_crash.recordNonFatal(error, stack, reason: 'ads_$stage'));
      }
      var allowed = false;
      try {
        allowed = await canRequestAds();
      } on Object {
        /* fail closed */
      }
      return ConsentResult(
        allowed: allowed,
        retryable: true,
        stage: stage,
        failure: failure,
      );
    }
  }
}
