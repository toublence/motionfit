import 'dart:math' as math;

import 'package:motionfit_squat/features/plank/workout/domain/models/squat_metrics.dart';
import 'package:motionfit_squat/features/plank/workout/domain/models/workout_enums.dart';

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
    final meanConfidence = _meanConfidence(samples);
    final confident = samples
        .where((sample) => sample.confidence >= config.minimumConfidence)
        .toList(growable: false);
    final metrics = <FormMetricType, FormMetricResult>{};

    FormMetricResult alignmentMetric({
      required FormMetricType type,
      required double Function(SquatMetrics sample) error,
      required double allowedError,
      required FormIssue issue,
    }) {
      if (confident.isEmpty) return _insufficient(type);
      final errors = confident.map(error).toList(growable: false);
      final persistence =
          errors.where((value) => value > allowedError).length / errors.length;
      final worst = errors.reduce(math.max);
      final needsAttention = persistence >= config.minimumPersistence;
      return FormMetricResult(
        type: type,
        status: needsAttention
            ? FormMetricStatus.needsAttention
            : FormMetricStatus.passed,
        score: _scoreLowerIsBetter(
          worst,
          good: allowedError * 0.35,
          worst: allowedError * 2.5,
        ),
        confidence: meanConfidence,
        persistence: persistence,
        issue: needsAttention ? issue : null,
        value: worst,
        threshold: allowedError,
      );
    }

    metrics[FormMetricType.depth] = alignmentMetric(
      type: FormMetricType.depth,
      error: (sample) => (180 - sample.hipAngle).abs(),
      allowedError: 25,
      issue: FormIssue.insufficientDepth,
    );
    metrics[FormMetricType.torsoLean] = alignmentMetric(
      type: FormMetricType.torsoLean,
      error: (sample) => (90 - sample.torsoLeanDegrees).abs(),
      allowedError: 35,
      issue: FormIssue.excessiveTorsoLean,
    );
    final kneeObservable = confident.any(
      (sample) => sample.leftKneeAngle != null || sample.rightKneeAngle != null,
    );
    metrics[FormMetricType.kneeAlignment] = kneeObservable
        ? alignmentMetric(
            type: FormMetricType.kneeAlignment,
            error: (sample) => (180 - sample.kneeAngle).abs(),
            allowedError: 30,
            issue: FormIssue.incompleteLockout,
          )
        : _notObservable(FormMetricType.kneeAlignment);
    metrics[FormMetricType.control] = alignmentMetric(
      type: FormMetricType.control,
      error: (sample) => sample.shoulderHipRelativeMovement.abs(),
      allowedError: 0.08,
      issue: FormIssue.unstableControl,
    );
    final control = metrics[FormMetricType.control]!;
    metrics[FormMetricType.balance] = FormMetricResult(
      type: FormMetricType.balance,
      status: control.status,
      score: control.score,
      confidence: control.confidence,
      persistence: control.persistence,
      issue: control.issue,
      value: control.value,
      threshold: control.threshold,
    );
    metrics[FormMetricType.heelContact] = _notObservable(
      FormMetricType.heelContact,
    );
    metrics[FormMetricType.descentTempo] = _notObservable(
      FormMetricType.descentTempo,
    );
    metrics[FormMetricType.ascentTempo] = _notObservable(
      FormMetricType.ascentTempo,
    );
    final legExtension = metrics[FormMetricType.kneeAlignment]!;
    metrics[FormMetricType.lockout] = FormMetricResult(
      type: FormMetricType.lockout,
      status: legExtension.status,
      score: legExtension.score,
      confidence: legExtension.confidence,
      persistence: legExtension.persistence,
      issue: legExtension.issue,
      value: legExtension.value,
      threshold: legExtension.threshold,
    );

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
