import 'package:flutter_test/flutter_test.dart';
import 'package:motionfit_squat/features/squat/domain/models/pose_frame.dart';
import 'package:motionfit_squat/features/squat/domain/models/squat_metrics.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_enums.dart';
import 'package:motionfit_squat/features/squat/domain/services/form_analyzer.dart';
import 'package:motionfit_squat/features/squat/domain/services/rep_detector.dart';

import '../../../support/synthetic_pose.dart';

void main() {
  group('SquatRepDetector', () {
    test('counts a complete down-bottom-up cycle exactly once', () {
      final input = SyntheticPoseSequence();
      final detector = SquatRepDetector(
        initialCalibration: input.standingCalibration,
      );

      final events = _feed(detector, input.validRep());
      final completed = events
          .where((event) => event.type == RepEventType.completed)
          .toList();

      expect(detector.snapshot.count, 1);
      expect(completed, hasLength(1));
      expect(completed.single.trace, isNotNull);
      expect(completed.single.trace!.samples, isNotEmpty);
      expect(
        completed.single.trace!.completedAtUs,
        greaterThan(completed.single.trace!.startedAtUs),
      );
    });

    test('counts a continuous fast repetition without a bottom hold', () {
      final input = SyntheticPoseSequence(frameIntervalUs: 66667);
      final detector = SquatRepDetector(
        initialCalibration: input.standingCalibration,
      );

      final events = _feed(detector, [
        ...input.hold(0, 5),
        ...input.ramp(0, 1, 9),
        ...input.ramp(1, 0, 9),
        ...input.hold(0, 8),
      ]);

      expect(
        events.where((event) => event.type == RepEventType.completed),
        hasLength(1),
      );
      expect(detector.snapshot.count, 1);
    });

    test('counts when usable landmarks have moderate confidence', () {
      final input = SyntheticPoseSequence();
      final detector = SquatRepDetector(
        initialCalibration: input.standingCalibration,
      );

      final events = _feed(
        detector,
        input.validRep().map((frame) => _withLandmarkConfidence(frame, 0.5)),
      );

      expect(
        events.where((event) => event.type == RepEventType.completed),
        hasLength(1),
      );
      expect(detector.snapshot.count, 1);
    });

    test('falls back to image landmarks when world landmarks are empty', () {
      final input = SyntheticPoseSequence();
      final detector = SquatRepDetector(
        initialCalibration: input.standingCalibration,
      );

      final events = _feed(
        detector,
        input.validRep().map(_withEmptyWorldLandmarks),
      );

      expect(
        events.where((event) => event.type == RepEventType.completed),
        hasLength(1),
      );
      expect(detector.snapshot.count, 1);
    });

    test('counts ten separated valid repetitions', () {
      final input = SyntheticPoseSequence();
      final detector = SquatRepDetector(
        initialCalibration: input.standingCalibration,
      );

      final events = <RepEvent>[];
      for (var index = 0; index < 10; index++) {
        events.addAll(_feed(detector, input.validRep()));
      }

      expect(detector.snapshot.count, 10);
      expect(
        events.where((event) => event.type == RepEventType.completed),
        hasLength(10),
      );
    });

    test('small standing jitter never becomes a repetition', () {
      final input = SyntheticPoseSequence();
      final detector = SquatRepDetector(
        initialCalibration: input.standingCalibration,
      );

      final frames = <PoseFrame>[];
      for (var index = 0; index < 240; index++) {
        frames.add(input.frame(depth: index.isEven ? 0.0 : 0.018));
      }
      final events = _feed(detector, frames);

      expect(detector.snapshot.count, 0);
      expect(
        events.where((event) => event.type == RepEventType.started),
        isEmpty,
      );
    });

    test('standing side-to-side sway never becomes a repetition', () {
      final input = SyntheticPoseSequence();
      final detector = SquatRepDetector(
        initialCalibration: input.standingCalibration,
      );

      final frames = List.generate(
        160,
        (index) =>
            _translateHorizontally(input.frame(), index.isEven ? -0.09 : 0.09),
      );
      final events = _feed(detector, frames);

      expect(detector.snapshot.count, 0);
      expect(
        events.where((event) => event.type == RepEventType.started),
        isEmpty,
      );
    });

    test('a short tracking loss holds the in-progress repetition', () {
      final input = SyntheticPoseSequence();
      final detector = SquatRepDetector(
        initialCalibration: input.standingCalibration,
      );
      final events = <RepEvent>[];

      events.addAll(_feed(detector, input.hold(0, 6)));
      events.addAll(_feed(detector, input.ramp(0, 0.65, 18)));
      events.addAll(_feed(detector, input.trackingGap(4)));
      events.addAll(_feed(detector, input.ramp(0.65, 1, 10)));
      events.addAll(_feed(detector, input.hold(1, 12)));
      events.addAll(_feed(detector, input.ramp(1, 0, 24)));
      events.addAll(_feed(detector, input.hold(0, 20)));

      expect(
        events.where((event) => event.type == RepEventType.trackingLost),
        isEmpty,
      );
      expect(
        events.where((event) => event.type == RepEventType.completed),
        hasLength(1),
      );
      expect(detector.snapshot.count, 1);
    });

    test('tracking loss never pauses the workout phase', () {
      final input = SyntheticPoseSequence();
      final detector = SquatRepDetector(
        initialCalibration: input.standingCalibration,
      );

      _feed(detector, input.hold(0, 6));
      _feed(detector, input.ramp(0, 0.75, 18));
      final lostEvents = _feed(detector, input.trackingGap(12));

      expect(
        lostEvents.where((event) => event.type == RepEventType.trackingLost),
        hasLength(1),
      );
      expect(detector.snapshot.phase, isNot(SquatPhase.trackingLost));
      expect(detector.snapshot.phase, isNot(SquatPhase.paused));

      _feed(detector, input.hold(0, 8));
      _feed(detector, input.validRep());
      expect(detector.snapshot.count, 1);
    });

    test('reports a shallow attempt without counting it as a rep', () {
      final input = SyntheticPoseSequence();
      final detector = SquatRepDetector(
        initialCalibration: input.standingCalibration,
      );

      final events = _feed(detector, [
        ...input.hold(0, 6),
        ...input.ramp(0, 0.2, 10),
        ...input.ramp(0.2, 0, 10),
        ...input.hold(0, 8),
      ]);

      expect(
        events.where((event) => event.type == RepEventType.shallowAttempt),
        hasLength(1),
      );
      expect(
        events.where((event) => event.type == RepEventType.completed),
        isEmpty,
      );
      expect(detector.snapshot.count, 0);
    });

    test('calibrates and counts with shoulders through knees only', () {
      final input = SyntheticPoseSequence();
      final detector = SquatRepDetector();

      final calibrationEvents = _feed(
        detector,
        input.hold(0, 40, anklesVisible: false),
      );
      expect(
        calibrationEvents.where(
          (event) => event.type == RepEventType.calibrated,
        ),
        hasLength(1),
      );

      _feed(detector, input.validRep(anklesVisible: false));
      expect(detector.snapshot.count, 1);
      expect(detector.snapshot.phase, isNot(SquatPhase.trackingLost));
    });

    test(
      'pause cancels an attempt and resume cannot count paused movement',
      () {
        final input = SyntheticPoseSequence();
        final detector = SquatRepDetector(
          initialCalibration: input.standingCalibration,
        );

        _feed(detector, input.hold(0, 6));
        _feed(detector, input.ramp(0, 0.7, 16));
        detector.pause(input.timestampUs);
        _feed(detector, input.validRep());
        expect(detector.snapshot.count, 0);

        detector.resume(input.timestampUs);
        _feed(detector, input.hold(0, 8));
        _feed(detector, input.validRep());

        expect(detector.snapshot.count, 1);
      },
    );

    test('refractory prevents duplicates but accepts the next full cycle', () {
      final input = SyntheticPoseSequence();
      final detector = SquatRepDetector(
        initialCalibration: input.standingCalibration,
      );

      _feedUntilCompleted(detector, input);
      expect(detector.snapshot.count, 1);

      _feed(detector, input.ramp(0, 1, 16));
      _feed(detector, input.hold(1, 8));
      _feed(detector, input.ramp(1, 0, 16));
      _feed(detector, input.hold(0, 12));
      expect(detector.snapshot.count, 2);

      _feed(detector, input.validRep());
      expect(detector.snapshot.count, 3);
    });

    test('an interrupted shallow descent cannot double-count the next rep', () {
      final input = SyntheticPoseSequence();
      final detector = SquatRepDetector(
        initialCalibration: input.standingCalibration,
      );
      final events = <RepEvent>[];

      events.addAll(_feed(detector, input.hold(0, 6)));
      events.addAll(_feed(detector, input.ramp(0, 0.18, 12)));
      events.addAll(_feed(detector, input.ramp(0.18, 0, 12)));
      events.addAll(_feed(detector, input.hold(0, 12)));
      expect(detector.snapshot.count, 0);

      events.addAll(_feed(detector, input.validRep()));

      expect(detector.snapshot.count, 1);
      expect(
        events.where((event) => event.type == RepEventType.completed),
        hasLength(1),
      );
    });

    test(
      'a detector-valid shallow rep is counted and receives a depth flag',
      () {
        final input = SyntheticPoseSequence();
        final detector = SquatRepDetector(
          initialCalibration: input.standingCalibration,
        );
        final completed = _feed(
          detector,
          _repAtPeakDepth(input, 0.60),
        ).singleWhere((event) => event.type == RepEventType.completed);

        final analysis = const SquatFormAnalyzer().analyze(completed.trace!);

        expect(detector.snapshot.count, 1);
        expect(analysis.detectedIssues, contains(FormIssue.insufficientDepth));
      },
    );

    test('incomplete lockout never merges consecutive repetitions', () {
      final input = SyntheticPoseSequence();
      final detector = SquatRepDetector(
        initialCalibration: input.standingCalibration,
      );

      final events = _feed(detector, [
        ...input.hold(0, 6),
        ...input.ramp(0, 1, 20),
        ...input.hold(1, 6),
        ...input.ramp(1, 0.25, 20),
        ...input.hold(0.25, 12),
        ...input.ramp(0.25, 1, 20),
        ...input.hold(1, 6),
        ...input.ramp(1, 0.25, 20),
        ...input.hold(0.25, 12),
      ]);

      expect(
        events.where((event) => event.type == RepEventType.completed),
        hasLength(2),
      );
      expect(detector.snapshot.count, 2);
    });

    test('a torso-lean flag does not invalidate a counted repetition', () {
      final input = SyntheticPoseSequence();
      final detector = SquatRepDetector(
        initialCalibration: input.standingCalibration,
      );
      final completed = _feed(
        detector,
        input.validRep(),
      ).singleWhere((event) => event.type == RepEventType.completed);
      final trace = _traceWithForm(completed.trace!, torsoLeanDegrees: 65);

      final analysis = const SquatFormAnalyzer().analyze(trace);

      expect(detector.snapshot.count, 1);
      expect(analysis.detectedIssues, contains(FormIssue.excessiveTorsoLean));
    });

    test('a heel-lift flag does not invalidate a counted repetition', () {
      final input = SyntheticPoseSequence();
      final detector = SquatRepDetector(
        initialCalibration: input.standingCalibration,
      );
      final completed = _feed(
        detector,
        input.validRep(),
      ).singleWhere((event) => event.type == RepEventType.completed);
      final trace = _traceWithForm(completed.trace!, heelLift: 0.08);

      final analysis = const SquatFormAnalyzer().analyze(trace);

      expect(detector.snapshot.count, 1);
      expect(analysis.detectedIssues, contains(FormIssue.heelLift));
    });

    test('multiple bad-form flags never subtract a completed repetition', () {
      final input = SyntheticPoseSequence();
      final detector = SquatRepDetector(
        initialCalibration: input.standingCalibration,
      );
      final completed = _feed(
        detector,
        input.validRep(),
      ).singleWhere((event) => event.type == RepEventType.completed);
      final original = completed.trace!;
      final deliberatelyBadTrace = _traceWithForm(
        original,
        kneeAngle: 135,
        torsoLeanDegrees: 65,
        heelLift: 0.08,
      );

      final analysis = const SquatFormAnalyzer().analyze(deliberatelyBadTrace);

      expect(analysis.detectedIssues, contains(FormIssue.excessiveTorsoLean));
      expect(analysis.detectedIssues, contains(FormIssue.insufficientDepth));
      expect(analysis.detectedIssues, contains(FormIssue.heelLift));
      expect(detector.snapshot.count, 1);
    });
  });
}

