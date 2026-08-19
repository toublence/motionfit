import 'dart:math' as math;

import 'package:motionfit_squat/features/squat/domain/models/squat_metrics.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_enums.dart';

enum FormMetricStatus {
  passed,
  needsAttention,
  notObservable,
  insufficientConfidence,
}

enum FormMetricType {
  depth,
  torsoLean,
  heelContact,
  kneeAlignment,
  balance,
  descentTempo,
  ascentTempo,
  control,
  lockout,
}

class FormMetricResult {
  const FormMetricResult({
    required this.type,
    required this.status,
    required this.score,
    required this.confidence,
    required this.persistence,
    this.issue,
    this.value,
    this.threshold,
  });

  final FormMetricType type;
  final FormMetricStatus status;
  final double? score;
  final double confidence;
  final double persistence;
  final FormIssue? issue;
  final double? value;
  final Object? threshold;
}

class FormAnalysisResult {
  const FormAnalysisResult({
    required this.repSequence,
    required this.metrics,
    required this.detectedIssues,
    required this.primaryIssue,
    required this.depthScore,
    required this.controlScore,
    required this.balanceScore,
    required this.overallScore,
    required this.coverage,
    required this.cameraAngle,
    required this.confidence,
  });

  final int repSequence;
  final Map<FormMetricType, FormMetricResult> metrics;
  final List<FormIssue> detectedIssues;
  final FormIssue? primaryIssue;
  final double? depthScore;
  final double? controlScore;
  final double? balanceScore;
  final double? overallScore;
  final double coverage;
  final CameraAngle cameraAngle;
  final double confidence;
}

class SquatFormConfig {
  const SquatFormConfig({
    this.minimumConfidence = 0.70,
    this.minimumPersistence = 0.30,
    this.goodDepthKneeAngle = 105,
    this.minimumGoodHipDrop = 0.12,
    this.maximumTorsoLeanDegrees = 45,
    this.maximumHeelLift = 0.035,
    this.maximumKneeAlignmentDeviation = 0.08,
    this.maximumBalanceDeviation = 0.05,
    this.minimumDescentSeconds = 0.45,
    this.maximumDescentSeconds = 5.0,
    this.minimumAscentSeconds = 0.30,
    this.maximumAscentSeconds = 5.0,
    this.maximumControlJerk = 1.8,
    this.lockoutKneeAngle = 165,
    this.lockoutHipAngle = 160,
  });

  final double minimumConfidence;
  final double minimumPersistence;
  final double goodDepthKneeAngle;
  final double minimumGoodHipDrop;
  final double maximumTorsoLeanDegrees;
  final double maximumHeelLift;
  final double maximumKneeAlignmentDeviation;
  final double maximumBalanceDeviation;
  final double minimumDescentSeconds;
  final double maximumDescentSeconds;
  final double minimumAscentSeconds;
  final double maximumAscentSeconds;
  final double maximumControlJerk;
  final double lockoutKneeAngle;
  final double lockoutHipAngle;
}

abstract interface class FormAnalyzer {
  FormAnalysisResult analyze(RepMotionTrace trace);
}

class SquatFormAnalyzer implements FormAnalyzer {
  const SquatFormAnalyzer({this.config = const SquatFormConfig()});

  final SquatFormConfig config;

