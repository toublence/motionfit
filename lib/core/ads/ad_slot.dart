import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../providers.dart';
import 'ad_sdk.dart';
import 'ad_slot_controller.dart';

class AdSlot extends ConsumerStatefulWidget {
  const AdSlot({
    required this.format,
    required this.placement,
    this.active = true,
    this.inline = false,
    super.key,
  });
  final AdFormat format;
  final String placement;
  final bool active;
  final bool inline;
  @override
  ConsumerState<AdSlot> createState() => _AdSlotState();
}

class _AdSlotState extends ConsumerState<AdSlot> {
  final _anchor = GlobalKey();
  AdSlotController? _controller;
  ScrollPosition? _scroll;
  bool _visible = false;
  bool _nearViewport = false;
  String? _renderedRequest;
  bool? _renderedVisible;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final position = Scrollable.maybeOf(context)?.position;
    if (!identical(position, _scroll)) {
      _scroll?.removeListener(_scrollChanged);
      _scroll = position;
      _scroll?.addListener(_scrollChanged);
    }
    _controller ??= AdSlotController(
      service: ref.read(adServiceProvider),
      preferredFormat: widget.format,
      placement: widget.placement,
      deferDisposal: (f) =>
          WidgetsBinding.instance.addPostFrameCallback((_) => f()),
      templateStyle: _style(Theme.of(context).colorScheme),
    )..addListener(_changed);
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  NativeTemplateStyle _style(ColorScheme c) => NativeTemplateStyle(
    templateType: TemplateType.small,
    mainBackgroundColor: c.surface,
    cornerRadius: 10,
    callToActionTextStyle: NativeTemplateTextStyle(
      textColor: c.onPrimary,
      backgroundColor: c.primary,
      style: NativeTemplateFontStyle.bold,
      size: 14,
    ),
    primaryTextStyle: NativeTemplateTextStyle(
      textColor: c.onSurface,
      backgroundColor: c.surface,
      style: NativeTemplateFontStyle.bold,
      size: 15,
    ),
    secondaryTextStyle: NativeTemplateTextStyle(
      textColor: c.onSurfaceVariant,
      backgroundColor: c.surface,
      size: 12,
    ),
    tertiaryTextStyle: NativeTemplateTextStyle(
      textColor: c.onSurfaceVariant,
      backgroundColor: c.surface,
      size: 12,
    ),
  );
  void _scrollChanged() =>
      WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  void _measure() {
    if (!mounted) return;
    final box = _anchor.currentContext?.findRenderObject();
    if (box is RenderBox && box.hasSize && box.attached) {
      final top = box.localToGlobal(Offset.zero).dy;
      _visible =
          top < MediaQuery.sizeOf(context).height &&
          top + math.max(1, box.size.height) >= 0;
      _nearViewport =
          top <= MediaQuery.sizeOf(context).height + 120 &&
          top + math.max(1, box.size.height) >= -120;
      _controller?.setActive(widget.active && _nearViewport);
      final controller = _controller;
      final request = controller?.ad == null ? null : controller?.requestId;
      if (request != _renderedRequest || _visible != _renderedVisible) {
        if (request != null || _renderedRequest != null) {
          ref.read(adServiceProvider).record('mf2_ad_view_state', {
            'ad_format': controller!.format.name,
            'ad_placement': widget.placement,
            'request_id': request ?? _renderedRequest!,
            'state': request == null ? 'detached' : 'attached',
            'visible': _visible,
          });
        }
        _renderedRequest = request;
        _renderedVisible = _visible;
      }
    }
  }

  @override
  void didUpdateWidget(covariant AdSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller?.setActive(widget.active && _nearViewport);
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = math.min(constraints.maxWidth, 720.0);
      if (width.isFinite && width > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _controller?.setWidth(width);
            _measure();
          }
        });
      }
      final ad = _controller?.ad;
      Widget body = const SizedBox.shrink();
      if (widget.active && ad != null) {
        final banner = _controller!.format == AdFormat.banner;
        final height = banner
            ? _controller!.size!.height.toDouble()
            : Theme.of(context).platform == TargetPlatform.android
            ? width / 4
            : 101.0;
        body = Padding(
          padding: widget.inline
              ? const EdgeInsets.symmetric(vertical: 24)
              : EdgeInsets.zero,
          child: Center(
            child: SizedBox(
              key: ValueKey(_controller!.requestId),
              width: banner ? _controller!.size!.width.toDouble() : width,
              height: height,
              child: ClipRect(child: ad.buildWidget()),
            ),
          ),
        );
      }
      return SizedBox(key: _anchor, child: body);
    },
  );
  @override
  void dispose() {
    _scroll?.removeListener(_scrollChanged);
    _controller?.removeListener(_changed);
    _controller?.dispose();
    super.dispose();
  }
}
