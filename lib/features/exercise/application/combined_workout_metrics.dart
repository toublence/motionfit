import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motionfit_squat/features/plank/records/application/records_providers.dart'
    as plank;
import 'package:motionfit_squat/features/pushup/records/application/records_providers.dart'
    as pushup;
import 'package:motionfit_squat/features/records/application/records_providers.dart'
    as squat;

class CombinedWorkoutMetrics {
  const CombinedWorkoutMetrics({
    required this.currentStreak,
    required this.streakAtRisk,
    required this.completedWorkoutCount,
    required this.distinctWorkoutDays,
  });

  final int currentStreak;
  final bool streakAtRisk;
  final int completedWorkoutCount;
  final int distinctWorkoutDays;
}

final combinedWorkoutMetricsProvider = FutureProvider<CombinedWorkoutMetrics>((
  ref,
) async {
  final squatFuture = ref.watch(squat.allSessionsProvider.future);
  final pushupFuture = ref.watch(pushup.allSessionsProvider.future);
  final plankFuture = ref.watch(plank.allSessionsProvider.future);
  final squatSessions = await squatFuture;
  final pushupSessions = await pushupFuture;
  final plankSessions = await plankFuture;
  final workoutDates = <DateTime>{};
  var completedWorkoutCount = 0;

  void addSession({
    required DateTime startedAt,
    required DateTime? endedAt,
    required bool completed,
    required bool interrupted,
    required int totalReps,
  }) {
    if (!completed || interrupted || totalReps <= 0) return;
    completedWorkoutCount++;
    final completedAt = (endedAt ?? startedAt).toLocal();
    workoutDates.add(
      DateTime(completedAt.year, completedAt.month, completedAt.day),
    );
  }

  for (final details in squatSessions) {
    final session = details.session;
    addSession(
      startedAt: session.startedAt,
      endedAt: session.endedAt,
      completed: session.completed,
      interrupted: session.interrupted,
      totalReps: session.totalReps,
    );
  }
  for (final details in pushupSessions) {
    final session = details.session;
    addSession(
      startedAt: session.startedAt,
      endedAt: session.endedAt,
      completed: session.completed,
      interrupted: session.interrupted,
      totalReps: session.totalReps,
    );
  }
  for (final details in plankSessions) {
    final session = details.session;
    addSession(
      startedAt: session.startedAt,
      endedAt: session.endedAt,
      completed: session.completed,
      interrupted: session.interrupted,
      totalReps: session.totalReps,
    );
  }

  final now = DateTime.now().toLocal();
  final today = DateTime(now.year, now.month, now.day);
  final trainedToday = workoutDates.contains(today);
  var cursor = trainedToday
      ? today
      : DateTime(today.year, today.month, today.day - 1);
  var currentStreak = 0;
  while (workoutDates.contains(cursor)) {
    currentStreak++;
    cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
  }

  return CombinedWorkoutMetrics(
    currentStreak: currentStreak,
    streakAtRisk: !trainedToday && currentStreak > 0,
    completedWorkoutCount: completedWorkoutCount,
    distinctWorkoutDays: workoutDates.length,
  );
});
