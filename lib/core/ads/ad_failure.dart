import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdFailure implements Exception {
  const AdFailure(this.kind, {this.code, this.domain = '', this.message = ''});
  factory AdFailure.sdk(AdError error) {
    final ios = error.domain == 'com.google.admob';
    final android = error.domain == 'com.google.android.gms.ads';
    final kind = (ios && error.code == 1) || (android && error.code == 3)
        ? 'no_fill'
        : (ios && error.code == 0) || (android && error.code == 1)
        ? 'configuration'
        : (ios || android) && error.code == 2
        ? 'network'
        : 'sdk_error';
    return AdFailure(
      kind,
      code: error.code,
      domain: error.domain,
      message: error.message,
    );
  }
  final String kind;
  final int? code;
  final String domain;
  final String message;
  bool get retryable =>
      !{'invalid_unit', 'consent_blocked'}.contains(kind) &&
      (kind != 'configuration' || domain == 'com.google.admob');
  Map<String, Object> get parameters => {
    'error_kind': kind,
    'error_code': ?code,
    if (domain.isNotEmpty) 'error_domain': domain,
  };
  @override
  String toString() => '$kind ($domain/$code): $message';
}