  @override
  FormAnalysisResult analyze(RepMotionTrace trace) {
    final samples = trace.samples;
    if (samples.isEmpty) {
      return FormAnalysisResult(
        repSequence: trace.repSequence,
        metrics: const {},
        detectedIssues: const [],
        primaryIssue: null,
        depthScore: null,
        controlScore: null,
        balanceScore: null,
        overallScore: null,
        coverage: 0,
        cameraAngle: CameraAngle.uncertain,
        confidence: 0,
      );
    }
    final cameraAngle = _dominantAngle(samples);
    final meanConfidence =
        samples.fold<double>(0, (sum, sample) => sum + sample.confidence) /
        samples.length;
    final metrics = <FormMetricType, FormMetricResult>{};
    final biomechanics3d = samples.any((sample) => sample.biomechanics3d);
    final continuousTrace = _isContinuous(samples);
    final kneeObservable = samples.any(
      (sample) => sample.leftKneeAngle != null || sample.rightKneeAngle != null,
    );
    final hipDrops = samples.map((sample) => sample.hipDrop).toList();
    final hipDropRange = hipDrops.reduce(math.max) - hipDrops.reduce(math.min);
    final bottomIndex = hipDropRange < 0.02 && kneeObservable
        ? samples.indexed
              .reduce((a, b) => a.$2.kneeAngle <= b.$2.kneeAngle ? a : b)
              .$1
        : samples.indexed
              .reduce((a, b) => a.$2.hipDrop >= b.$2.hipDrop ? a : b)
              .$1;
    final bottomRadius = math.max(1, (samples.length * 0.12).ceil());
    final bottomStart = math.max(0, bottomIndex - bottomRadius);
    final bottomEnd = math.min(samples.length, bottomIndex + bottomRadius + 1);
    final bottomSamples = samples.sublist(bottomStart, bottomEnd);

    metrics[FormMetricType.depth] = _assessDepth(
      useKneeAngle:
          kneeObservable &&
          (biomechanics3d ||
              cameraAngle == CameraAngle.side ||
              cameraAngle == CameraAngle.oblique),
      samples: bottomSamples,
    );
    metrics[FormMetricType.torsoLean] = _assessThreshold(
      type: FormMetricType.torsoLean,
      observable:
          biomechanics3d ||
          cameraAngle == CameraAngle.side ||
          cameraAngle == CameraAngle.oblique,
      samples: bottomSamples,
      violates: (sample) =>
          sample.torsoLeanDegrees > config.maximumTorsoLeanDegrees,
      score: _scoreLowerIsBetter(
        samples.map((sample) => sample.torsoLeanDegrees).reduce(math.max),
        good: 25,
        worst: 70,
      ),
      issue: FormIssue.excessiveTorsoLean,
      value: samples.map((sample) => sample.torsoLeanDegrees).reduce(math.max),
      threshold: config.maximumTorsoLeanDegrees,
    );
    metrics[FormMetricType.heelContact] = _assessOptionalThreshold(
      type: FormMetricType.heelContact,
      observable:
          cameraAngle == CameraAngle.side || cameraAngle == CameraAngle.oblique,
      samples: bottomSamples,
      value: (sample) {
        final values = [
          sample.leftHeelLift,
          sample.rightHeelLift,
        ].whereType<double>().toList();
        return values.isEmpty ? null : values.reduce(math.max);
      },
      threshold: config.maximumHeelLift,
      issue: FormIssue.heelLift,
    );
    metrics[FormMetricType.kneeAlignment] = _assessOptionalThreshold(
      type: FormMetricType.kneeAlignment,
      observable:
          cameraAngle == CameraAngle.front ||
          cameraAngle == CameraAngle.oblique,
      samples: bottomSamples,
      value: (sample) => sample.kneeAlignmentDeviation,
      threshold: config.maximumKneeAlignmentDeviation,
      issue: FormIssue.kneeAlignment,
    );
    metrics[FormMetricType.balance] = _assessOptionalThreshold(
      type: FormMetricType.balance,
      observable:
          cameraAngle == CameraAngle.front ||
          cameraAngle == CameraAngle.oblique,
      samples: bottomSamples,
      value: (sample) => sample.balanceDeviation,
      threshold: config.maximumBalanceDeviation,
      issue: FormIssue.leftRightImbalance,
    );

    final bottomAt = trace.bottomAtUs ?? samples[bottomIndex].timestampUs;
    final descentSeconds = (bottomAt - trace.startedAtUs) / 1000000.0;
    final ascentSeconds = (trace.completedAtUs - bottomAt) / 1000000.0;
    metrics[FormMetricType.descentTempo] = continuousTrace
        ? _tempoResult(
            FormMetricType.descentTempo,
            descentSeconds,
            config.minimumDescentSeconds,
            config.maximumDescentSeconds,
            FormIssue.descentTooFast,
            FormIssue.descentTooSlow,
            meanConfidence,
          )
        : _notObservable(FormMetricType.descentTempo);
    metrics[FormMetricType.ascentTempo] = continuousTrace
        ? _tempoResult(
            FormMetricType.ascentTempo,
            ascentSeconds,
            config.minimumAscentSeconds,
            config.maximumAscentSeconds,
            FormIssue.ascentTooFast,
            FormIssue.ascentTooSlow,
            meanConfidence,
          )
        : _notObservable(FormMetricType.ascentTempo);
    final jerk = _meanVelocityJerk(samples);
    metrics[FormMetricType.control] = FormMetricResult(
      type: FormMetricType.control,
      status: !continuousTrace
          ? FormMetricStatus.notObservable
          : meanConfidence < config.minimumConfidence
          ? FormMetricStatus.insufficientConfidence
          : jerk > config.maximumControlJerk
          ? FormMetricStatus.needsAttention
          : FormMetricStatus.passed,
      score: !continuousTrace || meanConfidence < config.minimumConfidence
          ? null
          : _scoreLowerIsBetter(
              jerk,
              good: 0.35,
              worst: config.maximumControlJerk * 2,
            ),
      confidence: continuousTrace ? meanConfidence : 0,
      persistence: continuousTrace && jerk > config.maximumControlJerk ? 1 : 0,
      value: jerk,
      threshold: config.maximumControlJerk,
      issue: continuousTrace && jerk > config.maximumControlJerk
          ? FormIssue.unstableControl
          : null,
    );
    // Counting deliberately completes after a clear recovery from the bottom,
    // before full standing lockout. The trace therefore cannot prove that the
    // user failed to stand tall; coaching it here creates systematic false cues.
    metrics[FormMetricType.lockout] = _notObservable(FormMetricType.lockout);

    final evaluated = metrics.values
        .where((metric) => metric.score != null)
        .toList();
    final issueMetrics = metrics.values
        .where(
          (metric) =>
              metric.status == FormMetricStatus.needsAttention &&
              metric.issue != null,
        )
        .toList();
    final primary = issueMetrics.isEmpty
        ? null
        : issueMetrics
              .reduce((a, b) => _priorityScore(a) >= _priorityScore(b) ? a : b)
              .issue;
    final issues = issueMetrics
        .map((metric) => metric.issue!)
        .toList(growable: false);
    final overall = evaluated.isEmpty
        ? null
        : evaluated.fold<double>(0, (sum, metric) => sum + metric.score!) /
              evaluated.length;
    return FormAnalysisResult(
      repSequence: trace.repSequence,
      metrics: Map.unmodifiable(metrics),
      detectedIssues: issues,
      primaryIssue: primary,
      depthScore: metrics[FormMetricType.depth]?.score,
      controlScore: metrics[FormMetricType.control]?.score,
      balanceScore: metrics[FormMetricType.balance]?.score,
      overallScore: overall,
      coverage: evaluated.length / FormMetricType.values.length,
      cameraAngle: cameraAngle,
      confidence: meanConfidence,
    );
  }

