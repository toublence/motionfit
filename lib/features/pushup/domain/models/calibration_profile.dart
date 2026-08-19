import 'package:motionfit_squat/features/pushup/domain/models/workout_enums.dart';

class CalibrationProfile {
  const CalibrationProfile({
    required this.baselineKneeAngle,
    required this.baselineHipAngle,
    required this.baselineHipY,
    required this.baselineShoulderY,
    required this.bodyScale,
    required this.motionNoiseMad,
    required this.cameraAngle,
    required this.calibratedAtUs,
    this.baselineLeftHeelLift,
    this.baselineRightHeelLift,
    this.baselineKneeAlignment,
    this.baselineBalanceOffset,
  });

  final double baselineKneeAngle;
  final double baselineHipAngle;
  final double baselineHipY;
  final double baselineShoulderY;
  final double bodyScale;
  final double motionNoiseMad;
  final CameraAngle cameraAngle;
  final int calibratedAtUs;
  final double? baselineLeftHeelLift;
  final double? baselineRightHeelLift;
  final double? baselineKneeAlignment;
  final double? baselineBalanceOffset;

  factory CalibrationProfile.fromMap(
    Map<Object?, Object?> map,
  ) => CalibrationProfile(
    baselineKneeAngle: (map['baselineKneeAngle'] as num).toDouble(),
    baselineHipAngle: (map['baselineHipAngle'] as num).toDouble(),
    baselineHipY: (map['baselineHipY'] as num).toDouble(),
    baselineShoulderY: (map['baselineShoulderY'] as num).toDouble(),
    bodyScale: (map['bodyScale'] as num).toDouble(),
    motionNoiseMad: (map['motionNoiseMad'] as num).toDouble(),
    cameraAngle: CameraAngle.values.byName(map['cameraAngle'] as String),
    calibratedAtUs: (map['calibratedAtUs'] as num).toInt(),
    baselineLeftHeelLift: (map['baselineLeftHeelLift'] as num?)?.toDouble(),
    baselineRightHeelLift: (map['baselineRightHeelLift'] as num?)?.toDouble(),
    baselineKneeAlignment: (map['baselineKneeAlignment'] as num?)?.toDouble(),
    baselineBalanceOffset: (map['baselineBalanceOffset'] as num?)?.toDouble(),
  );

  Map<String, Object?> toMap() => {
    'baselineKneeAngle': baselineKneeAngle,
    'baselineHipAngle': baselineHipAngle,
    'baselineHipY': baselineHipY,
    'baselineShoulderY': baselineShoulderY,
    'bodyScale': bodyScale,
    'motionNoiseMad': motionNoiseMad,
    'cameraAngle': cameraAngle.name,
    'calibratedAtUs': calibratedAtUs,
    'baselineLeftHeelLift': baselineLeftHeelLift,
    'baselineRightHeelLift': baselineRightHeelLift,
    'baselineKneeAlignment': baselineKneeAlignment,
    'baselineBalanceOffset': baselineBalanceOffset,
  };
}
