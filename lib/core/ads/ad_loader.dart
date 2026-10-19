import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'ad_failure.dart';
import 'ad_sdk.dart';

typedef AdTelemetry =
    void Function(String name, Map<String, Object> parameters);

/// Owns a request's deadline, retry and stale callback rejection for all formats.
class AdLoader extends ChangeNotifier {
  AdLoader({
    required this.format,
    required this.placement,
    required this.unitId,
    required this.create,
    required this.telemetry,
    this.retry = true,
    this.timeout = const Duration(seconds: 15),
    String Function()? newId,
  }) : _newId = newId ?? const Uuid().v7;
  final AdFormat format;
  final String placement;
  final String unitId;
  final FutureOr<AdHandle> Function(AdCallbacks) create;
  final AdTelemetry telemetry;
  final bool retry;
  final Duration timeout;
  final String Function() _newId;
  AdHandle? _pending;
  AdHandle? _ad;
  Timer? _deadline;
  Timer? _retryTimer;
  int _generation = 0;
  int _failures = 0;
  bool _enabled = false;
  bool _disposed = false;
  bool _loading = false;
  bool _requested = false;
  String? _requestId;
  AdFailure? _failure;
  AdHandle? get ad => _ad;
  bool get loading => _loading;
  AdFailure? get failure => _failure;
  String? get requestId => _requestId;
  Map<String, Object> get context => {
    'ad_format': format.name,
    'ad_placement': placement,
    'ad_unit_id': unitId,
    'request_id': ?_requestId,
    'retry_attempt': _failures,
  };
  void _log(String event, [Map<String, Object> extra = const {}]) =>
      telemetry(event, {...context, ...extra});
  void setEnabled(bool value) {
    if (_disposed) return;
    if (value && !_enabled && _failure?.kind == 'consent_blocked') {
      _failure = null;
    }
    _enabled = value;
    if (!value) {
      _retryTimer?.cancel();
      if (_loading) _cancelPending('inactive');
    } else {
      ensureLoaded();
    }
  }

  void ensureLoaded() {
    if (_disposed ||
        !_enabled ||
        _loading ||
        _ad != null ||
        _failure?.retryable == false ||
        _retryTimer?.isActive == true) {
      return;
    }
    _loading = true;
    _requested = false;
    _requestId = _newId();
    final generation = ++_generation;
    final requestContext = context;
    _deadline = Timer(
      timeout,
      () => _fail(generation, const AdFailure('timeout')),
    );
    unawaited(
      Future<void>.microtask(() async {
        try {
          final handle = await create(
            AdCallbacks(
              isActive: () => _current(generation) && _loading,
              loaded: () {
                if (!_current(generation) || !_loading) return;
                _deadline?.cancel();
                _loading = false;
                _ad = _pending;
                _pending = null;
                _log('mf2_ad_load_result', {'result': 'loaded'});
                _failure = null;
                _failures = 0;
                notifyListeners();
              },
              failed: (error) => _fail(generation, error),
              impression: () {
                if (_current(generation)) {
                  telemetry('mf2_ad_impression_callback', requestContext);
                }
              },
              clicked: () {
                if (_current(generation)) {
                  telemetry('mf2_ad_clicked', requestContext);
                }
              },
            ),
          );
          if (!_current(generation) || !_loading) {
            _dispose(handle);
            return;
          }
          _pending = handle;
          _requested = true;
          _log('mf2_ad_request_attempted');
          await handle.load();
        } on Object catch (error) {
          _fail(
            generation,
            error is AdFailure
                ? error
                : AdFailure('invocation_error', message: error.toString()),
          );
        }
      }),
    );
  }

  bool _current(int generation) => !_disposed && generation == _generation;
  void _fail(int generation, AdFailure error) {
    if (!_current(generation) || !_loading) return;
    _deadline?.cancel();
    _loading = false;
    ++_generation;
    final pending = _pending;
    _pending = null;
    if (pending != null) _dispose(pending);
    _failure = error;
    _log(_requested ? 'mf2_ad_load_result' : 'mf2_ad_decision', {
      'result': _requested ? 'failed' : 'load_blocked',
      ...error.parameters,
    });
    ++_failures;
    if (retry && error.retryable && _enabled) {
      _retryTimer = Timer(retryDelay(_failures), () {
        _retryTimer = null;
        ensureLoaded();
      });
    }
    notifyListeners();
  }

  static Duration retryDelay(int attempt) => Duration(
    seconds: const [5, 15, 30, 60, 120, 300][(attempt - 1).clamp(0, 5)],
  );
  void _cancelPending(String reason) {
    ++_generation;
    _deadline?.cancel();
    _loading = false;
    if (_requested) {
      _log('mf2_ad_load_result', {'result': 'cancelled', 'reason': reason});
    }
    final pending = _pending;
    _pending = null;
    if (pending != null) _dispose(pending);
  }

  AdHandle? takeAd() {
    final result = _ad;
    _ad = null;
    return result;
  }

  void discard(String reason) {
    _retryTimer?.cancel();
    if (_loading) _cancelPending(reason);
    final ad = takeAd();
    ++_generation;
    if (ad != null) {
      _log('mf2_ad_disposed', {'reason': reason});
      _dispose(ad);
    }
    notifyListeners();
  }

  void _dispose(AdHandle ad) {
    unawaited(
      Future<void>.sync(ad.dispose).catchError((Object error) {
        _log('mf2_ad_dispose_failed', {'error_kind': 'invocation_error'});
      }),
    );
  }

  @override
  void dispose() {
    if (_disposed) return;
    _enabled = false;
    _retryTimer?.cancel();
    if (_loading) _cancelPending('disposed');
    final ad = takeAd();
    if (ad != null) _dispose(ad);
    _disposed = true;
    ++_generation;
    super.dispose();
  }
}