  FormMetricResult _assessThreshold({
    required FormMetricType type,
    required bool observable,
    required List<SquatMetrics> samples,
    required bool Function(SquatMetrics) violates,
    required double score,
    required FormIssue issue,
    required double value,
    required double threshold,
  }) {
    if (!observable) return _notObservable(type);
    final confident = samples
        .where((sample) => sample.confidence >= config.minimumConfidence)
        .toList();
    if (confident.isEmpty) return _insufficient(type);
    final persistence = confident.where(violates).length / confident.length;
    final needsAttention = persistence >= config.minimumPersistence;
    return FormMetricResult(
      type: type,
      status: needsAttention
          ? FormMetricStatus.needsAttention
          : FormMetricStatus.passed,
      score: score,
      confidence: _meanConfidence(confident),
      persistence: persistence,
      issue: needsAttention ? issue : null,
      value: value,
      threshold: threshold,
    );
  }

  FormMetricResult _assessDepth({
    required bool useKneeAngle,
    required List<SquatMetrics> samples,
  }) {
    final confident = samples
        .where((sample) => sample.confidence >= config.minimumConfidence)
        .toList();
    if (confident.isEmpty) return _insufficient(FormMetricType.depth);
    if (useKneeAngle) {
      final kneeSamples = confident
          .where(
            (sample) =>
                sample.leftKneeAngle != null || sample.rightKneeAngle != null,
          )
          .toList();
      if (kneeSamples.isNotEmpty) {
        final angles = kneeSamples.map((sample) => sample.kneeAngle).toList()
          ..sort();
        final deepestCount = math.max(1, (angles.length * 0.4).ceil());
        final representativeAngle =
            angles.take(deepestCount).reduce((a, b) => a + b) / deepestCount;
        final needsAttention = representativeAngle > config.goodDepthKneeAngle;
        return FormMetricResult(
          type: FormMetricType.depth,
          status: needsAttention
              ? FormMetricStatus.needsAttention
              : FormMetricStatus.passed,
          score: _scoreLowerIsBetter(
            representativeAngle,
            good: config.goodDepthKneeAngle,
            worst: 155,
          ),
          confidence: _meanConfidence(kneeSamples),
          persistence: needsAttention ? 1 : 0,
          issue: needsAttention ? FormIssue.insufficientDepth : null,
          value: representativeAngle,
          threshold: config.goodDepthKneeAngle,
        );
      }
    }

    final drops = confident.map((sample) => sample.hipDrop).toList()
      ..sort((a, b) => b.compareTo(a));
    final deepestCount = math.max(1, (drops.length * 0.4).ceil());
    final representativeDrop =
        drops.take(deepestCount).reduce((a, b) => a + b) / deepestCount;
    final needsAttention = representativeDrop < config.minimumGoodHipDrop;
    return FormMetricResult(
      type: FormMetricType.depth,
      status: needsAttention
          ? FormMetricStatus.needsAttention
          : FormMetricStatus.passed,
      score: _scoreHigherIsBetter(
        representativeDrop,
        good: config.minimumGoodHipDrop,
        worst: 0.04,
      ),
      confidence: _meanConfidence(confident),
      persistence: needsAttention ? 1 : 0,
      issue: needsAttention ? FormIssue.insufficientDepth : null,
      value: representativeDrop,
      threshold: config.minimumGoodHipDrop,
    );
  }

