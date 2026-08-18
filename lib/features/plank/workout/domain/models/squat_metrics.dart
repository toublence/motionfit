import 'package:motionfit_squat/features/plank/workout/domain/models/workout_enums.dart';

class SquatMetrics {
  const SquatMetrics({
    required this.timestampUs,
    this.videoElapsedUs,
    required this.confidence,
    required this.leftKneeAngle,
    required this.rightKneeAngle,
    required this.kneeAngle,
    required this.leftHipAngle,
    required this.rightHipAngle,
    required this.hipAngle,
    required this.hipY,
    required this.shoulderY,
    required this.bodyScale,
    required this.hipDrop,
    required this.hipVelocity,
    required this.shoulderHipRelativeMovement,
    required this.torsoLeanDegrees,
    required this.leftHeelLift,
    required this.rightHeelLift,
    required this.kneeAlignmentDeviation,
    required this.balanceDeviation,
    required this.cameraAngle,
    this.biomechanics3d = false,
  });

  final int timestampUs;
  final int? videoElapsedUs;
  final double confidence;
  final double? leftKneeAngle;
  final double? rightKneeAngle;
  final double kneeAngle;
  final double? leftHipAngle;
  final double? rightHipAngle;
  final double hipAngle;
  final double hipY;
  final double shoulderY;
  final double bodyScale;
  final double hipDrop;
  final double hipVelocity;
  final double shoulderHipRelativeMovement;
  final double torsoLeanDegrees;
  final double? leftHeelLift;
  final double? rightHeelLift;
  final double? kneeAlignmentDeviation;
  final double? balanceDeviation;
  final CameraAngle cameraAngle;
  final bool biomechanics3d;

  SquatMetrics copyWith({
    double? confidence,
    double? kneeAngle,
    double? hipAngle,
    double? hipY,
    double? shoulderY,
    double? bodyScale,
    double? hipDrop,
    double? hipVelocity,
    double? shoulderHipRelativeMovement,
    double? torsoLeanDegrees,
  }) => SquatMetrics(
    timestampUs: timestampUs,
    videoElapsedUs: videoElapsedUs,
    confidence: confidence ?? this.confidence,
    leftKneeAngle: leftKneeAngle,
    rightKneeAngle: rightKneeAngle,
    kneeAngle: kneeAngle ?? this.kneeAngle,
    leftHipAngle: leftHipAngle,
    rightHipAngle: rightHipAngle,
    hipAngle: hipAngle ?? this.hipAngle,
    hipY: hipY ?? this.hipY,
    shoulderY: shoulderY ?? this.shoulderY,
    bodyScale: bodyScale ?? this.bodyScale,
    hipDrop: hipDrop ?? this.hipDrop,
    hipVelocity: hipVelocity ?? this.hipVelocity,
    shoulderHipRelativeMovement:
        shoulderHipRelativeMovement ?? this.shoulderHipRelativeMovement,
    torsoLeanDegrees: torsoLeanDegrees ?? this.torsoLeanDegrees,
    leftHeelLift: leftHeelLift,
    rightHeelLift: rightHeelLift,
    kneeAlignmentDeviation: kneeAlignmentDeviation,
    balanceDeviation: balanceDeviation,
    cameraAngle: cameraAngle,
    biomechanics3d: biomechanics3d,
  );
}

class RepMotionTrace {
  const RepMotionTrace({
    required this.repSequence,
    required this.startedAtUs,
    required this.bottomAtUs,
    required this.completedAtUs,
    required this.samples,
    required this.detectionConfidence,
    this.videoStartedAtUs,
    this.videoBottomAtUs,
    this.videoCompletedAtUs,
  });

  final int repSequence;
  final int startedAtUs;
  final int? bottomAtUs;
  final int completedAtUs;
  final List<SquatMetrics> samples;
  final double detectionConfidence;
  final int? videoStartedAtUs;
  final int? videoBottomAtUs;
  final int? videoCompletedAtUs;

  int get durationMilliseconds =>
      ((completedAtUs - startedAtUs) / 1000).round().clamp(0, 120000).toInt();
}
