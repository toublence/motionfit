import 'dart:math' as math;

import 'package:motionfit_squat/features/pushup/domain/models/calibration_profile.dart';
import 'package:motionfit_squat/features/pushup/domain/models/pose_frame.dart';
import 'package:motionfit_squat/features/pushup/domain/models/pushup_metrics.dart';
import 'package:motionfit_squat/features/pushup/domain/models/workout_enums.dart';
import 'package:motionfit_squat/features/pushup/domain/services/one_euro_filter.dart';
import 'package:motionfit_squat/features/pushup/domain/services/pushup_detection_config.dart';

/// Extracts push-up motion features. The persisted metric field names are kept
/// compatible with the original app schema: knee angles contain elbow angles,
/// hip angles contain shoulder-hip-ankle body-line angles, and hip motion
/// contains shoulder motion.
class PushupFeatureExtractor {
  PushupFeatureExtractor(this.config);

  final PushupDetectionConfig config;
  final _elbowFilter = OneEuroFilter(minimumCutoff: 1.2, beta: 0.025);
  final _bodyLineFilter = OneEuroFilter(minimumCutoff: 1.1, beta: 0.02);
  final _shoulderYFilter = OneEuroFilter(minimumCutoff: 1.0, beta: 0.02);
  final _hipYFilter = OneEuroFilter(minimumCutoff: 1.0, beta: 0.02);
  final List<PushupMetrics> _recent = [];
  PushupMetrics? _previous;