  FormMetricResult _assessOptionalThreshold({
    required FormMetricType type,
    required bool observable,
    required List<SquatMetrics> samples,
    required double? Function(SquatMetrics) value,
    required double threshold,
    required FormIssue issue,
  }) {
    if (!observable) return _notObservable(type);
    final confident = samples
        .where(
          (sample) =>
              sample.confidence >= config.minimumConfidence &&
              value(sample) != null,
        )
        .toList();
    if (confident.isEmpty) return _insufficient(type);
    final persistence =
        confident.where((sample) => value(sample)! > threshold).length /
        confident.length;
    final worst = confident.map((sample) => value(sample)!).reduce(math.max);
    final needsAttention = persistence >= config.minimumPersistence;
    return FormMetricResult(
      type: type,
      status: needsAttention
          ? FormMetricStatus.needsAttention
          : FormMetricStatus.passed,
      score: _scoreLowerIsBetter(
        worst,
        good: threshold * 0.4,
        worst: threshold * 3,
      ),
      confidence: _meanConfidence(confident),
      persistence: persistence,
      issue: needsAttention ? issue : null,
      value: worst,
      threshold: threshold,
    );
  }

  FormMetricResult _tempoResult(
    FormMetricType type,
    double seconds,
    double minimum,
    double maximum,
    FormIssue fastIssue,
    FormIssue slowIssue,
    double confidence,
  ) {
    if (confidence < config.minimumConfidence) return _insufficient(type);
    final issue = seconds < minimum
        ? fastIssue
        : seconds > maximum
        ? slowIssue
        : null;
    final ideal = (minimum + math.min(maximum, 2.5)) / 2;
    final error = (seconds - ideal).abs();
    return FormMetricResult(
      type: type,
      status: issue == null
          ? FormMetricStatus.passed
          : FormMetricStatus.needsAttention,
      score: (100 - error * 25).clamp(0, 100).toDouble(),
      confidence: confidence,
      persistence: issue == null ? 0 : 1,
      issue: issue,
      value: seconds,
      threshold: {'minimum': minimum, 'maximum': maximum},
    );
  }