List<PoseFrame> _repAtPeakDepth(
  SyntheticPoseSequence input,
  double peakDepth,
) => [
  ...input.hold(0, 6),
  ...input.ramp(0, peakDepth, 24),
  ...input.hold(peakDepth, 12),
  ...input.ramp(peakDepth, 0, 24),
  ...input.hold(0, 20),
];

PoseFrame _translateHorizontally(PoseFrame frame, double offset) {
  List<PoseLandmark> translate(List<PoseLandmark> points) => points
      .map(
        (point) => PoseLandmark(
          x: point.x + offset,
          y: point.y,
          z: point.z,
          visibility: point.visibility,
          presence: point.presence,
        ),
      )
      .toList(growable: false);

  return PoseFrame(
    sequenceId: frame.sequenceId,
    timestampUs: frame.timestampUs,
    landmarks: translate(frame.landmarks),
    worldLandmarks: translate(frame.worldLandmarks),
    trackingState: frame.trackingState,
    peopleCount: frame.peopleCount,
    mirrored: frame.mirrored,
    rotationDegrees: frame.rotationDegrees,
    inputWidth: frame.inputWidth,
    inputHeight: frame.inputHeight,
    inferenceLatencyMilliseconds: frame.inferenceLatencyMilliseconds,
  );
}