  PushupMetrics? extract(PoseFrame frame, [CalibrationProfile? profile]) {
    if (!frame.hasCompletePose ||
        frame.meanKeyConfidence < config.landmarkConfidenceFloor) {
      return null;
    }

    PoseLandmark imagePoint(int index) => frame.landmarks[index];
    final useWorld =
        frame.worldLandmarks.length >= 33 &&
        _hasUsableSide(frame.worldLandmarks);
    PoseLandmark point(int index) =>
        useWorld ? frame.worldLandmarks[index] : frame.landmarks[index];

    final leftElbow = _jointAngle(
      point(PoseLandmarkIndex.leftShoulder),
      point(PoseLandmarkIndex.leftElbow),
      point(PoseLandmarkIndex.leftWrist),
      useDepth: useWorld,
    );
    final rightElbow = _jointAngle(
      point(PoseLandmarkIndex.rightShoulder),
      point(PoseLandmarkIndex.rightElbow),
      point(PoseLandmarkIndex.rightWrist),
      useDepth: useWorld,
    );
    final leftBodyLine = _jointAngle(
      point(PoseLandmarkIndex.leftShoulder),
      point(PoseLandmarkIndex.leftHip),
      point(PoseLandmarkIndex.leftAnkle),
      useDepth: useWorld,
    );
    final rightBodyLine = _jointAngle(
      point(PoseLandmarkIndex.rightShoulder),
      point(PoseLandmarkIndex.rightHip),
      point(PoseLandmarkIndex.rightAnkle),
      useDepth: useWorld,
    );

    final leftElbowConfidence = _minimumConfidence([
      point(PoseLandmarkIndex.leftShoulder),
      point(PoseLandmarkIndex.leftElbow),
      point(PoseLandmarkIndex.leftWrist),
    ]);
    final rightElbowConfidence = _minimumConfidence([
      point(PoseLandmarkIndex.rightShoulder),
      point(PoseLandmarkIndex.rightElbow),
      point(PoseLandmarkIndex.rightWrist),
    ]);
    final leftBodyConfidence = _minimumConfidence([
      point(PoseLandmarkIndex.leftShoulder),
      point(PoseLandmarkIndex.leftHip),
      point(PoseLandmarkIndex.leftAnkle),
    ]);
    final rightBodyConfidence = _minimumConfidence([
      point(PoseLandmarkIndex.rightShoulder),
      point(PoseLandmarkIndex.rightHip),
      point(PoseLandmarkIndex.rightAnkle),
    ]);
    final elbowAngle = _weightedPair(
      leftElbow,
      leftElbowConfidence,
      rightElbow,
      rightElbowConfidence,
    );
    final bodyLineAngle = _weightedPair(
      leftBodyLine,
      leftBodyConfidence,
      rightBodyLine,
      rightBodyConfidence,
    );
    if (elbowAngle == null || bodyLineAngle == null) return null;

    final shoulder = _weightedCenter(
      imagePoint(PoseLandmarkIndex.leftShoulder),
      imagePoint(PoseLandmarkIndex.rightShoulder),
    );
    final hip = _weightedCenter(
      imagePoint(PoseLandmarkIndex.leftHip),
      imagePoint(PoseLandmarkIndex.rightHip),
    );
    final ankle = _weightedCenter(
      imagePoint(PoseLandmarkIndex.leftAnkle),
      imagePoint(PoseLandmarkIndex.rightAnkle),
    );
    if (shoulder == null || hip == null || ankle == null) return null;

    final bodyScale = _distance(shoulder, ankle).clamp(0.1, 2.0).toDouble();
    final confidence = [
      frame.meanKeyConfidence,
      math.max(leftElbowConfidence, rightElbowConfidence),
      math.max(leftBodyConfidence, rightBodyConfidence),
    ].reduce(math.min);
    final filteredElbow = _elbowFilter.filter(
      elbowAngle,
      frame.timestampUs,
      confidence: confidence,
    );
    final filteredBodyLine = _bodyLineFilter.filter(
      bodyLineAngle,
      frame.timestampUs,
      confidence: confidence,
    );
    final filteredShoulderY = _shoulderYFilter.filter(
      shoulder.y,
      frame.timestampUs,
      confidence: confidence,
    );
    final filteredHipY = _hipYFilter.filter(
      hip.y,
      frame.timestampUs,
      confidence: confidence,
    );
    final referenceScale = profile?.bodyScale ?? bodyScale;
    final shoulderDrop = profile == null
        ? 0.0
        : (filteredShoulderY - profile.baselineShoulderY) / referenceScale;
    var shoulderVelocity = 0.0;
    if (_previous != null && frame.timestampUs > _previous!.timestampUs) {
      final dt = (frame.timestampUs - _previous!.timestampUs) / 1000000.0;
      if (dt <= 0.5) {
        shoulderVelocity = (shoulderDrop - _previous!.hipDrop) / dt;
      }
    }
    final hipRelativeMovement = profile == null
        ? 0.0
        : ((filteredHipY - profile.baselineHipY) / referenceScale) -
              shoulderDrop;
    final bodyLineDeviation = (180 - filteredBodyLine).abs();
    final leftFlare = _elbowFlare(
      imagePoint(PoseLandmarkIndex.leftShoulder),
      imagePoint(PoseLandmarkIndex.leftElbow),
      imagePoint(PoseLandmarkIndex.leftWrist),
      referenceScale,
    );
    final rightFlare = _elbowFlare(
      imagePoint(PoseLandmarkIndex.rightShoulder),
      imagePoint(PoseLandmarkIndex.rightElbow),
      imagePoint(PoseLandmarkIndex.rightWrist),
      referenceScale,
    );
    final elbowImbalance = leftElbow == null || rightElbow == null
        ? null
        : (leftElbow - rightElbow).abs() / 180;

    var metrics = PushupMetrics(
      timestampUs: frame.timestampUs,
      videoElapsedUs: frame.videoElapsedUs,
      confidence: confidence,
      leftKneeAngle: leftElbowConfidence >= config.landmarkConfidenceFloor
          ? leftElbow
          : null,
      rightKneeAngle: rightElbowConfidence >= config.landmarkConfidenceFloor
          ? rightElbow
          : null,
      kneeAngle: filteredElbow,
      leftHipAngle: leftBodyConfidence >= config.landmarkConfidenceFloor
          ? leftBodyLine
          : null,
      rightHipAngle: rightBodyConfidence >= config.landmarkConfidenceFloor
          ? rightBodyLine
          : null,
      hipAngle: filteredBodyLine,
      hipY: filteredHipY,
      shoulderY: filteredShoulderY,
      bodyScale: bodyScale,
      hipDrop: shoulderDrop,
      hipVelocity: shoulderVelocity,
      shoulderHipRelativeMovement: hipRelativeMovement,
      torsoLeanDegrees: bodyLineDeviation,
      leftHeelLift: hipRelativeMovement.abs(),
      rightHeelLift: hipRelativeMovement.abs(),
      kneeAlignmentDeviation: _maximumOptional(leftFlare, rightFlare),
      balanceDeviation: elbowImbalance,
      cameraAngle: profile?.cameraAngle ?? _cameraAngle(frame, bodyScale),
      biomechanics3d: useWorld,
    );
    metrics = _rejectOutliers(metrics);
    _recent.add(metrics);
    if (_recent.length > 3) _recent.removeAt(0);
    if (_recent.length == 3) {
      metrics = metrics.copyWith(
        kneeAngle: _median(_recent.map((value) => value.kneeAngle)),
        hipAngle: _median(_recent.map((value) => value.hipAngle)),
        hipDrop: _median(_recent.map((value) => value.hipDrop)),
        hipVelocity: _median(_recent.map((value) => value.hipVelocity)),
        torsoLeanDegrees: _median(
          _recent.map((value) => value.torsoLeanDegrees),
        ),
      );
    }
    _previous = metrics;
    return metrics;
  }

  double? _jointAngle(
    PoseLandmark a,
    PoseLandmark b,
    PoseLandmark c, {
    required bool useDepth,
  }) {
    if (_minimumConfidence([a, b, c]) < config.landmarkConfidenceFloor) {
      return null;
    }
    final abx = a.x - b.x;
    final aby = a.y - b.y;
    final abz = useDepth ? a.z - b.z : 0.0;
    final cbx = c.x - b.x;
    final cby = c.y - b.y;
    final cbz = useDepth ? c.z - b.z : 0.0;
    final denominator =
        math.sqrt(abx * abx + aby * aby + abz * abz) *
        math.sqrt(cbx * cbx + cby * cby + cbz * cbz);
    if (denominator < 1e-6) return null;
    final cosine = ((abx * cbx + aby * cby + abz * cbz) / denominator).clamp(
      -1.0,
      1.0,
    );
    return math.acos(cosine) * 180 / math.pi;
  }

