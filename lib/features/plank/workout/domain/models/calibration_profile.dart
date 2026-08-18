import 'package:motionfit_squat/features/plank/workout/domain/models/workout_enums.dart';

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
}
