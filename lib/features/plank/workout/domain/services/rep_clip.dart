import 'dart:async';

import 'package:flutter/foundation.dart';

class RepClipWindow {
  const RepClipWindow({required this.start, required this.end});

  static const defaultPadding = Duration(milliseconds: 800);

  final Duration start;
  final Duration end;

  Duration get duration => end - start;

  factory RepClipWindow.forRep({
    required Duration repStart,
    required Duration repEnd,
    required Duration videoDuration,
    Duration padding = defaultPadding,
  }) {
    final safeDuration = videoDuration.isNegative
        ? Duration.zero
        : videoDuration;
    final paddedStart = repStart - padding;
    final start = paddedStart.isNegative ? Duration.zero : paddedStart;
    final paddedEnd = repEnd + padding;
    final end = paddedEnd > safeDuration ? safeDuration : paddedEnd;
    final clampedStart = start > end ? end : start;
    return RepClipWindow(start: clampedStart, end: end);
  }
}

abstract interface class RepClipPlayer {
  Duration get position;
  bool get isPlaying;

  void addListener(VoidCallback listener);
  void removeListener(VoidCallback listener);
  Future<void> seekTo(Duration position);
  Future<void> play();
  Future<void> pause();
}

class RepClipPlaybackController {
  RepClipPlaybackController({
    required this.player,
    required this.window,
    this.onPlay,
  }) {
    player.addListener(_onPlayerChanged);
  }

  final RepClipPlayer player;
  final RepClipWindow window;
  final VoidCallback? onPlay;
  bool _starting = false;
  bool _pausingAtEnd = false;
  bool _disposed = false;
  Future<void>? _endPauseOperation;

  Future<void> play() async {
    if (_disposed || _starting) return;
    final endPause = _endPauseOperation;
    if (endPause != null) await endPause;
    if (_disposed || _starting) return;
    _starting = true;
    try {
      await player.seekTo(window.start);
      await player.play();
      onPlay?.call();
    } finally {
      _starting = false;
    }
  }

  Future<void> replay() => play();

  void _onPlayerChanged() {
    if (_disposed ||
        _pausingAtEnd ||
        !player.isPlaying ||
        player.position < window.end) {
      return;
    }
    _pausingAtEnd = true;
    final operation = () async {
      try {
        await player.pause();
        if (player.position != window.end) {
          await player.seekTo(window.end);
        }
      } finally {
        _pausingAtEnd = false;
      }
    }();
    _endPauseOperation = operation;
    unawaited(
      operation.whenComplete(() {
        if (identical(_endPauseOperation, operation)) {
          _endPauseOperation = null;
        }
      }),
    );
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    player.removeListener(_onPlayerChanged);
  }
}
