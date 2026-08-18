import 'package:flutter_test/flutter_test.dart';
import 'package:motionfit_squat/features/squat/domain/models/squat_metrics.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_enums.dart';
import 'package:motionfit_squat/features/squat/domain/services/form_analyzer.dart';

void main() {
  const analyzer = SquatFormAnalyzer();

  group('SquatFormAnalyzer', () {
    test('reports persistent observable side-view problems', () {
      final samples = List.generate(
        10,
        (index) => _metrics(
          index,
          cameraAngle: CameraAngle.side,
          kneeAngle: 135,
          hipAngle: 145,
          torsoLeanDegrees: 58,
          heelLift: 0.08,
        ),
      );

      final result = analyzer.analyze(_trace(samples));

      expect(result.detectedIssues, contains(FormIssue.insufficientDepth));
      expect(result.detectedIssues, contains(FormIssue.excessiveTorsoLean));
      expect(result.detectedIssues, contains(FormIssue.heelLift));
      expect(
        result.metrics[FormMetricType.lockout]!.status,
        FormMetricStatus.notObservable,
      );
      expect(
        result.metrics[FormMetricType.kneeAlignment]!.status,
        FormMetricStatus.notObservable,
      );
      expect(
        result.metrics[FormMetricType.balance]!.status,
        FormMetricStatus.notObservable,
      );
      expect(result.coverage, greaterThan(0));
    });

    test('reports front-view knee alignment and balance independently', () {
      final samples = List.generate(
        10,
        (index) => _metrics(
          index,
          cameraAngle: CameraAngle.front,
          kneeAlignmentDeviation: 0.13,
          balanceDeviation: 0.09,
          hipDrop: 0.16,
        ),
      );

      final result = analyzer.analyze(_trace(samples));

      expect(result.detectedIssues, contains(FormIssue.kneeAlignment));
      expect(result.detectedIssues, contains(FormIssue.leftRightImbalance));
      expect(
        result.metrics[FormMetricType.depth]!.status,
        FormMetricStatus.passed,
      );
      expect(
        result.metrics[FormMetricType.heelContact]!.status,
        FormMetricStatus.notObservable,
      );
    });

    test('does not flag a transient issue below the persistence threshold', () {
      final samples = List.generate(
        10,
        (index) => _metrics(
          index,
          cameraAngle: CameraAngle.side,
          heelLift: index == 4 ? 0.09 : 0.0,
          hipDrop: index == 4 ? 0.16 : 0.08,
        ),
      );

      final result = analyzer.analyze(_trace(samples));
      final heel = result.metrics[FormMetricType.heelContact]!;

      expect(heel.status, FormMetricStatus.passed);
      expect(heel.persistence, 0.2);
      expect(result.detectedIssues, isNot(contains(FormIssue.heelLift)));
    });

    test('judges depth around the bottom instead of the standing tail', () {
      const kneeAngles = <double>[
        175,
        160,
        130,
        105,
        90,
        90,
        105,
        130,
        160,
        175,
      ];
      final samples = List.generate(
        kneeAngles.length,
        (index) => _metrics(
          index,
          cameraAngle: CameraAngle.side,
          kneeAngle: kneeAngles[index],
        ),
      );

      final result = analyzer.analyze(_trace(samples));

      expect(
        result.metrics[FormMetricType.depth]!.status,
        FormMetricStatus.passed,
      );
      expect(
        result.detectedIssues,
        isNot(contains(FormIssue.insufficientDepth)),
      );
      expect(result.depthScore, 100);
    });

    test('never reports insufficient depth with a perfect depth score', () {
      const kneeAngles = <double>[150, 125, 100, 88, 92, 115, 145];
      final samples = List.generate(
        kneeAngles.length,
        (index) => _metrics(
          index,
          cameraAngle: CameraAngle.oblique,
          kneeAngle: kneeAngles[index],
        ),
      );

      final result = analyzer.analyze(_trace(samples));

      expect(result.depthScore, 100);
      expect(
        result.detectedIssues,
        isNot(contains(FormIssue.insufficientDepth)),
      );
    });

    test('withholds tempo and control coaching across a tracking gap', () {
      final samples = <SquatMetrics>[
        _metrics(0),
        _metrics(1),
        _metrics(12),
        _metrics(13),
      ];

      final result = analyzer.analyze(_trace(samples));

      expect(
        result.metrics[FormMetricType.descentTempo]!.status,
        FormMetricStatus.notObservable,
      );
      expect(
        result.metrics[FormMetricType.ascentTempo]!.status,
        FormMetricStatus.notObservable,
      );
      expect(
        result.metrics[FormMetricType.control]!.status,
        FormMetricStatus.notObservable,
      );
    });

    test('assesses depth from calibrated hip drop without visible ankles', () {
      final shallow = List.generate(
        7,
        (index) => _metrics(
          index,
          kneesObservable: false,
          hipDrop: index == 3 ? 0.08 : 0.05,
        ),
      );
      final deep = List.generate(
        7,
        (index) => _metrics(
          index,
          kneesObservable: false,
          hipDrop: index == 3 ? 0.16 : 0.08,
        ),
      );

      final shallowResult = analyzer.analyze(_trace(shallow));
      final deepResult = analyzer.analyze(_trace(deep));

      expect(
        shallowResult.detectedIssues,
        contains(FormIssue.insufficientDepth),
      );
      expect(
        deepResult.detectedIssues,
        isNot(contains(FormIssue.insufficientDepth)),
      );
    });

    test('withholds scores when landmark confidence is insufficient', () {
      final samples = List.generate(
        10,
        (index) =>
            _metrics(index, confidence: 0.45, cameraAngle: CameraAngle.oblique),
      );

      final result = analyzer.analyze(_trace(samples));

      expect(result.overallScore, isNull);
      expect(result.detectedIssues, isEmpty);
      expect(
        result.metrics.values.where(
          (metric) => metric.status == FormMetricStatus.needsAttention,
        ),
        isEmpty,
      );
    });

    test('empty traces are explicitly unscored', () {
      final result = analyzer.analyze(
        const RepMotionTrace(
          repSequence: 7,
          startedAtUs: 0,
          bottomAtUs: null,
          completedAtUs: 0,
          samples: [],
          detectionConfidence: 0,
        ),
      );

      expect(result.repSequence, 7);
      expect(result.metrics, isEmpty);
      expect(result.overallScore, isNull);
      expect(result.coverage, 0);
    });
  });
}

