import 'dart:async';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motionfit_squat/core/privacy/privacy_consent_service.dart';
import '../ads/support/fakes.dart';

void main() {
  test(
    'ATT completion waits for delayed resume before requesting the form',
    () {
      fakeAsync((time) {
        final tracking = Completer<void>();
        final backend = FakeConsent()..tracking = () => tracking.future;
        final consent = PrivacyConsentService(backend: backend);
        ConsentResult? result;
        consent.requestTrackingAndConsent().then((value) => result = value);
        time.flushMicrotasks();
        consent.setForeground(false);
        tracking.complete();
        time.flushMicrotasks();
        expect(result, null);
        expect(backend.forms, 0);
        time.elapse(const Duration(milliseconds: 500));
        consent.setForeground(true);
        time.flushMicrotasks();
        expect(result!.retryable, false);
        expect(result!.allowed, true);
        expect(backend.forms, 1);
      });
    },
  );

  test('ATT completion in background does not open a consent form', () {
    fakeAsync((time) {
      final backend = FakeConsent()..allowed = false;
      final consent = PrivacyConsentService(backend: backend);
      backend.tracking = () async => consent.setForeground(false);
      ConsentResult? result;
      consent.requestTrackingAndConsent().then((value) => result = value);
      time.flushMicrotasks();
      time.elapse(const Duration(seconds: 2));
      expect(result!.failure!.kind, 'inactive');
      expect(result!.allowed, false);
      expect(backend.forms, 0);
    });
  });
}
