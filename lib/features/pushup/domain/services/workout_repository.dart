import 'package:motionfit_squat/features/pushup/records/domain/workout_session_details.dart';
import 'package:motionfit_squat/features/pushup/records/domain/workout_statistics.dart';
import 'package:motionfit_squat/features/settings/domain/reminder_schedule.dart';
import 'package:motionfit_squat/features/pushup/domain/models/rep_record.dart';
import 'package:motionfit_squat/features/pushup/domain/models/workout_plan.dart';
import 'package:motionfit_squat/features/pushup/domain/models/workout_journal.dart';
import 'package:motionfit_squat/features/pushup/domain/models/workout_session.dart';
import 'package:motionfit_squat/features/pushup/domain/models/workout_set.dart';

abstract interface class WorkoutRepository {
  Future<void> savePlan(WorkoutPlan plan);
  Future<WorkoutPlan?> loadLatestPlan();
  Future<void> createSession(WorkoutSession session, WorkoutSet firstSet);
  Future<void> saveProgress({
    required RepRecord rep,
    required WorkoutSet set,
    required WorkoutSession session,
  });
  Future<void> saveSetAndSession(WorkoutSet set, WorkoutSession session);
  Future<void> advanceSet({
    required WorkoutSet completedSet,
    required WorkoutSet nextSet,
    required WorkoutSession session,
  });
  Future<void> finishSession(WorkoutSession session, WorkoutSet currentSet);
  Future<void> saveWorkoutVideo({
    required String sessionId,
    required String path,
    required int durationMilliseconds,
  });
  Future<bool> deleteWorkoutVideo(String sessionId);
  Future<void> discardSession(String sessionId);
  Future<WorkoutSessionDetails?> loadSession(String id);
  Future<List<WorkoutSessionDetails>> loadSessions({
    DateTime? from,
    DateTime? to,
  });
  Future<WorkoutStatistics> loadStatistics({DateTime? from, DateTime? to});
  Future<WorkoutSessionDetails?> loadRecoverableSession();
  Future<void> markInterrupted(String sessionId, DateTime endedAt);
  Future<void> saveWorkoutJournal(WorkoutJournal journal);
  Future<WorkoutJournal?> loadWorkoutJournal(String sessionId);
  Future<void> clearWorkoutJournal(String sessionId);
  Future<List<ReminderSchedule>> loadReminders();
  Future<void> saveReminder(ReminderSchedule schedule);
}
