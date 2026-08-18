import 'dart:async';
import 'dart:convert';

import 'package:motionfit_squat/features/plank/workout/domain/models/pose_frame.dart';
import 'package:motionfit_squat/features/plank/workout/domain/models/workout_enums.dart';
import 'package:motionfit_squat/features/plank/workout/domain/services/pose_engine.dart';

class ReplayPoseEngine implements PoseEngine {
  ReplayPoseEngine(this._sourceFrames, {this.speed = 1});

  factory ReplayPoseEngine.fromJson(String source, {double speed = 1}) {
    final root = jsonDecode(source);
    final frames = (root is Map ? root['frames'] : root) as List;
    return ReplayPoseEngine(
      frames
          .cast<Map>()
          .map((map) => PoseFrame.fromMap(map.cast<Object?, Object?>()))
          .toList(growable: false),
      speed: speed,
    );
  }

  final List<PoseFrame> _sourceFrames;
  final double speed;
  final StreamController<PoseFrame> _controller =
      StreamController<PoseFrame>.broadcast(sync: true);
  Timer? _timer;
  int _index = 0;
  bool _running = false;
  bool _paused = false;

  @override
  Stream<PoseFrame> get frames => _controller.stream;

  @override
  int? get previewTextureId => null;

  @override
  bool get isRunning => _running && !_paused;

  @override
  Future<void> start(PoseEngineConfig config) async {
    _timer?.cancel();
    _index = 0;
    _running = true;
    _paused = false;
    _scheduleNext();
  }

  void _scheduleNext() {
    if (!_running || _paused || _index >= _sourceFrames.length) return;
    final current = _sourceFrames[_index];
    final previous = _index == 0 ? null : _sourceFrames[_index - 1];
    final sourceDelay = previous == null
        ? Duration.zero
        : Duration(microseconds: current.timestampUs - previous.timestampUs);
    final micros = (sourceDelay.inMicroseconds / speed).round();
    _timer = Timer(
      Duration(microseconds: micros.clamp(0, 1000000).toInt()),
      () {
        if (!_running || _paused) return;
        _controller.add(current);
        _index++;
        _scheduleNext();
      },
    );
  }

  void emitForTest(PoseFrame frame) => _controller.add(frame);

  @override
  Future<void> pause() async {
    _paused = true;
    _timer?.cancel();
  }

  @override
  Future<void> resume() async {
    if (!_running) return;
    _paused = false;
    _scheduleNext();
  }

  @override
  Future<void> switchCamera(CameraSelection camera) async {}

  @override
  Future<void> setModelQuality(PoseModelQuality quality) async {}

  @override
  Future<void> setTargetInferenceFps(int fps) async {}

  @override
  Future<void> dispose() async {
    _running = false;
    _timer?.cancel();
    await _controller.close();
  }
}
