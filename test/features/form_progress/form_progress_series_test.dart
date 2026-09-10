import 'package:flutter_test/flutter_test.dart';
import 'package:motionfit_squat/features/exercise/domain/exercise_type.dart';
import 'package:motionfit_squat/features/form_progress/domain/form_pose_snapshot.dart';
import 'package:motionfit_squat/features/form_progress/domain/form_progress_point.dart';
import 'package:motionfit_squat/features/form_progress/domain/form_progress_series.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_enums.dart';

FormProgressPoint point({
  required String id,
  required DateTime date,
  double? score,
  double? accuracy,
  List<FormIssue> issues = const [],
}) => FormProgressPoint(
  sessionId: id,
  exerciseType: ExerciseType.squat,
  workoutDate: date,
  formScore: score,
  accuracy: accuracy,
  reps: 10,
  durationSeconds: 120,
  issues: issues,
);

FormPoseSnapshot snapshot(String sessionId, DateTime date, double score) =>
    FormPoseSnapshot(
      sessionId: sessionId,
      repId: '$sessionId:1',
      capturedAt: date,
      capturedOn: FormPoseSnapshot.dayKey(date),
      formScore: score,
      accuracy: 0.85,
      primaryIssue: null,
      landmarks: List.generate(
        33,
        (index) => FormPosePoint(x: 0.5, y: index / 33, confidence: 0.9),
      ),
      sourceWidth: 640,
      sourceHeight: 480,
      mirrored: false,
      createdAt: date,
    );

void main() {
  final origin = DateTime(2026, 4, 1, 7);

  test('an empty series exposes no scores or deltas', () {
    final series = FormProgressSeries(
      exerciseType: ExerciseType.squat,
      points: const [],
    );

    expect(series.isEmpty, isTrue);
    expect(series.sessionCount, 0);
    expect(series.firstScore, isNull);
    expect(series.latestScore, isNull);
    expect(series.scoreDelta, isNull);
    expect(series.bestScore, isNull);
  });

  test('points sort oldest first and expose first and latest scores', () {
    final series = FormProgressSeries(
      exerciseType: ExerciseType.squat,
      points: [
        point(
          id: 'c',
          date: origin.add(const Duration(days: 29)),
          score: 84,
        ),
        point(id: 'a', date: origin, score: 62),
        point(id: 'b', date: origin.add(const Duration(days: 6)), score: 71),
      ],
    );

    expect(series.firstScore, 62);
    expect(series.latestScore, 84);
    expect(series.scoreDelta, 22);
    expect(series.bestScore, 84);
    expect(series.dayNumberOf(series.points.last), 30);
  });

  test('a single scored session reports no delta', () {
    final series = FormProgressSeries(
      exerciseType: ExerciseType.squat,
      points: [point(id: 'a', date: origin, score: 62)],
    );

    expect(series.firstScore, 62);
    expect(series.latestScore, 62);
    expect(series.scoreDelta, isNull);
  });

  test('unscored sessions stay in history but not in the trend', () {
    final series = FormProgressSeries(
      exerciseType: ExerciseType.squat,
      points: [
        point(id: 'a', date: origin, score: 60),
        point(id: 'b', date: origin.add(const Duration(days: 1))),
        point(id: 'c', date: origin.add(const Duration(days: 2)), score: 70),
      ],
    );

    expect(series.sessionCount, 3);
    expect(series.scoredPoints.length, 2);
    expect(series.scoreDelta, 10);
  });

  test('a declining score yields a negative delta', () {
    final series = FormProgressSeries(
      exerciseType: ExerciseType.squat,
      points: [
        point(id: 'a', date: origin, score: 80),
        point(id: 'b', date: origin.add(const Duration(days: 3)), score: 68),
      ],
    );

    expect(series.scoreDelta, -12);
  });

  test('accuracy delta follows the same first-to-latest rule', () {
    final series = FormProgressSeries(
      exerciseType: ExerciseType.squat,
      points: [
        point(id: 'a', date: origin, score: 60, accuracy: 0.7),
        point(
          id: 'b',
          date: origin.add(const Duration(days: 5)),
          score: 75,
          accuracy: 0.9,
        ),
      ],
    );

    expect(series.firstAccuracy, 0.7);
    expect(series.latestAccuracy, 0.9);
    expect(series.accuracyDelta, closeTo(0.2, 0.0001));
  });

  test('issues are tallied most frequent first', () {
    final series = FormProgressSeries(
      exerciseType: ExerciseType.squat,
      points: [
        point(
          id: 'a',
          date: origin,
          score: 60,
          issues: const [FormIssue.insufficientDepth, FormIssue.kneeAlignment],
        ),
        point(
          id: 'b',
          date: origin.add(const Duration(days: 1)),
          score: 65,
          issues: const [FormIssue.insufficientDepth],
        ),
      ],
    );

    final tallies = series.topIssues;
    expect(tallies.first.issue, FormIssue.insufficientDepth);
    expect(tallies.first.count, 2);
    expect(tallies.last.issue, FormIssue.kneeAlignment);
    expect(tallies.last.count, 1);
  });

  test('an issue only in the earlier half counts as resolved', () {
    final series = FormProgressSeries(
      exerciseType: ExerciseType.squat,
      points: [
        point(
          id: 'a',
          date: origin,
          score: 60,
          issues: const [FormIssue.insufficientDepth],
        ),
        point(
          id: 'b',
          date: origin.add(const Duration(days: 1)),
          score: 62,
          issues: const [FormIssue.insufficientDepth],
        ),
        point(
          id: 'c',
          date: origin.add(const Duration(days: 2)),
          score: 78,
          issues: const [FormIssue.kneeAlignment],
        ),
        point(
          id: 'd',
          date: origin.add(const Duration(days: 3)),
          score: 82,
          issues: const [FormIssue.kneeAlignment],
        ),
      ],
    );

    expect(series.resolvedIssues, const [FormIssue.insufficientDepth]);
  });

  test('too little history reports nothing as resolved', () {
    final series = FormProgressSeries(
      exerciseType: ExerciseType.squat,
      points: [
        point(
          id: 'a',
          date: origin,
          score: 60,
          issues: const [FormIssue.insufficientDepth],
        ),
        point(id: 'b', date: origin.add(const Duration(days: 1)), score: 70),
      ],
    );

    expect(series.resolvedIssues, isEmpty);
  });

  test('posed points expose only sessions that stored a pose', () {
    final second = origin.add(const Duration(days: 7));
    final series = FormProgressSeries(
      exerciseType: ExerciseType.squat,
      points: [
        point(id: 'a', date: origin, score: 60),
        point(id: 'b', date: second, score: 75),
      ],
      poses: {'b': snapshot('b', second, 75)},
    );

    expect(series.posedPoints.length, 1);
    expect(series.posedPoints.single.sessionId, 'b');
    expect(series.poseFor(series.points.first), isNull);
  });

  test('a pose snapshot survives an encode and decode round trip', () {
    final original = snapshot('a', origin, 71);
    final restored = FormPoseSnapshot.fromMap(original.toMap());

    expect(restored.sessionId, 'a');
    expect(restored.formScore, 71);
    expect(restored.landmarks.length, 33);
    expect(restored.isRenderable, isTrue);
    expect(restored.landmarks[10].x, closeTo(0.5, 0.0001));
    expect(
      restored.landmarks[10].y,
      closeTo(original.landmarks[10].y, 0.0001),
    );
  });
}
