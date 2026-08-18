import 'dart:math' as math;

import 'package:motionfit_squat/features/squat/domain/models/calibration_profile.dart';
import 'package:motionfit_squat/features/squat/domain/models/pose_frame.dart';
import 'package:motionfit_squat/features/squat/domain/models/squat_metrics.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_enums.dart';
import 'package:motionfit_squat/features/squat/domain/services/one_euro_filter.dart';
import 'package:motionfit_squat/features/squat/domain/services/squat_detection_config.dart';

class SquatFeatureExtractor {
  SquatFeatureExtractor(this.config);

  final SquatDetectionConfig config;
  final _kneeFilter = OneEuroFilter(minimumCutoff: 1.2, beta: 0.025);
  final _hipAngleFilter = OneEuroFilter(minimumCutoff: 1.2, beta: 0.025);
  final _hipYFilter = OneEuroFilter(minimumCutoff: 1.0, beta: 0.02);
  final _shoulderYFilter = OneEuroFilter(minimumCutoff: 1.0, beta: 0.02);
  final List<SquatMetrics> _recent = [];
  SquatMetrics? _previous;

  SquatMetrics? extract(PoseFrame frame, [CalibrationProfile? profile]) {
    if (!frame.hasCompletePose ||
        frame.meanKeyConfidence < config.landmarkConfidenceFloor) {
      return null;
    }

    PoseLandmark point(int index) => frame.landmarks[index];
    final useWorldLandmarks =
        frame.worldLandmarks.length >= 33 &&
        _hasUsableBiomechanicsSide(frame.worldLandmarks);
    PoseLandmark biomechanicsPoint(int index) => useWorldLandmarks
        ? frame.worldLandmarks[index]
        : frame.landmarks[index];
    final leftKnee = _jointAngle(
      biomechanicsPoint(PoseLandmarkIndex.leftHip),
      biomechanicsPoint(PoseLandmarkIndex.leftKnee),
      biomechanicsPoint(PoseLandmarkIndex.leftAnkle),
      useDepth: useWorldLandmarks,
    );
    final rightKnee = _jointAngle(
      biomechanicsPoint(PoseLandmarkIndex.rightHip),
      biomechanicsPoint(PoseLandmarkIndex.rightKnee),
      biomechanicsPoint(PoseLandmarkIndex.rightAnkle),
      useDepth: useWorldLandmarks,
    );
    final leftHip = _jointAngle(
      biomechanicsPoint(PoseLandmarkIndex.leftShoulder),
      biomechanicsPoint(PoseLandmarkIndex.leftHip),
      biomechanicsPoint(PoseLandmarkIndex.leftKnee),
      useDepth: useWorldLandmarks,
    );
    final rightHip = _jointAngle(
      biomechanicsPoint(PoseLandmarkIndex.rightShoulder),
      biomechanicsPoint(PoseLandmarkIndex.rightHip),
      biomechanicsPoint(PoseLandmarkIndex.rightKnee),
      useDepth: useWorldLandmarks,
    );
    final leftKneeConfidence = _minimumConfidence([
      biomechanicsPoint(PoseLandmarkIndex.leftHip),
      biomechanicsPoint(PoseLandmarkIndex.leftKnee),
      biomechanicsPoint(PoseLandmarkIndex.leftAnkle),
    ]);
    final rightKneeConfidence = _minimumConfidence([
      biomechanicsPoint(PoseLandmarkIndex.rightHip),
      biomechanicsPoint(PoseLandmarkIndex.rightKnee),
      biomechanicsPoint(PoseLandmarkIndex.rightAnkle),
    ]);
    final leftHipConfidence = _minimumConfidence([
      biomechanicsPoint(PoseLandmarkIndex.leftShoulder),
      biomechanicsPoint(PoseLandmarkIndex.leftHip),
      biomechanicsPoint(PoseLandmarkIndex.leftKnee),
    ]);
    final rightHipConfidence = _minimumConfidence([
      biomechanicsPoint(PoseLandmarkIndex.rightShoulder),
      biomechanicsPoint(PoseLandmarkIndex.rightHip),
      biomechanicsPoint(PoseLandmarkIndex.rightKnee),
    ]);
    final observedKneeAngle = _weightedPair(
      leftKnee,
      leftKneeConfidence,
      rightKnee,
      rightKneeConfidence,
    );
    final hipAngle = _weightedPair(
      leftHip,
      leftHipConfidence,
      rightHip,
      rightHipConfidence,
    );
    if (hipAngle == null) return null;

    final shoulder = _weightedCenter(
      point(PoseLandmarkIndex.leftShoulder),
      point(PoseLandmarkIndex.rightShoulder),
    );
    final hip = _weightedCenter(
      point(PoseLandmarkIndex.leftHip),
      point(PoseLandmarkIndex.rightHip),
    );
    final knee = _weightedCenter(
      point(PoseLandmarkIndex.leftKnee),
      point(PoseLandmarkIndex.rightKnee),
    );
    if (shoulder == null || hip == null || knee == null) return null;
    final ankle = _weightedCenter(
      point(PoseLandmarkIndex.leftAnkle),
      point(PoseLandmarkIndex.rightAnkle),
    );
    final bodyScale =
        (ankle == null
                ? _distance(shoulder, knee) * 1.65
                : _distance(shoulder, ankle))
            .clamp(0.1, 2.0)
            .toDouble();
    final confidenceValues = <double>[
      frame.meanKeyConfidence,
      leftHipConfidence > rightHipConfidence
          ? leftHipConfidence
          : rightHipConfidence,
    ];
    if (observedKneeAngle != null) {
      confidenceValues.add(
        leftKneeConfidence > rightKneeConfidence
            ? leftKneeConfidence
            : rightKneeConfidence,
      );
    }
    final confidence = confidenceValues.reduce((a, b) => a < b ? a : b);
    final filteredKnee = _kneeFilter.filter(
      observedKneeAngle ?? 180,
      frame.timestampUs,
      confidence: confidence,
    );
    final filteredHipAngle = _hipAngleFilter.filter(
      hipAngle,
      frame.timestampUs,
      confidence: confidence,
    );
    final filteredHipY = _hipYFilter.filter(
      hip.y,
      frame.timestampUs,
      confidence: confidence,
    );
    final filteredShoulderY = _shoulderYFilter.filter(
      shoulder.y,
      frame.timestampUs,
      confidence: confidence,
    );
    final referenceScale = profile?.bodyScale ?? bodyScale;
    final hipDrop = profile == null
        ? 0.0
        : (filteredHipY - profile.baselineHipY) / referenceScale;
    var hipVelocity = 0.0;
    if (_previous != null && frame.timestampUs > _previous!.timestampUs) {
      final dt = (frame.timestampUs - _previous!.timestampUs) / 1000000.0;
      if (dt <= 0.5) {
        hipVelocity = (hipDrop - _previous!.hipDrop) / dt;
      }
    }
    final shoulderMovement = profile == null
        ? 0.0
        : ((filteredShoulderY - profile.baselineShoulderY) / referenceScale) -
              hipDrop;
    final torsoLean = useWorldLandmarks
        ? _worldTorsoLean(frame)
        : _angleFromVertical(shoulder, hip);
    final cameraAngle =
        profile?.cameraAngle ??
        _cameraAngle(
          point(PoseLandmarkIndex.leftShoulder),
          point(PoseLandmarkIndex.rightShoulder),
          bodyScale,
        );
    final rawLeftHeelLift = _heelLift(
      point(PoseLandmarkIndex.leftHeel),
      point(PoseLandmarkIndex.leftFootIndex),
      referenceScale,
    );
    final rawRightHeelLift = _heelLift(
      point(PoseLandmarkIndex.rightHeel),
      point(PoseLandmarkIndex.rightFootIndex),
      referenceScale,
    );
    final rawKneeAlignment = _kneeAlignmentDeviation(frame, referenceScale);
    final rawBalanceOffset = ankle == null
        ? null
        : (hip.x - ankle.x) / referenceScale;

    var metrics = SquatMetrics(
      timestampUs: frame.timestampUs,
      videoElapsedUs: frame.videoElapsedUs,
      confidence: confidence,
      leftKneeAngle:
          leftKnee != null &&
              leftKneeConfidence >= config.landmarkConfidenceFloor
          ? leftKnee
          : null,
      rightKneeAngle:
          rightKnee != null &&
              rightKneeConfidence >= config.landmarkConfidenceFloor
          ? rightKnee
          : null,
      kneeAngle: filteredKnee,
      leftHipAngle: leftHipConfidence >= config.landmarkConfidenceFloor
          ? leftHip
          : null,
      rightHipAngle: rightHipConfidence >= config.landmarkConfidenceFloor
          ? rightHip
          : null,
      hipAngle: filteredHipAngle,
      hipY: filteredHipY,
      shoulderY: filteredShoulderY,
      bodyScale: bodyScale,
      hipDrop: hipDrop,
      hipVelocity: hipVelocity,
      shoulderHipRelativeMovement: shoulderMovement,
      torsoLeanDegrees: torsoLean,
      leftHeelLift: profile == null
          ? rawLeftHeelLift
          : _positiveDelta(rawLeftHeelLift, profile.baselineLeftHeelLift),
      rightHeelLift: profile == null
          ? rawRightHeelLift
          : _positiveDelta(rawRightHeelLift, profile.baselineRightHeelLift),
      kneeAlignmentDeviation: profile == null
          ? rawKneeAlignment
          : _negativeDelta(rawKneeAlignment, profile.baselineKneeAlignment),
      balanceDeviation: profile == null
          ? rawBalanceOffset
          : _absoluteDelta(rawBalanceOffset, profile.baselineBalanceOffset),
      cameraAngle: cameraAngle,
      biomechanics3d: useWorldLandmarks,
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

  double _minimumConfidence(List<PoseLandmark> points) =>
      points.map((point) => point.confidence).reduce((a, b) => a < b ? a : b);

  bool _hasUsableBiomechanicsSide(List<PoseLandmark> points) {
    const sides = [
      [
        PoseLandmarkIndex.leftShoulder,
        PoseLandmarkIndex.leftHip,
        PoseLandmarkIndex.leftKnee,
      ],
      [
        PoseLandmarkIndex.rightShoulder,
        PoseLandmarkIndex.rightHip,
        PoseLandmarkIndex.rightKnee,
      ],
    ];
    return sides.any(
      (side) => side.every(
        (index) => points[index].confidence >= config.landmarkConfidenceFloor,
      ),
    );
  }

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

  double _distance(_Point a, _Point b) =>
      math.sqrt(math.pow(a.x - b.x, 2) + math.pow(a.y - b.y, 2));

  double _angleFromVertical(_Point shoulder, _Point hip) {
    final dx = shoulder.x - hip.x;
    final dy = shoulder.y - hip.y;
    return math.atan2(dx.abs(), dy.abs().clamp(1e-6, 2.0)) * 180 / math.pi;
  }

  double _worldTorsoLean(PoseFrame frame) {
    final shoulder = _weightedCenter3d(
      frame.worldLandmarks[PoseLandmarkIndex.leftShoulder],
      frame.worldLandmarks[PoseLandmarkIndex.rightShoulder],
    );
    final hip = _weightedCenter3d(
      frame.worldLandmarks[PoseLandmarkIndex.leftHip],
      frame.worldLandmarks[PoseLandmarkIndex.rightHip],
    );
    if (shoulder == null || hip == null) return 0;
    final dx = shoulder.x - hip.x;
    final dy = shoulder.y - hip.y;
    final dz = shoulder.z - hip.z;
    final horizontal = math.sqrt(dx * dx + dz * dz);
    return math.atan2(horizontal, dy.abs().clamp(1e-6, 2.0)) * 180 / math.pi;
  }

  _Point3? _weightedCenter3d(PoseLandmark a, PoseLandmark b) {
    final aWeight = a.confidence >= config.landmarkConfidenceFloor
        ? a.confidence
        : 0.0;
    final bWeight = b.confidence >= config.landmarkConfidenceFloor
        ? b.confidence
        : 0.0;
    final total = aWeight + bWeight;
    if (total <= 0) return null;
    return _Point3(
      (a.x * aWeight + b.x * bWeight) / total,
      (a.y * aWeight + b.y * bWeight) / total,
      (a.z * aWeight + b.z * bWeight) / total,
    );
  }

  CameraAngle _cameraAngle(
    PoseLandmark leftShoulder,
    PoseLandmark rightShoulder,
    double bodyScale,
  ) {
    final ratio = (leftShoulder.x - rightShoulder.x).abs() / bodyScale;
    if (ratio < 0.18) return CameraAngle.side;
    if (ratio < 0.34) return CameraAngle.oblique;
    return CameraAngle.front;
  }

  double? _heelLift(PoseLandmark heel, PoseLandmark foot, double bodyScale) {
    if (_minimumConfidence([heel, foot]) < config.landmarkConfidenceFloor) {
      return null;
    }
    return (foot.y - heel.y) / bodyScale;
  }

  double? _kneeAlignmentDeviation(PoseFrame frame, double bodyScale) {
    final leftHip = frame.landmark(PoseLandmarkIndex.leftHip);
    final rightHip = frame.landmark(PoseLandmarkIndex.rightHip);
    final leftKnee = frame.landmark(PoseLandmarkIndex.leftKnee);
    final rightKnee = frame.landmark(PoseLandmarkIndex.rightKnee);
    if ([leftHip, rightHip, leftKnee, rightKnee].any(
      (point) =>
          point == null || point.confidence < config.landmarkConfidenceFloor,
    )) {
      return null;
    }
    final hipWidth = (leftHip!.x - rightHip!.x).abs();
    final kneeWidth = (leftKnee!.x - rightKnee!.x).abs();
    if (hipWidth / bodyScale < 0.025) return null;
    return kneeWidth / hipWidth;
  }

  double? _positiveDelta(double? current, double? baseline) {
    if (current == null || baseline == null) return null;
    return math.max(0, current - baseline);
  }

  double? _negativeDelta(double? current, double? baseline) {
    if (current == null || baseline == null) return null;
    return math.max(0, baseline - current);
  }

  double? _absoluteDelta(double? current, double? baseline) {
    if (current == null || baseline == null) return null;
    return (current - baseline).abs();
  }

  double _median(Iterable<double> values) {
    final sorted = values.toList()..sort();
    return sorted[sorted.length ~/ 2];
  }

  SquatMetrics _rejectOutliers(SquatMetrics current) {
    final previous = _previous;
    if (previous == null || current.timestampUs <= previous.timestampUs) {
      return current;
    }
    final elapsedSeconds =
        (current.timestampUs - previous.timestampUs) / 1000000.0;
    if (elapsedSeconds > 0.5) return current;
    final angleLimit =
        config.maximumJointAngularVelocityDegreesPerSecond * elapsedSeconds;
    final hipDropLimit = config.maximumHipDropVelocity * elapsedSeconds;
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
          .clamp(
            previous.hipDrop - hipDropLimit,
            previous.hipDrop + hipDropLimit,
          )
          .toDouble(),
      hipVelocity: current.hipVelocity
          .clamp(-config.maximumHipDropVelocity, config.maximumHipDropVelocity)
          .toDouble(),
    );
  }

  void resetDerivatives() {
    _previous = null;
    _recent.clear();
  }

  void reset() {
    _kneeFilter.reset();
    _hipAngleFilter.reset();
    _hipYFilter.reset();
    _shoulderYFilter.reset();
    resetDerivatives();
  }
}

class _Point {
  const _Point(this.x, this.y);
  final double x;
  final double y;
}

class _Point3 {
  const _Point3(this.x, this.y, this.z);
  final double x;
  final double y;
  final double z;
}
