import 'package:motionfit_squat/features/pushup/records/domain/workout_session_details.dart';
import 'package:motionfit_squat/features/pushup/domain/services/workout_session_policy.dart';

class RetentionMetrics {
  const RetentionMetrics({
    required this.todayReps,
    required this.todaySets,
    required this.currentStreak,
    required this.streakAtRisk,
    required this.completedWorkoutCount,
    required this.distinctWorkoutDays,
  });

  factory RetentionMetrics.fromSessions(
    List<WorkoutSessionDetails> sessions, {
    DateTime? now,
  }) {
    final localNow = (now ?? DateTime.now()).toLocal();
    final today = _dateOnly(localNow);
    final workoutDates = <DateTime>{};
    var todayReps = 0;
    var todaySets = 0;
    var completedWorkoutCount = 0;

    for (final details in sessions) {
      final session = details.session;
      if (!WorkoutSessionPolicy.canUpdateChallenge(session)) continue;
      completedWorkoutCount++;
      final date = _dateOnly((session.endedAt ?? session.startedAt).toLocal());
      workoutDates.add(date);
      if (date == today) {
        todayReps += session.totalReps;
        todaySets += session.completedSetCount;
      }
    }

    final trainedToday = workoutDates.contains(today);
    var cursor = trainedToday ? today : _previousDay(today);
    var currentStreak = 0;
    while (workoutDates.contains(cursor)) {
      currentStreak++;
      cursor = _previousDay(cursor);
    }

    return RetentionMetrics(
      todayReps: todayReps,
      todaySets: todaySets,
      currentStreak: currentStreak,
      streakAtRisk: !trainedToday && currentStreak > 0,
      completedWorkoutCount: completedWorkoutCount,
      distinctWorkoutDays: workoutDates.length,
    );
  }

  final int todayReps;
  final int todaySets;
  final int currentStreak;
  final bool streakAtRisk;
  final int completedWorkoutCount;
  final int distinctWorkoutDays;

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static DateTime _previousDay(DateTime value) =>
      DateTime(value.year, value.month, value.day - 1);
}
