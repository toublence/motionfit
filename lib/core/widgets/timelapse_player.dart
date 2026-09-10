import 'dart:async';

import 'package:flutter/material.dart';
import 'package:motionfit_squat/app/localization/generated/app_localizations.dart';
import 'package:motionfit_squat/app/theme/motionfit_tokens.dart';

/// Plays an ordered list of frames back as an in-app timelapse.
///
/// Frames are rendered by the caller, so Body Progress can hand over photos and
/// Form Progress can hand over drawn poses. Playback stays inside the app: no
/// video file is produced here.
class TimelapsePlayer extends StatefulWidget {
  const TimelapsePlayer({
    required this.frameCount,
    required this.frameBuilder,
    required this.captionBuilder,
    this.aspectRatio = 3 / 4,
    this.autoPlay = false,
    super.key,
  });

  final int frameCount;
  final Widget Function(BuildContext context, int index) frameBuilder;
  final Widget Function(BuildContext context, int index) captionBuilder;
  final double aspectRatio;
  final bool autoPlay;

  @override
  State<TimelapsePlayer> createState() => _TimelapsePlayerState();
}

class _TimelapsePlayerState extends State<TimelapsePlayer> {
  static const _speeds = <double>[0.5, 1, 2];

  Timer? _timer;
  int _index = 0;
  int _speedIndex = 1;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoPlay && widget.frameCount >= 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _play();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(TimelapsePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_index >= widget.frameCount) {
      _index = widget.frameCount == 0 ? 0 : widget.frameCount - 1;
    }
    if (widget.autoPlay && oldWidget.frameCount < 2 && widget.frameCount >= 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _play();
      });
    }
  }

  Duration get _interval =>
      Duration(milliseconds: (700 / _speeds[_speedIndex]).round());

  void _play() {
    if (widget.frameCount < 2) return;
    _timer?.cancel();
    setState(() {
      _playing = true;
      if (_index >= widget.frameCount - 1) _index = 0;
    });
    _timer = Timer.periodic(_interval, (timer) {
      if (!mounted) return;
      if (_index >= widget.frameCount - 1) {
        timer.cancel();
        setState(() => _playing = false);
        return;
      }
      setState(() => _index++);
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _playing = false);
  }

  void _cycleSpeed() {
    setState(() => _speedIndex = (_speedIndex + 1) % _speeds.length);
    if (_playing) _play();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (widget.frameCount == 0) return const SizedBox.shrink();
    final index = _index.clamp(0, widget.frameCount - 1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(context.tokens.radiusLg),
          child: AspectRatio(
            aspectRatio: widget.aspectRatio,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: KeyedSubtree(
                    key: ValueKey(index),
                    child: widget.frameBuilder(context, index),
                  ),
                ),
                PositionedDirectional(
                  start: 0,
                  end: 0,
                  bottom: 0,
                  child: Container(
                    color: context.tokens.cameraOverlay,
                    padding: EdgeInsets.symmetric(
                      horizontal: context.tokens.space12,
                      vertical: context.tokens.spaceSm,
                    ),
                    child: DefaultTextStyle.merge(
                      style: const TextStyle(color: Colors.white),
                      child: widget.captionBuilder(context, index),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: context.tokens.space12),
        Slider(
          value: index.toDouble(),
          max: (widget.frameCount - 1).toDouble(),
          divisions: widget.frameCount > 1 ? widget.frameCount - 1 : null,
          label: l10n.progressTimelapseFrameOf(index + 1, widget.frameCount),
          onChanged: (value) {
            _pause();
            setState(() => _index = value.round());
          },
        ),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _playing
                    ? _pause
                    : (index >= widget.frameCount - 1 ? _play : _play),
                icon: Icon(
                  _playing
                      ? Icons.pause_rounded
                      : index >= widget.frameCount - 1
                      ? Icons.replay_rounded
                      : Icons.play_arrow_rounded,
                ),
                label: Text(
                  _playing
                      ? l10n.progressTimelapsePause
                      : index >= widget.frameCount - 1
                      ? l10n.progressTimelapseReplay
                      : l10n.progressTimelapsePlay,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            SizedBox(width: context.tokens.spaceSm),
            OutlinedButton(
              onPressed: _cycleSpeed,
              child: Text(
                '${l10n.progressTimelapseSpeed} ${_speeds[_speedIndex]}x',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