PoseFrame _withLandmarkConfidence(PoseFrame frame, double confidence) {
  List<PoseLandmark> update(List<PoseLandmark> points) => points
      .map(
        (point) => PoseLandmark(
          x: point.x,
          y: point.y,
          z: point.z,
          visibility: confidence,
          presence: confidence,
        ),
      )
      .toList(growable: false);

  return _copyPoseFrame(
    frame,
    landmarks: update(frame.landmarks),
    worldLandmarks: update(frame.worldLandmarks),
  );
}

PoseFrame _withEmptyWorldLandmarks(PoseFrame frame) => _copyPoseFrame(
  frame,
  worldLandmarks: List.filled(
    33,
    const PoseLandmark(x: 0, y: 0, z: 0, visibility: 0, presence: 0),
  ),
);

PoseFrame _copyPoseFrame(
  PoseFrame frame, {
  List<PoseLandmark>? landmarks,
  List<PoseLandmark>? worldLandmarks,
}) => PoseFrame(
  sequenceId: frame.sequenceId,
  timestampUs: frame.timestampUs,
  landmarks: landmarks ?? frame.landmarks,
  worldLandmarks: worldLandmarks ?? frame.worldLandmarks,
  trackingState: frame.trackingState,
  peopleCount: frame.peopleCount,
  mirrored: frame.mirrored,
  rotationDegrees: frame.rotationDegrees,
  inputWidth: frame.inputWidth,
  inputHeight: frame.inputHeight,
  inferenceLatencyMilliseconds: frame.inferenceLatencyMilliseconds,
  previewTransform: frame.previewTransform,
  previewHandlesCropAndRotation: frame.previewHandlesCropAndRotation,
);

