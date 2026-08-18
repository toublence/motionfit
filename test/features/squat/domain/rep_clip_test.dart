import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motionfit_squat/features/squat/domain/services/rep_clip.dart';

void main() {
  group('RepClipWindow', () {
    test('clamps padded bounds to the video duration', () {
      final window = RepClipWindow.forRep(
        repStart: const Duration(milliseconds: 300),
        repEnd: const Duration(milliseconds: 9700),
        videoDuration: const Duration(seconds: 10),
      );

      expect(window.start, Duration.zero);
      expect(window.end, const Duration(seconds: 10));
      expect(window.duration, const Duration(seconds: 10));
    });

    test('collapses an out-of-range rep to a valid empty window', () {
      final window = RepClipWindow.forRep(
        repStart: const Duration(seconds: 12),
        repEnd: const Duration(seconds: 14),
        videoDuration: const Duration(seconds: 10),
      );

      expect(window.start, const Duration(seconds: 10));
      expect(window.end, const Duration(seconds: 10));
    });
  });

  group('RepClipPlaybackController', () {
    test('Rep 3 play seeks to its padded timestamp before playing', () async {
      final player = _FakeRepClipPlayer();
      final controller = RepClipPlaybackController(
        player: player,
        window: RepClipWindow.forRep(
          repStart: const Duration(seconds: 10),
          repEnd: const Duration(seconds: 12),
          videoDuration: const Duration(seconds: 30),
        ),
      );

      await controller.play();

      expect(player.operations, ['seek:9200', 'play']);
      expect(player.position, const Duration(milliseconds: 9200));
      expect(player.isPlaying, isTrue);
      controller.dispose();
    });

    test('automatically pauses when playback reaches the clip end', () async {
      final player = _FakeRepClipPlayer();
      final controller = RepClipPlaybackController(
        player: player,
        window: const RepClipWindow(
          start: Duration(seconds: 2),
          end: Duration(seconds: 5),
        ),
      );
      await controller.play();

      player.moveTo(const Duration(milliseconds: 4999));
      expect(player.pauseCalls, 0);

      player.moveTo(const Duration(seconds: 5));
      expect(player.pauseCalls, 1);
      expect(player.isPlaying, isFalse);
      controller.dispose();
    });

    test('replay seeks back to the clip start', () async {
      final player = _FakeRepClipPlayer();
      final controller = RepClipPlaybackController(
        player: player,
        window: const RepClipWindow(
          start: Duration(seconds: 3),
          end: Duration(seconds: 6),
        ),
      );
      await controller.play();
      player.moveTo(const Duration(seconds: 6));

      await controller.replay();

      expect(player.seekPositions, const [
        Duration(seconds: 3),
        Duration(seconds: 3),
      ]);
      expect(player.playCalls, 2);
      expect(player.position, const Duration(seconds: 3));
      expect(player.isPlaying, isTrue);
      controller.dispose();
    });

    test('calls onPlay once for each successful play only', () async {
      var callbacks = 0;
      final successfulPlayer = _FakeRepClipPlayer();
      final successfulController = RepClipPlaybackController(
        player: successfulPlayer,
        window: const RepClipWindow(
          start: Duration(seconds: 1),
          end: Duration(seconds: 2),
        ),
        onPlay: () => callbacks++,
      );

      await successfulController.play();
      expect(callbacks, 1);
      await successfulController.replay();
      expect(callbacks, 2);
      expect(successfulPlayer.playCalls, 2);

      final failingPlayer = _FakeRepClipPlayer(failPlay: true);
      final failingController = RepClipPlaybackController(
        player: failingPlayer,
        window: const RepClipWindow(
          start: Duration(seconds: 1),
          end: Duration(seconds: 2),
        ),
        onPlay: () => callbacks++,
      );

      await expectLater(failingController.play(), throwsStateError);
      expect(callbacks, 2);

      successfulController.dispose();
      failingController.dispose();
    });
  });
}

class _FakeRepClipPlayer implements RepClipPlayer {
  _FakeRepClipPlayer({this.failPlay = false});

  final bool failPlay;
  final Set<VoidCallback> _listeners = {};
  final List<String> operations = [];
  final List<Duration> seekPositions = [];

  Duration _position = Duration.zero;
  bool _isPlaying = false;
  int playCalls = 0;
  int pauseCalls = 0;

  @override
  Duration get position => _position;

  @override
  bool get isPlaying => _isPlaying;

  @override
  void addListener(VoidCallback listener) => _listeners.add(listener);

  @override
  void removeListener(VoidCallback listener) => _listeners.remove(listener);

  @override
  Future<void> seekTo(Duration position) {
    _position = position;
    seekPositions.add(position);
    operations.add('seek:${position.inMilliseconds}');
    return Future.value();
  }

  @override
  Future<void> play() {
    playCalls++;
    operations.add('play');
    if (failPlay) return Future.error(StateError('play failed'));
    _isPlaying = true;
    return Future.value();
  }

  @override
  Future<void> pause() {
    pauseCalls++;
    operations.add('pause');
    _isPlaying = false;
    return Future.value();
  }

  void moveTo(Duration position) {
    _position = position;
    for (final listener in _listeners.toList(growable: false)) {
      listener();
    }
  }
}
