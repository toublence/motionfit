import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motionfit_squat/core/providers.dart';
import 'package:motionfit_squat/features/pushup/providers.dart' as pushup;
import 'package:motionfit_squat/features/plank/providers.dart' as plank;

class CompletedWorkout {
  const CompletedWorkout(this.id, this.exercise, this.completedAt);
  final String id;
  final String exercise;
  final DateTime completedAt;
  DateTime get day {
    final local = completedAt.toLocal();
    return DateTime(local.year, local.month, local.day);
  }
}

/// Pure classification across all exercise databases. A second completion on
/// the same day and a completion on the second workout date are different.
Map<String, Map<String, Object>> retentionMilestones(
  List<CompletedWorkout> workouts,
  String sessionId,
  String exercise,
) {
  final sorted = [...workouts]
    ..sort((a, b) {
      final time = a.completedAt.compareTo(b.completedAt);
      return time != 0
          ? time
          : '${a.exercise}:${a.id}'.compareTo('${b.exercise}:${b.id}');
    });
  final index = sorted.indexWhere(
    (w) => w.id == sessionId && w.exercise == exercise,
  );
  if (index < 0) return {};
  final completed = sorted[index];
  final throughCurrent = sorted.take(index + 1).toList();
  final days = throughCurrent.map((w) => w.day).toSet().toList()..sort();
  final firstDay = sorted.first.day;
  // UTC calendar arithmetic avoids DST changing a calendar-day difference.
  final daysSinceFirst =
      DateTime.utc(completed.day.year, completed.day.month, completed.day.day)
          .difference(DateTime.utc(firstDay.year, firstDay.month, firstDay.day))
          .inDays;
  final values = <String, Object>{
    'app_workout_count': index + 1,
    'workout_day_count': days.length,
    'days_since_first_completion': daysSinceFirst,
    'is_next_calendar_day': daysSinceFirst == 1 ? 1 : 0,
    'is_first_workout': index == 0 ? 1 : 0,
  };
  final firstOnDay = !sorted.take(index).any((w) => w.day == completed.day);
  return {
    if (index == 0) 'mf2_first_workout_completed': values,
    if (index == 1) 'mf2_app_second_workout_completed': values,
    if (days.length == 2 && firstOnDay)
      'mf2_second_workout_day_completed': values,
    if (firstOnDay) 'mf2_workout_day_completed': values,
  };
}

Future<void> recordWorkoutRetention(
  Ref ref, {
  required String sessionId,
  required String exercise,
  required Map<String, Object> context,
}) async {
  // Capture services before awaiting; the active attempt can change meanwhile.
  final analytics = ref.read(analyticsServiceProvider);
  final preferences = ref.read(preferencesServiceProvider);
  final groups = await Future.wait<List<CompletedWorkout>>([
    ref
        .read(workoutRepositoryProvider)
        .loadSessions()
        .then(
          (sessions) => [
            for (final details in sessions)
              if (details.session.completed &&
                  !details.session.interrupted &&
                  details.session.totalReps > 0)
                CompletedWorkout(
                  details.session.id,
                  'squat',
                  details.session.endedAt ?? details.session.startedAt,
                ),
          ],
        ),
    ref
        .read(pushup.workoutRepositoryProvider)
        .loadSessions()
        .then(
          (sessions) => [
            for (final details in sessions)
              if (details.session.completed &&
                  !details.session.interrupted &&
                  details.session.totalReps > 0)
                CompletedWorkout(
                  details.session.id,
                  'pushup',
                  details.session.endedAt ?? details.session.startedAt,
                ),
          ],
        ),
    ref
        .read(plank.workoutRepositoryProvider)
        .loadSessions()
        .then(
          (sessions) => [
            for (final details in sessions)
              if (details.session.completed &&
                  !details.session.interrupted &&
                  details.session.totalReps > 0)
                CompletedWorkout(
                  details.session.id,
                  'plank',
                  details.session.endedAt ?? details.session.startedAt,
                ),
          ],
        ),
  ]);
  final all = groups.expand((group) => group).toList();
  final events = retentionMilestones(all, sessionId, exercise);
  final current = all
      .where((w) => w.id == sessionId && w.exercise == exercise)
      .firstOrNull;
  if (current == null) return;
  for (final event in events.entries) {
    final key = event.key == 'mf2_workout_day_completed'
        ? '${event.key}:${current.day.toIso8601String()}'
        : event.key;
    if (await preferences.claimRetentionEvent(key)) {
      analytics.retentionEvent(event.key, {...context, ...event.value});
    }
  }
}
