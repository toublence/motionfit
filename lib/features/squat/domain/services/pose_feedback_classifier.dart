import 'package:motionfit_squat/features/squat/domain/models/squat_metrics.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_enums.dart';

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

    final ratios = <double>[];
    final sideObservable =
        metrics.cameraAngle == CameraAngle.side ||
        metrics.cameraAngle == CameraAngle.oblique;
    final frontObservable =
        metrics.cameraAngle == CameraAngle.front ||
        metrics.cameraAngle == CameraAngle.oblique;

    if (sideObservable) {
      ratios.add(metrics.torsoLeanDegrees / config.maximumTorsoLeanDegrees);
      final heelLift = [
        metrics.leftHeelLift,
        metrics.rightHeelLift,
      ].whereType<double>();
      if (heelLift.isNotEmpty) {
        ratios.add(
          heelLift.reduce((left, right) => left > right ? left : right) /
              config.maximumHeelLift,
        );
      }
    }
    if (frontObservable) {
      if (metrics.kneeAlignmentDeviation case final value?) {
        ratios.add(value / config.maximumKneeAlignmentDeviation);
      }
      if (metrics.balanceDeviation case final value?) {
        ratios.add(value / config.maximumBalanceDeviation);
      }
    }
    if (ratios.isEmpty) return PoseFeedbackLevel.unavailable;

    final violations = ratios.where((ratio) => ratio >= 1).length;
    final worst = ratios.reduce((left, right) => left > right ? left : right);
    if (worst >= config.criticalRatio || violations >= 2) {
      return PoseFeedbackLevel.poor;
    }
    if (worst >= config.warningRatio) return PoseFeedbackLevel.caution;
    return PoseFeedbackLevel.good;
  }
}
