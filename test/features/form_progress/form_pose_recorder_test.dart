import 'package:flutter_test/flutter_test.dart';
import 'package:motionfit_squat/features/form_progress/application/form_pose_recorder.dart';
import 'package:motionfit_squat/features/form_progress/domain/form_pose_snapshot.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_enums.dart';

/// Builds a full 33-point frame whose x value marks the frame, so the test can
/// tell which buffered frame the recorder picked.
List<double> frameValues(double marker) => [
  for (var index = 0; index < 33; index++) ...[marker, index / 33, 0.9],
];

void addFrame(FormPoseRecorder recorder, int timestampUs, double marker) {
  recorder.addFrame(
    timestampUs: timestampUs,
    flatXyConfidence: frameValues(marker),
    sourceWidth: 640,
    sourceHeight: 480,
    mirrored: true,
  );
}

FormPoseSnapshot? capture(
  FormPoseRecorder recorder, {
  required String repId,
  double? score = 70,
  int? bottomAtUs = 1000,
  DateTime? at,
  FormIssue? issue,
  FormProgressSource source = FormProgressSource.freeWorkout,
}) => recorder.snapshotForRep(
  sessionId: 's',
  repId: repId,
  capturedAt: at ?? DateTime(2026, 5, 1, 8),
  score: score,
  accuracy: 0.82,
  primaryIssue: issue,
  bottomAtUs: bottomAtUs,
  sourceType: source,
);

void main() {
  test('an unscored rep produces no snapshot', () {
    final recorder = FormPoseRecorder();
    addFrame(recorder, 1000, 0.1);

    expect(capture(recorder, repId: 'r1', score: null), isNull);
  });

  test('a rep with no buffered frame produces no snapshot', () {
    final recorder = FormPoseRecorder();

    expect(capture(recorder, repId: 'r1'), isNull);
  });

  test('incomplete landmark frames are ignored', () {
    final recorder = FormPoseRecorder();
    recorder.addFrame(
      timestampUs: 1000,
      flatXyConfidence: const [0.1, 0.2, 0.9],
      sourceWidth: 640,
      sourceHeight: 480,
      mirrored: false,
    );

    expect(capture(recorder, repId: 'r1'), isNull);
  });

  test('the frame closest to the rep bottom is chosen', () {
    final recorder = FormPoseRecorder();
    addFrame(recorder, 1000, 0.10);
    addFrame(recorder, 2000, 0.20);
    addFrame(recorder, 3000, 0.30);

    final snapshot = capture(
      recorder,
      repId: 'r1',
      bottomAtUs: 2100,
      issue: FormIssue.insufficientDepth,
    );

    expect(snapshot, isNotNull);
    expect(snapshot!.landmarks.first.x, closeTo(0.20, 0.0001));
    expect(snapshot.landmarks.length, 33);
    expect(snapshot.primaryIssue, FormIssue.insufficientDepth);
    expect(snapshot.mirrored, isTrue);
    expect(snapshot.sourceWidth, 640);
    expect(snapshot.accuracy, closeTo(0.82, 0.0001));
  });

  test('only the first scored rep of a session is captured', () {
    final recorder = FormPoseRecorder();
    addFrame(recorder, 1000, 0.10);

    final first = capture(recorder, repId: 'r1', score: 62);
    final second = capture(recorder, repId: 'r2', score: 91);
    final third = capture(recorder, repId: 'r3', score: 40);

    expect(first, isNotNull);
    expect(first!.repId, 'r1');
    expect(first.formScore, 62);
    expect(
      second,
      isNull,
      reason: 'a later rep must not replace the first, even scoring higher',
    );
    expect(third, isNull);
  });

  test('an unscored opening rep does not consume the daily capture', () {
    final recorder = FormPoseRecorder();
    addFrame(recorder, 1000, 0.10);

    expect(capture(recorder, repId: 'r1', score: null), isNull);
    final scored = capture(recorder, repId: 'r2', score: 58);

    expect(scored, isNotNull);
    expect(scored!.repId, 'r2');
  });

  test('the snapshot carries the day key of the rep', () {
    final recorder = FormPoseRecorder();
    addFrame(recorder, 1000, 0.10);

    final snapshot = capture(
      recorder,
      repId: 'r1',
      at: DateTime(2026, 9, 10, 21, 30),
    );

    expect(snapshot!.capturedOn, '2026-09-10');
  });

  test('the workout source is recorded on the snapshot', () {
    final recorder = FormPoseRecorder();
    addFrame(recorder, 1000, 0.10);

    final snapshot = capture(
      recorder,
      repId: 'r1',
      source: FormProgressSource.challenge,
    );

    expect(snapshot!.sourceType, FormProgressSource.challenge);
  });

  test('the buffer keeps only the most recent frames', () {
    final recorder = FormPoseRecorder(windowLength: 3);
    addFrame(recorder, 1000, 0.10);
    addFrame(recorder, 2000, 0.20);
    addFrame(recorder, 3000, 0.30);
    addFrame(recorder, 4000, 0.40);

    // The oldest frame is gone, so the nearest remaining one is used instead.
    final snapshot = capture(recorder, repId: 'r1', bottomAtUs: 1000);

    expect(snapshot!.landmarks.first.x, closeTo(0.20, 0.0001));
  });

  test('reset clears both the buffer and the captured flag', () {
    final recorder = FormPoseRecorder();
    addFrame(recorder, 1000, 0.10);
    expect(capture(recorder, repId: 'r1'), isNotNull);
    expect(capture(recorder, repId: 'r2'), isNull);

    recorder.reset();
    expect(
      capture(recorder, repId: 'r3'),
      isNull,
      reason: 'the buffer is empty after a reset',
    );

    addFrame(recorder, 5000, 0.55);
    expect(
      capture(recorder, repId: 'r4', bottomAtUs: 5000),
      isNotNull,
      reason: 'the next session captures its own first rep',
    );
  });
}
