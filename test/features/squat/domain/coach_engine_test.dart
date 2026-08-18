import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_enums.dart';
import 'package:motionfit_squat/features/squat/domain/services/coach_engine.dart';
import 'package:motionfit_squat/features/squat/domain/services/form_analyzer.dart';

void main() {
  group('CoachPolicy', () {
    test('coaches an issue observed twice within three repetitions', () {
      final policy = CoachPolicy();

      expect(
        policy.selectIssue(
          _analysis(
            FormIssue.insufficientDepth,
            repSequence: 1,
            confidence: 0.82,
            persistence: 0.45,
          ),
        ),
        isNull,
      );
      expect(policy.selectIssue(_analysis(null, repSequence: 2)), isNull);
      expect(
        policy.selectIssue(
          _analysis(
            FormIssue.insufficientDepth,
            repSequence: 3,
            confidence: 0.84,
            persistence: 0.55,
          ),
        ),
        FormIssue.insufficientDepth,
      );
    });

    test('coaches a clearly observed safety issue immediately', () {
      final policy = CoachPolicy();

      expect(
        policy.selectIssue(
          _analysis(
            FormIssue.heelLift,
            repSequence: 1,
            confidence: 0.94,
            persistence: 0.75,
          ),
        ),
        FormIssue.heelLift,
      );
    });

    test('does not repeat the same cue again within three repetitions', () {
      final policy = CoachPolicy();

      expect(
        policy.selectIssue(
          _analysis(
            FormIssue.kneeAlignment,
            repSequence: 1,
            confidence: 0.95,
            persistence: 0.8,
          ),
        ),
        FormIssue.kneeAlignment,
      );
      expect(
        policy.selectIssue(
          _analysis(
            FormIssue.kneeAlignment,
            repSequence: 2,
            confidence: 0.95,
            persistence: 0.8,
          ),
        ),
        isNull,
      );
    });

    test('leaves at least one repetition between different form cues', () {
      final policy = CoachPolicy();

      expect(
        policy.selectIssue(
          _analysis(
            FormIssue.kneeAlignment,
            repSequence: 1,
            confidence: 0.95,
            persistence: 0.8,
          ),
        ),
        FormIssue.kneeAlignment,
      );
      expect(
        policy.selectIssue(
          _analysis(
            FormIssue.excessiveTorsoLean,
            repSequence: 2,
            confidence: 0.95,
            persistence: 0.8,
          ),
        ),
        isNull,
      );
    });
  });

  group('CoachQueue', () {
    test('rep count preempts a lower-priority message', () async {
      final engine = _FakeVoiceEngine(blockFirst: true);
      final queue = CoachQueue(engine);
      final first = queue.enqueue(
        _message(CoachMessageType.encouragement, 'first', 'first'),
      );
      await engine.firstSpeakStarted.future;

      await queue.enqueue(_message(CoachMessageType.repCount, 'rep', 'rep'));
      await first;

      expect(engine.stopped, isTrue);
      expect(engine.spoken, ['first', 'rep']);
      await queue.dispose();
    });

    test('deduplicates messages during cooldown', () async {
      final engine = _FakeVoiceEngine();
      final queue = CoachQueue(
        engine,
        defaultCooldown: const Duration(minutes: 1),
      );

      await queue.enqueue(_message(CoachMessageType.repCount, 'one', 'rep-1'));
      await queue.enqueue(
        _message(CoachMessageType.repCount, 'duplicate', 'rep-1'),
      );

      expect(engine.spoken, ['one']);
      await queue.dispose();
    });

    test('allows at most one form cue per rep sequence', () async {
      final engine = _FakeVoiceEngine();
      final queue = CoachQueue(engine, defaultCooldown: Duration.zero);

      await queue.enqueue(
        _message(CoachMessageType.form, 'depth', 'depth-3', repSequence: 3),
      );
      await queue.enqueue(
        _message(CoachMessageType.form, 'heel', 'heel-3', repSequence: 3),
      );
      await queue.enqueue(
        _message(
          CoachMessageType.form,
          'depth next',
          'depth-4',
          repSequence: 4,
        ),
      );

      expect(engine.spoken, ['depth', 'depth next']);
      await queue.dispose();
    });

    test('drops expired messages before speech', () async {
      final engine = _FakeVoiceEngine();
      final queue = CoachQueue(engine);

      await queue.enqueue(
        CoachMessage(
          type: CoachMessageType.form,
          text: 'stale',
          deduplicationKey: 'stale',
          createdAt: DateTime.now().subtract(const Duration(seconds: 5)),
          expiresAfter: const Duration(seconds: 1),
        ),
      );

      expect(engine.spoken, isEmpty);
      await queue.dispose();
    });

    test('retries one transient speech failure', () async {
      final engine = _FakeVoiceEngine(failFirstSpeak: true);
      final queue = CoachQueue(engine);

      await queue.enqueue(_message(CoachMessageType.form, 'depth', 'depth'));

      expect(engine.spoken, ['depth', 'depth']);
      expect(engine.stopped, isTrue);
      await queue.dispose();
    });
  });
}

FormAnalysisResult _analysis(
  FormIssue? issue, {
  int repSequence = 1,
  double confidence = 1,
  double persistence = 1,
}) {
  final metric = FormMetricResult(
    type: FormMetricType.depth,
    status: issue == null
        ? FormMetricStatus.passed
        : FormMetricStatus.needsAttention,
    score: issue == null ? 100 : 60,
    confidence: confidence,
    persistence: persistence,
    issue: issue,
  );
  return FormAnalysisResult(
    repSequence: repSequence,
    metrics: {FormMetricType.depth: metric},
    detectedIssues: issue == null ? const [] : [issue],
    primaryIssue: issue,
    depthScore: metric.score,
    controlScore: null,
    balanceScore: null,
    overallScore: metric.score,
    coverage: 1 / FormMetricType.values.length,
    cameraAngle: CameraAngle.side,
    confidence: confidence,
  );
}

CoachMessage _message(
  CoachMessageType type,
  String text,
  String key, {
  int? repSequence,
}) => CoachMessage(
  type: type,
  text: text,
  deduplicationKey: key,
  createdAt: DateTime.now(),
  repSequence: repSequence,
);

class _FakeVoiceEngine implements CoachVoiceEngine {
  _FakeVoiceEngine({this.blockFirst = false, this.failFirstSpeak = false});

  final bool blockFirst;
  final bool failFirstSpeak;
  final List<String> spoken = [];
  final Completer<void> firstSpeakStarted = Completer<void>();
  final Completer<void> releaseFirst = Completer<void>();
  var stopped = false;
  var disposed = false;

  @override
  Future<bool> configure({
    required String locale,
    required double rate,
  }) async => true;

  @override
  Future<void> speak(
    String text, {
    CoachMessageType type = CoachMessageType.form,
  }) async {
    spoken.add(text);
    if (failFirstSpeak && spoken.length == 1) {
      throw StateError('transient speech failure');
    }
    if (blockFirst && spoken.length == 1) {
      firstSpeakStarted.complete();
      await releaseFirst.future;
    }
  }

  @override
  Future<void> stop() async {
    stopped = true;
    if (blockFirst && !releaseFirst.isCompleted) releaseFirst.complete();
  }

  @override
  Future<void> dispose() async {
    disposed = true;
  }
}
