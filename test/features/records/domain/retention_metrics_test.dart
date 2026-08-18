import 'package:flutter_test/flutter_test.dart';
import 'package:motionfit_squat/features/records/domain/retention_metrics.dart';
import 'package:motionfit_squat/features/records/domain/workout_session_details.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_session.dart';

void main() {
  group('RetentionMetrics', () {
    test('counts a streak through today and aggregates today progress', () {
      final now = DateTime(2026, 7, 29, 12);
      final metrics = RetentionMetrics.fromSessions([
        _details(now, reps: 12, sets: 2),
        _details(now.subtract(const Duration(days: 1)), reps: 10),
        _details(now.subtract(const Duration(days: 2)), reps: 8),
      ], now: now);

      expect(metrics.todayReps, 12);
      expect(metrics.todaySets, 2);
      expect(metrics.currentStreak, 3);
      expect(metrics.streakAtRisk, isFalse);
      expect(metrics.completedWorkoutCount, 3);
      expect(metrics.distinctWorkoutDays, 3);
    });

    test('keeps yesterday streak at risk and ignores empty sessions', () {
      final now = DateTime(2026, 7, 29, 12);
      final metrics = RetentionMetrics.fromSessions([
        _details(now, reps: 0),
        _details(now.subtract(const Duration(days: 1)), reps: 10),
        _details(now.subtract(const Duration(days: 2)), reps: 10),
      ], now: now);

      expect(metrics.todayReps, 0);
      expect(metrics.currentStreak, 2);
      expect(metrics.streakAtRisk, isTrue);
      expect(metrics.completedWorkoutCount, 2);
      expect(metrics.distinctWorkoutDays, 2);
    });

    test('returns zero after a missed day', () {
      final now = DateTime(2026, 7, 29, 12);
      final metrics = RetentionMetrics.fromSessions([
        _details(now.subtract(const Duration(days: 2)), reps: 10),
      ], now: now);

      expect(metrics.currentStreak, 0);
      expect(metrics.streakAtRisk, isFalse);
    });

    test('uses completion day and excludes interrupted sessions', () {
      final now = DateTime(2026, 7, 29, 12);
      final completedAcrossMidnight = _details(
        DateTime(2026, 7, 28, 23, 58),
        reps: 10,
        endedAt: DateTime(2026, 7, 29, 0, 3),
      );
      final interrupted = _details(now, reps: 10, interrupted: true);

      final metrics = RetentionMetrics.fromSessions([
        completedAcrossMidnight,
        interrupted,
      ], now: now);

      expect(metrics.todayReps, 10);
      expect(metrics.currentStreak, 1);
      expect(metrics.completedWorkoutCount, 1);
    });
  });
}

WorkoutSessionDetails _details(
  DateTime startedAt, {
  required int reps,
  int sets = 1,
  bool completed = true,
  bool interrupted = false,
  DateTime? endedAt,
}) {
  final session = WorkoutSession(
    id: startedAt.toIso8601String(),
    startedAt: startedAt,
    endedAt: endedAt ?? startedAt.add(const Duration(minutes: 5)),
    plannedSetCount: sets,
    plannedRepsPerSet: reps,
    plannedRestSeconds: 60,
    completedSetCount: sets,
    totalReps: reps,
    activeDurationSeconds: 120,
    restDurationSeconds: 0,
    totalDurationSeconds: 120,
    averageRepDurationMilliseconds: 1000,
    completed: completed,
    interrupted: interrupted,
    createdAt: startedAt,
  );
  return WorkoutSessionDetails(
    session: session,
    sets: const [],
    reps: const [],
  );
}
