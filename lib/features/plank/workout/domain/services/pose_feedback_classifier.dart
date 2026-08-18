import 'package:motionfit_squat/features/plank/workout/domain/models/squat_metrics.dart';
import 'package:motionfit_squat/features/plank/workout/domain/models/workout_enums.dart';

class PoseFeedbackConfig {
  const PoseFeedbackConfig({
    this.minimumConfidence = 0.60,
    this.warningRatio = 0.75,
    this.criticalRatio = 1.50,
    this.maximumTorsoLeanDegrees = 45,
    this.maximumHeelLift = 0.035,
    this.maximumKneeAlignmentDeviation = 0.08,
    this.maximumBalanceDeviation = 0.05,
  });

  final double minimumConfidence;
  final double warningRatio;
  final double criticalRatio;
  final double maximumTorsoLeanDegrees;
  final double maximumHeelLift;
  final double maximumKneeAlignmentDeviation;
  final double maximumBalanceDeviation;
}

/// Lightweight live feedback for the overlay. Final per-rep form analysis
/// remains independent and is performed after a repetition completes.
class PoseFeedbackClassifier {
  const PoseFeedbackClassifier({this.config = const PoseFeedbackConfig()});

  final PoseFeedbackConfig config;

  PoseFeedbackLevel classify(
    SquatMetrics? metrics, {
    required TrackingState trackingState,
  }) {
    if (trackingState != TrackingState.tracking ||
        metrics == null ||
        metrics.confidence < config.minimumConfidence) {
      return PoseFeedbackLevel.unavailable;
    }

    final ratios = <double>[
      (180 - metrics.hipAngle).abs() / 25,
      (90 - metrics.torsoLeanDegrees).abs() / 35,
    ];
    if (metrics.leftKneeAngle != null || metrics.rightKneeAngle != null) {
      ratios.add((180 - metrics.kneeAngle).abs() / 30);
    }

    final violations = ratios.where((ratio) => ratio >= 1).length;
    final worst = ratios.reduce((left, right) => left > right ? left : right);
    if (worst >= config.criticalRatio || violations >= 2) {
      return PoseFeedbackLevel.poor;
    }
    if (worst >= config.warningRatio) return PoseFeedbackLevel.caution;
    return PoseFeedbackLevel.good;
  }
}