  bool _hasUsableSide(List<PoseLandmark> points) {
    const sides = [
      [11, 13, 15, 23, 27],
      [12, 14, 16, 24, 28],
    ];
    return sides.any(
      (side) => side.every(
        (index) => points[index].confidence >= config.landmarkConfidenceFloor,
      ),
    );
  }

  double _minimumConfidence(List<PoseLandmark> points) =>
      points.map((point) => point.confidence).reduce(math.min);

  double? _weightedPair(
    double? left,
    double leftWeight,
    double? right,
    double rightWeight,
  ) {
    final validLeft =
        left != null && leftWeight >= config.landmarkConfidenceFloor;
    final validRight =
        right != null && rightWeight >= config.landmarkConfidenceFloor;
    if (!validLeft && !validRight) return null;
    if (!validLeft) return right;
    if (!validRight) return left;
    return (left * leftWeight + right * rightWeight) /
        (leftWeight + rightWeight);
  }

  _Point? _weightedCenter(PoseLandmark a, PoseLandmark b) {
    final aWeight = a.confidence >= config.landmarkConfidenceFloor
        ? a.confidence
        : 0.0;
    final bWeight = b.confidence >= config.landmarkConfidenceFloor
        ? b.confidence
        : 0.0;
    final total = aWeight + bWeight;
    if (total <= 0) return null;
    return _Point(
      (a.x * aWeight + b.x * bWeight) / total,
      (a.y * aWeight + b.y * bWeight) / total,
    );
  }

  double? _elbowFlare(
    PoseLandmark shoulder,
    PoseLandmark elbow,
    PoseLandmark wrist,
    double bodyScale,
  ) {
    if (_minimumConfidence([shoulder, elbow, wrist]) <
        config.landmarkConfidenceFloor) {
      return null;
    }
    final lineX = wrist.x - shoulder.x;
    final lineY = wrist.y - shoulder.y;
    final length = math.sqrt(lineX * lineX + lineY * lineY);
    if (length < 1e-6) return null;
    final distance =
        ((elbow.x - shoulder.x) * lineY - (elbow.y - shoulder.y) * lineX)
            .abs() /
        length;
    return distance / bodyScale;
  }

  CameraAngle _cameraAngle(PoseFrame frame, double bodyScale) {
    final left = frame.landmark(PoseLandmarkIndex.leftShoulder);
    final right = frame.landmark(PoseLandmarkIndex.rightShoulder);
    if (left == null || right == null) return CameraAngle.uncertain;
    final width = (left.x - right.x).abs() / bodyScale;
    if (width < 0.10) return CameraAngle.side;
    if (width > 0.25) return CameraAngle.front;
    return CameraAngle.oblique;
  }

  double? _maximumOptional(double? a, double? b) {
    if (a == null) return b;
    if (b == null) return a;
    return math.max(a, b);
  }

  PushupMetrics _rejectOutliers(PushupMetrics current) {
    final previous = _previous;
    if (previous == null || current.timestampUs <= previous.timestampUs) {
      return current;
    }
    final seconds = (current.timestampUs - previous.timestampUs) / 1000000.0;
    if (seconds > 0.5) return current;
    final angleLimit =
        config.maximumJointAngularVelocityDegreesPerSecond * seconds;
    final motionLimit = config.maximumHipDropVelocity * seconds;
    return current.copyWith(
      kneeAngle: current.kneeAngle
          .clamp(
            previous.kneeAngle - angleLimit,
            previous.kneeAngle + angleLimit,
          )
          .toDouble(),
      hipAngle: current.hipAngle
          .clamp(previous.hipAngle - angleLimit, previous.hipAngle + angleLimit)
          .toDouble(),
      hipDrop: current.hipDrop
          .clamp(previous.hipDrop - motionLimit, previous.hipDrop + motionLimit)
          .toDouble(),
      hipVelocity: current.hipVelocity
          .clamp(-config.maximumHipDropVelocity, config.maximumHipDropVelocity)
          .toDouble(),
    );
  }

  double _distance(_Point a, _Point b) {
    final dx = a.x - b.x;
    final dy = a.y - b.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  double _median(Iterable<double> values) {
    final sorted = values.toList()..sort();
    final middle = sorted.length ~/ 2;
    return sorted.length.isOdd
        ? sorted[middle]
        : (sorted[middle - 1] + sorted[middle]) / 2;
  }

  void resetDerivatives() {
    _previous = null;
    _recent.clear();
  }

  void reset() {
    _elbowFilter.reset();
    _bodyLineFilter.reset();
    _shoulderYFilter.reset();
    _hipYFilter.reset();
    resetDerivatives();
  }
}

class _Point {
  const _Point(this.x, this.y);

  final double x;
  final double y;
}
