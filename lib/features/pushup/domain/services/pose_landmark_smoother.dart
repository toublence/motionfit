import 'dart:math' as math;

import 'package:motionfit_squat/features/pushup/domain/models/pose_frame.dart';

/// Smooths display-only landmarks without delaying the rep detector.
///
/// Low-confidence points briefly keep their last reliable position while their
/// confidence decays. A long frame gap resets the filter so an old pose can
/// never be blended into a newly acquired person.
class PoseLandmarkSmoother {
  PoseLandmarkSmoother({
    this.maximumGapUs = 250000,
    this.minimumTrackingConfidence = 0.15,
  });

  final int maximumGapUs;
  final double minimumTrackingConfidence;

  List<PoseLandmark>? _previous;
  int? _lastTimestampUs;

  List<PoseLandmark> smooth(List<PoseLandmark> landmarks, int timestampUs) {
    if (landmarks.length < 33) {
      reset();
      return const [];
    }

    final current = landmarks.take(33).toList(growable: false);
    final previous = _previous;
    final previousTimestampUs = _lastTimestampUs;
    if (previous == null ||
        previousTimestampUs == null ||
        timestampUs <= previousTimestampUs ||
        timestampUs - previousTimestampUs > maximumGapUs) {
      _previous = current;
      _lastTimestampUs = timestampUs;
      return current;
    }

    final smoothed = List<PoseLandmark>.generate(
      33,
      (index) => _smoothPoint(previous[index], current[index]),
      growable: false,
    );
    _previous = smoothed;
    _lastTimestampUs = timestampUs;
    return smoothed;
  }

  void reset() {
    _previous = null;
    _lastTimestampUs = null;
  }

  PoseLandmark _smoothPoint(PoseLandmark previous, PoseLandmark current) {
    if (!_hasFiniteCoordinates(current)) {
      return PoseLandmark(
        x: previous.x,
        y: previous.y,
        z: previous.z,
        visibility: 0,
        presence: 0,
      );
    }
    if (!_hasFiniteCoordinates(previous)) return current;

    final confidence = current.confidence.clamp(0.0, 1.0).toDouble();
    final confidenceAlpha = confidence >= previous.confidence ? 0.65 : 0.42;
    if (confidence < minimumTrackingConfidence) {
      return PoseLandmark(
        x: previous.x,
        y: previous.y,
        z: previous.z,
        visibility: _lerp(
          previous.visibility,
          current.visibility,
          confidenceAlpha,
        ),
        presence: _lerp(previous.presence, current.presence, confidenceAlpha),
      );
    }

    final distance = math.sqrt(
      math.pow(current.x - previous.x, 2) + math.pow(current.y - previous.y, 2),
    );
    final motionBoost = (distance * 4).clamp(0.0, 0.35).toDouble();
    final positionAlpha = (0.18 + confidence * 0.22 + motionBoost)
        .clamp(0.18, 0.75)
        .toDouble();
    return PoseLandmark(
      x: _lerp(previous.x, current.x, positionAlpha),
      y: _lerp(previous.y, current.y, positionAlpha),
      z: _lerp(previous.z, current.z, positionAlpha),
      visibility: _lerp(
        previous.visibility,
        current.visibility,
        confidenceAlpha,
      ),
      presence: _lerp(previous.presence, current.presence, confidenceAlpha),
    );
  }

  bool _hasFiniteCoordinates(PoseLandmark point) =>
      point.x.isFinite && point.y.isFinite && point.z.isFinite;

  double _lerp(double from, double to, double amount) =>
      from + (to - from) * amount;
}
