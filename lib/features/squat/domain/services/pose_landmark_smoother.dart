import 'dart:math' as math;

import 'package:motionfit_squat/features/squat/domain/models/pose_frame.dart';

/// Smooths display-only landmarks without delaying the rep detector.
///
/// Low-confidence points briefly keep their last reliable position while their
/// confidence decays. A long frame gap resets the filter so an old pose can
/// never be blended into a newly acquired person.
class PoseLandmarkSmoother {
  PoseLandmarkSmoother({
    this.maximumGapUs = 250000,
    this.minimumTrackingConfidence = 0.15,
    this.minimumReliableConfidence = 0.25,
    this.confidenceHoldUs = 350000,
  });

  final int maximumGapUs;
  final double minimumTrackingConfidence;
  final double minimumReliableConfidence;
  final int confidenceHoldUs;

  List<PoseLandmark>? _previous;
  int? _lastTimestampUs;
  List<PoseLandmark?>? _lastReliable;
  List<int?>? _lastReliableAtUs;

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
      _seedReliable(current, timestampUs);
      return current;
    }

    final smoothed = List<PoseLandmark>.generate(
      33,
      (index) =>
          _smoothPoint(previous[index], current[index], index, timestampUs),
      growable: false,
    );
    for (var index = 0; index < current.length; index++) {
      if (_hasFiniteCoordinates(current[index]) &&
          current[index].confidence >= minimumReliableConfidence) {
        _lastReliable![index] = smoothed[index];
        _lastReliableAtUs![index] = timestampUs;
      }
    }
    _previous = smoothed;
    _lastTimestampUs = timestampUs;
    return smoothed;
  }

  void reset() {
    _previous = null;
    _lastTimestampUs = null;
    _lastReliable = null;
    _lastReliableAtUs = null;
  }

  PoseLandmark _smoothPoint(
    PoseLandmark previous,
    PoseLandmark current,
    int index,
    int timestampUs,
  ) {
    if (!_hasFiniteCoordinates(current)) {
      return _heldPoint(previous, index, timestampUs) ??
          PoseLandmark(
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
    if (confidence < minimumReliableConfidence) {
      final held = _heldPoint(previous, index, timestampUs);
      if (held != null) return held;
      if (confidence < minimumTrackingConfidence) {
        return PoseLandmark(
          x: previous.x,
          y: previous.y,
          z: previous.z,
          visibility: current.visibility,
          presence: current.presence,
        );
      }
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

  void _seedReliable(List<PoseLandmark> landmarks, int timestampUs) {
    _lastReliable = List<PoseLandmark?>.filled(33, null);
    _lastReliableAtUs = List<int?>.filled(33, null);
    for (var index = 0; index < landmarks.length; index++) {
      final point = landmarks[index];
      if (_hasFiniteCoordinates(point) &&
          point.confidence >= minimumReliableConfidence) {
        _lastReliable![index] = point;
        _lastReliableAtUs![index] = timestampUs;
      }
    }
  }

  PoseLandmark? _heldPoint(PoseLandmark previous, int index, int timestampUs) {
    final reliable = _lastReliable?[index];
    final reliableAtUs = _lastReliableAtUs?[index];
    if (reliable == null || reliableAtUs == null || confidenceHoldUs <= 0) {
      return null;
    }
    final ageUs = timestampUs - reliableAtUs;
    if (ageUs < 0 || ageUs > confidenceHoldUs) return null;
    final ageRatio = (ageUs / confidenceHoldUs).clamp(0.0, 1.0).toDouble();
    final heldConfidence = _lerp(
      reliable.confidence,
      minimumTrackingConfidence,
      ageRatio,
    );
    return PoseLandmark(
      x: previous.x,
      y: previous.y,
      z: previous.z,
      visibility: heldConfidence,
      presence: heldConfidence,
    );
  }

  double _lerp(double from, double to, double amount) =>
      from + (to - from) * amount;
}