RepMotionTrace _trace(List<SquatMetrics> samples) => RepMotionTrace(
  repSequence: 1,
  startedAtUs: 0,
  bottomAtUs: 1000000,
  completedAtUs: 2000000,
  samples: samples,
  detectionConfidence: 0.95,
);

SquatMetrics _metrics(
  int index, {
  double confidence = 0.95,
  double kneeAngle = 175,
  double hipAngle = 170,
  double torsoLeanDegrees = 15,
  double heelLift = 0,
  double kneeAlignmentDeviation = 0.01,
  double balanceDeviation = 0.01,
  CameraAngle cameraAngle = CameraAngle.side,
  bool kneesObservable = true,
  double hipDrop = 0,
}) => SquatMetrics(
  timestampUs: index * 200000,
  confidence: confidence,
  leftKneeAngle: kneesObservable ? kneeAngle : null,
  rightKneeAngle: kneesObservable ? kneeAngle : null,
  kneeAngle: kneeAngle,
  leftHipAngle: hipAngle,
  rightHipAngle: hipAngle,
  hipAngle: hipAngle,
  hipY: 0.45,
  shoulderY: 0.20,
  bodyScale: 0.7,
  hipDrop: hipDrop,
  hipVelocity: 0,
  shoulderHipRelativeMovement: 0,
  torsoLeanDegrees: torsoLeanDegrees,
  leftHeelLift: heelLift,
  rightHeelLift: heelLift,
  kneeAlignmentDeviation: kneeAlignmentDeviation,
  balanceDeviation: balanceDeviation,
  cameraAngle: cameraAngle,
);