RepMotionTrace _traceWithForm(
  RepMotionTrace source, {
  double? kneeAngle,
  double? torsoLeanDegrees,
  double? heelLift,
}) => RepMotionTrace(
  repSequence: source.repSequence,
  startedAtUs: source.startedAtUs,
  bottomAtUs: source.bottomAtUs,
  completedAtUs: source.completedAtUs,
  samples: source.samples
      .map(
        (sample) => SquatMetrics(
          timestampUs: sample.timestampUs,
          confidence: sample.confidence,
          leftKneeAngle: kneeAngle ?? sample.leftKneeAngle,
          rightKneeAngle: kneeAngle ?? sample.rightKneeAngle,
          kneeAngle: kneeAngle ?? sample.kneeAngle,
          leftHipAngle: sample.leftHipAngle,
          rightHipAngle: sample.rightHipAngle,
          hipAngle: sample.hipAngle,
          hipY: sample.hipY,
          shoulderY: sample.shoulderY,
          bodyScale: sample.bodyScale,
          hipDrop: sample.hipDrop,
          hipVelocity: sample.hipVelocity,
          shoulderHipRelativeMovement: sample.shoulderHipRelativeMovement,
          torsoLeanDegrees: torsoLeanDegrees ?? sample.torsoLeanDegrees,
          leftHeelLift: heelLift ?? sample.leftHeelLift,
          rightHeelLift: heelLift ?? sample.rightHeelLift,
          kneeAlignmentDeviation: sample.kneeAlignmentDeviation,
          balanceDeviation: sample.balanceDeviation,
          cameraAngle: sample.cameraAngle,
          biomechanics3d: sample.biomechanics3d,
        ),
      )
      .toList(growable: false),
  detectionConfidence: source.detectionConfidence,
);

List<RepEvent> _feed(SquatRepDetector detector, Iterable<PoseFrame> frames) {
  final events = <RepEvent>[];
  for (final frame in frames) {
    events.addAll(detector.addFrame(frame));
  }
  return events;
}

void _feedUntilCompleted(
  SquatRepDetector detector,
  SyntheticPoseSequence input,
) {
  final depths = <double>[
    ...List.filled(6, 0),
    ...List.generate(24, (index) => (index + 1) / 24),
    ...List.filled(12, 1),
    ...List.generate(24, (index) => 1 - (index + 1) / 24),
    ...List.filled(30, 0),
  ];
  for (final depth in depths) {
    final events = detector.addFrame(input.frame(depth: depth));
    if (events.any((event) => event.type == RepEventType.completed)) return;
  }
  fail('Synthetic cycle did not complete.');
}