  FormMetricResult _notObservable(FormMetricType type) => FormMetricResult(
    type: type,
    status: FormMetricStatus.notObservable,
    score: null,
    confidence: 0,
    persistence: 0,
  );

  FormMetricResult _insufficient(FormMetricType type) => FormMetricResult(
    type: type,
    status: FormMetricStatus.insufficientConfidence,
    score: null,
    confidence: 0,
    persistence: 0,
  );

  double _scoreLowerIsBetter(
    double value, {
    required double good,
    required double worst,
  }) {
    if (value <= good) return 100;
    return (100 * (1 - (value - good) / (worst - good)))
        .clamp(0, 100)
        .toDouble();
  }

  double _scoreHigherIsBetter(
    double value, {
    required double good,
    required double worst,
  }) {
    if (value >= good) return 100;
    return (100 * (value - worst) / (good - worst)).clamp(0, 100).toDouble();
  }

  double _meanVelocityJerk(List<SquatMetrics> samples) {
    if (samples.length < 3) return 0;
    var sum = 0.0;
    var count = 0;
    for (var index = 2; index < samples.length; index++) {
      final dt =
          (samples[index].timestampUs - samples[index - 1].timestampUs) /
          1000000.0;
      if (dt <= 0 || dt > 0.5) continue;
      sum +=
          ((samples[index].hipVelocity - samples[index - 1].hipVelocity) / dt)
              .abs();
      count++;
    }
    return count == 0 ? 0 : sum / count;
  }

  bool _isContinuous(List<SquatMetrics> samples) {
    for (var index = 1; index < samples.length; index++) {
      final gap = samples[index].timestampUs - samples[index - 1].timestampUs;
      if (gap <= 0 || gap > 350000) return false;
    }
    return true;
  }

  double _meanConfidence(List<SquatMetrics> samples) =>
      samples.fold<double>(0, (sum, sample) => sum + sample.confidence) /
      samples.length;

  double _priorityScore(FormMetricResult result) {
    final priority = switch (result.issue) {
      FormIssue.heelLift => 1.20,
      FormIssue.kneeAlignment => 1.18,
      FormIssue.excessiveTorsoLean => 1.12,
      FormIssue.leftRightImbalance => 1.10,
      FormIssue.incompleteLockout => 1.08,
      FormIssue.insufficientDepth => 1.05,
      FormIssue.unstableControl => 1.03,
      _ => 1.0,
    };
    final severity = 1 - ((result.score ?? 100) / 100);
    return severity * result.confidence * result.persistence * priority;
  }

  CameraAngle _dominantAngle(List<SquatMetrics> samples) {
    final counts = <CameraAngle, int>{};
    for (final sample in samples) {
      counts[sample.cameraAngle] = (counts[sample.cameraAngle] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }
}
