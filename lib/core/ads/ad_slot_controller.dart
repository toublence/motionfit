import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_failure.dart';
import 'ad_loader.dart';
import 'ad_sdk.dart';
import 'ad_service.dart';

/// View-ad lifetime, shared by banner slots and native -> banner fallback.
class AdSlotController extends ChangeNotifier {
  AdSlotController({
    required this.service,
    required this.preferredFormat,
    required this.placement,
    this.templateStyle,
    void Function(VoidCallback)? deferDisposal,
  }) : _format = preferredFormat,
       _defer = deferDisposal ?? ((f) => f()) {
    service.addListener(_sync);
  }
  final AdService service;
  final AdFormat preferredFormat;
  final String placement;
  final NativeTemplateStyle? templateStyle;
  final void Function(VoidCallback) _defer;
  AdFormat _format;
  AdLoader? _loader;
  AdSize? _size;
  int? _width;
  int _generation = 0;
  bool _active = false;
  bool _disposed = false;
  bool _missingReported = false;
  AdFormat get format => _format;
  AdHandle? get ad =>
      service.ready && service.visible && _active ? _loader?.ad : null;
  AdSize? get size => _size;
  bool get loading => _loader?.loading ?? false;
  String? get requestId => _loader?.requestId;
  void setActive(bool value) {
    if (_disposed || _active == value) return;
    _active = value;
    _sync();
  }

  void setWidth(double value) {
    final width = value.floor();
    if (_disposed || width <= 0 || width == _width) return;
    final resized = _width != null;
    _width = width;
    if (resized && _format == AdFormat.banner) {
      _retire('resized');
      _size = null;
    }
    _sync();
  }

  void _sync() {
    if (_disposed) return;
    final enabled =
        _active && service.ready && service.loadsAllowed && _width != null;
    if (!service.ready && _loader?.ad != null) {
      _retire('consent_change');
    }
    if (_loader == null && enabled) {
      final unit = service.unitFor(_format);
      if (unit == null) {
        if (!_missingReported) {
          service.record('mf2_ad_decision', {
            'ad_format': _format.name,
            'ad_placement': placement,
            'result': 'skipped',
            'skip_reason': 'unit_unconfigured',
          });
          _missingReported = true;
        }
        if (_format == AdFormat.native &&
            service.unitFor(AdFormat.banner) != null) {
          _format = AdFormat.banner;
          _sync();
        }
        return;
      }
      final generation = ++_generation;
      final format = _format;
      final width = _width!;
      _loader = AdLoader(
        format: format,
        placement: placement,
        unitId: unit,
        retry: format == AdFormat.banner,
        telemetry: service.record,
        create: (callbacks) async {
          AdSize? size;
          if (format == AdFormat.banner) {
            size = await service.sdk.bannerSize(width);
            if (size == null) {
              throw const AdFailure('adaptive_size_unavailable');
            }
          }
          if (_disposed || generation != _generation || !callbacks.isActive()) {
            throw const AdFailure('inactive');
          }
          _size = size;
          return service.createAd(
            format: format,
            unitId: unit,
            callbacks: callbacks,
            size: size,
            templateStyle: templateStyle,
          );
        },
      )..addListener(_changed);
    }
    _loader?.setEnabled(enabled);
    notifyListeners();
  }

  void _changed() {
    if (_disposed) return;
    if (_format == AdFormat.native && _loader?.failure != null) {
      service.record('mf2_ad_fallback', {
        ..._loader!.context,
        'fallback_format': 'banner',
        ..._loader!.failure!.parameters,
      });
      _retire();
      _format = AdFormat.banner;
      _sync();
      return;
    }
    notifyListeners();
  }

  void _retire([String reason = 'replaced']) {
    ++_generation;
    final old = _loader;
    _loader = null;
    if (old == null) return;
    old.removeListener(_changed);
    // Remove an attached view on the next frame before disposing the SDK ad.
    final attached = old.takeAd();
    if (attached != null) {
      service.record('mf2_ad_disposed', {...old.context, 'reason': reason});
    }
    old.setEnabled(false);
    scheduleMicrotask(old.dispose);
    if (attached != null) {
      _defer(() => unawaited(attached.dispose().catchError((Object _) {})));
    }
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    service.removeListener(_sync);
    _retire('slot_disposed');
    super.dispose();
  }
}
