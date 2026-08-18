import 'dart:io';

import 'package:motionfit_squat/core/database/app_database.dart';
import 'package:motionfit_squat/features/records/domain/workout_session_details.dart';
import 'package:motionfit_squat/features/records/domain/workout_statistics.dart';
import 'package:motionfit_squat/features/settings/domain/reminder_schedule.dart';
import 'package:motionfit_squat/features/squat/domain/models/rep_record.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_enums.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_plan.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_journal.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_session.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_set.dart';
import 'package:motionfit_squat/features/squat/domain/services/workout_repository.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class SqliteWorkoutRepository implements WorkoutRepository {
  const SqliteWorkoutRepository(this.appDatabase, {this.onError});

  final AppDatabase appDatabase;
  final void Function(Object error, StackTrace stackTrace, String reason)?
  onError;

  static String _journalKey(String sessionId) => 'workout_journal:$sessionId';

  @override
  Future<void> savePlan(WorkoutPlan plan) async {
    final database = await appDatabase.database;
    await database.insert(
      'workout_plans',
      plan.normalized().toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<WorkoutPlan?> loadLatestPlan() async {
    final database = await appDatabase.database;
    final rows = await database.query(
      'workout_plans',
      orderBy: 'updated_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    try {
      return WorkoutPlan.fromMap(rows.first);
    } on Object catch (error, stackTrace) {
      onError?.call(error, stackTrace, 'workout_plan_parse');
      return null;
    }
  }

  @override
  Future<void> createSession(
    WorkoutSession session,
    WorkoutSet firstSet,
  ) async {
    final database = await appDatabase.database;
    await database.transaction((transaction) async {
      await transaction.insert(
        'workout_sessions',
        session.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      await transaction.insert(
        'workout_sets',
        firstSet.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    });
  }

  @override
  Future<void> saveProgress({
    required RepRecord rep,
    required WorkoutSet set,
    required WorkoutSession session,
  }) async {
    final database = await appDatabase.database;
    await database.transaction((transaction) async {
      await transaction.insert(
        'rep_records',
        rep.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      final changes = await transaction.rawQuery('SELECT changes() AS count');
      if ((changes.first['count']! as int) == 0) return;
      await transaction.update(
        'workout_sets',
        set.toMap(),
        where: 'id = ?',
        whereArgs: [set.id],
      );
      await transaction.update(
        'workout_sessions',
        session.toMap(),
        where: 'id = ?',
        whereArgs: [session.id],
      );
    });
  }

  @override
  Future<void> saveSetAndSession(WorkoutSet set, WorkoutSession session) async {
    final database = await appDatabase.database;
    await database.transaction((transaction) async {
      await transaction.insert(
        'workout_sets',
        set.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      await transaction.update(
        'workout_sets',
        set.toMap(),
        where: 'id = ?',
        whereArgs: [set.id],
      );
      await transaction.update(
        'workout_sessions',
        session.toMap(),
        where: 'id = ?',
        whereArgs: [session.id],
      );
    });
  }

  @override
  Future<void> advanceSet({
    required WorkoutSet completedSet,
    required WorkoutSet nextSet,
    required WorkoutSession session,
  }) async {
    final database = await appDatabase.database;
    await database.transaction((transaction) async {
      await transaction.update(
        'workout_sets',
        completedSet.toMap(),
        where: 'id = ?',
        whereArgs: [completedSet.id],
      );
      await transaction.insert(
        'workout_sets',
        nextSet.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      await transaction.update(
        'workout_sessions',
        session.toMap(),
        where: 'id = ?',
        whereArgs: [session.id],
      );
    });
  }

  @override
  Future<void> finishSession(WorkoutSession session, WorkoutSet currentSet) =>
      saveSetAndSession(currentSet, session);

  @override
  Future<void> saveWorkoutVideo({
    required String sessionId,
    required String path,
    required int durationMilliseconds,
  }) async {
    final database = await appDatabase.database;
    await database.update(
      'workout_sessions',
      {
        'video_path': path,
        'video_duration_milliseconds': durationMilliseconds.clamp(0, 86400000),
      },
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  @override
  Future<bool> deleteWorkoutVideo(String sessionId) async {
    final database = await appDatabase.database;
    final rows = await database.query(
      'workout_sessions',
      columns: ['video_path'],
      where: 'id = ?',
      whereArgs: [sessionId],
      limit: 1,
    );
    final path = rows.isEmpty ? null : rows.first['video_path'] as String?;
    var deleted = false;
    if (path != null && _isManagedWorkoutVideo(path, sessionId)) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        deleted = true;
      }
    }
    await database.update(
      'workout_sessions',
      {'video_path': null, 'video_duration_milliseconds': null},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
    return deleted;
  }

  bool _isManagedWorkoutVideo(String path, String sessionId) {
    final normalized = p.normalize(path);
    final directory = p.basename(p.dirname(normalized));
    final safeSessionId = sessionId.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    final filename = p.basename(normalized);
    return directory == 'motionfit_workout_videos' &&
        (filename == 'workout_$safeSessionId.mp4' ||
            filename == 'workout_$safeSessionId.mov');
  }

  @override
  Future<void> discardSession(String sessionId) async {
    final database = await appDatabase.database;
    await database.transaction((transaction) async {
      await transaction.delete(
        'app_state',
        where: 'key = ?',
        whereArgs: [_journalKey(sessionId)],
      );
      await transaction.delete(
        'workout_sessions',
        where: 'id = ?',
        whereArgs: [sessionId],
      );
    });
  }

  @override
  Future<WorkoutSessionDetails?> loadSession(String id) async {
    final database = await appDatabase.database;
    final sessionRows = await database.query(
      'workout_sessions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (sessionRows.isEmpty) return null;
    final setRows = await database.query(
      'workout_sets',
      where: 'session_id = ?',
      whereArgs: [id],
      orderBy: 'set_index ASC',
    );
    final repRows = await database.query(
      'rep_records',
      where: 'session_id = ?',
      whereArgs: [id],
      orderBy: 'completed_at ASC',
    );
    try {
      return WorkoutSessionDetails(
        session: WorkoutSession.fromMap(sessionRows.first),
        sets: setRows.map(WorkoutSet.fromMap).toList(growable: false),
        reps: repRows.map(RepRecord.fromMap).toList(growable: false),
      );
    } on Object catch (error, stackTrace) {
      onError?.call(error, stackTrace, 'workout_session_parse');
      return null;
    }
  }

  @override
  Future<List<WorkoutSessionDetails>> loadSessions({
    DateTime? from,
    DateTime? to,
  }) async {
    final database = await appDatabase.database;
    final clauses = <String>['total_reps > 0'];
    final arguments = <Object?>[];
    if (from != null) {
      clauses.add('started_at >= ?');
      arguments.add(from.millisecondsSinceEpoch);
    }
    if (to != null) {
      clauses.add('started_at < ?');
      arguments.add(to.millisecondsSinceEpoch);
    }
    final rows = await database.query(
      'workout_sessions',
      where: clauses.join(' AND '),
      whereArgs: arguments.isEmpty ? null : arguments,
      orderBy: 'started_at DESC',
    );
    final details = <WorkoutSessionDetails>[];
    for (final row in rows) {
      final id = row['id'];
      if (id is! String) {
        onError?.call(
          const FormatException('Workout session ID is missing'),
          StackTrace.current,
          'workout_session_id_parse',
        );
        continue;
      }
      final value = await loadSession(id);
      if (value != null) details.add(value);
    }
    return details;
  }

  @override
  Future<WorkoutStatistics> loadStatistics({
    DateTime? from,
    DateTime? to,
  }) async {
    final sessions = await loadSessions(from: from, to: to);
    final byDate = <DateTime, List<WorkoutSessionDetails>>{};
    final issues = <FormIssue, int>{};
    for (final details in sessions) {
      final startedAt = details.session.startedAt.toLocal();
      final date = DateTime(startedAt.year, startedAt.month, startedAt.day);
      byDate.putIfAbsent(date, () => []).add(details);
      for (final rep in details.reps) {
        for (final issue in rep.detectedIssues) {
          issues[issue] = (issues[issue] ?? 0) + 1;
        }
      }
    }
    final totalReps = sessions.fold<int>(
      0,
      (sum, details) => sum + details.session.totalReps,
    );
    final totalActive = sessions.fold<int>(
      0,
      (sum, details) => sum + details.session.activeDurationSeconds,
    );
    final totalSets = sessions.fold<int>(
      0,
      (sum, details) => sum + details.session.completedSetCount,
    );
    final daily =
        byDate.entries
            .map(
              (entry) => DailyWorkoutTotal(
                date: entry.key,
                totalReps: entry.value.fold<int>(
                  0,
                  (sum, details) => sum + details.session.totalReps,
                ),
                sessionCount: entry.value.length,
                activeDurationSeconds: entry.value.fold<int>(
                  0,
                  (sum, details) => sum + details.session.activeDurationSeconds,
                ),
              ),
            )
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));
    return WorkoutStatistics(
      totalReps: totalReps,
      workoutDays: byDate.length,
      totalActiveSeconds: totalActive,
      averageSetCount: sessions.isEmpty ? 0 : totalSets / sessions.length,
      averageReps: sessions.isEmpty ? 0 : totalReps / sessions.length,
      dailyTotals: daily,
      frequentIssues: issues,
    );
  }

  @override
  Future<WorkoutSessionDetails?> loadRecoverableSession() async {
    final database = await appDatabase.database;
    final rows = await database.query(
      'workout_sessions',
      where: 'completed = 0 AND interrupted = 0 AND total_reps > 0',
      orderBy: 'started_at DESC',
      limit: 1,
    );
    return rows.isEmpty ? null : loadSession(rows.first['id']! as String);
  }

  @override
  Future<void> markInterrupted(String sessionId, DateTime endedAt) async {
    final database = await appDatabase.database;
    final journal = await loadWorkoutJournal(sessionId);
    await database.transaction((transaction) async {
      final rows = await transaction.query(
        'workout_sessions',
        columns: [
          'started_at',
          'active_duration_seconds',
          'rest_duration_seconds',
          'total_duration_seconds',
        ],
        where: 'id = ? AND completed = 0 AND interrupted = 0',
        whereArgs: [sessionId],
        limit: 1,
      );
      if (rows.isEmpty) return;
      final row = rows.first;
      final startedAt = DateTime.fromMillisecondsSinceEpoch(
        row['started_at']! as int,
      );
      var activeSeconds = row['active_duration_seconds']! as int;
      var restSeconds = row['rest_duration_seconds']! as int;
      var totalSeconds = row['total_duration_seconds']! as int;
      if (journal != null) {
        if (journal.activeDurationSeconds > activeSeconds) {
          activeSeconds = journal.activeDurationSeconds;
        }
        if (journal.restDurationSeconds > restSeconds) {
          restSeconds = journal.restDurationSeconds;
        }
        if (journal.status == WorkoutSessionStatus.resting &&
            journal.restStartedAt != null) {
          final restEnd =
              journal.restEndsAt == null ||
                  endedAt.isBefore(journal.restEndsAt!)
              ? endedAt
              : journal.restEndsAt!;
          final currentRest = restEnd.difference(journal.restStartedAt!);
          if (!currentRest.isNegative) {
            restSeconds += currentRest.inSeconds;
          }
          final uncheckpointed = restEnd.difference(journal.updatedAt);
          if (!uncheckpointed.isNegative) {
            final recoveredTotal =
                journal.totalDurationSeconds + uncheckpointed.inSeconds;
            if (recoveredTotal > totalSeconds) totalSeconds = recoveredTotal;
          }
        } else if (journal.totalDurationSeconds > totalSeconds) {
          totalSeconds = journal.totalDurationSeconds;
        }
        final measuredSeconds = activeSeconds + restSeconds;
        if (measuredSeconds > totalSeconds) totalSeconds = measuredSeconds;
      } else if (totalSeconds == 0) {
        totalSeconds = endedAt.difference(startedAt).inSeconds;
      }
      totalSeconds = totalSeconds.clamp(0, 864000).toInt();
      await transaction.update(
        'workout_sessions',
        {
          'ended_at': endedAt.millisecondsSinceEpoch,
          'interrupted': 1,
          'active_duration_seconds': activeSeconds,
          'rest_duration_seconds': restSeconds,
          'total_duration_seconds': totalSeconds,
        },
        where: 'id = ? AND completed = 0 AND interrupted = 0',
        whereArgs: [sessionId],
      );
      await transaction.update(
        'workout_sets',
        {
          'ended_at': endedAt.millisecondsSinceEpoch,
          if (journal != null)
            'active_duration_seconds': journal.currentSetActiveDurationSeconds,
        },
        where: 'session_id = ? AND ended_at IS NULL',
        whereArgs: [sessionId],
      );
      if (journal != null &&
          journal.status == WorkoutSessionStatus.resting &&
          journal.restStartedAt != null) {
        final restEnd =
            journal.restEndsAt == null || endedAt.isBefore(journal.restEndsAt!)
            ? endedAt
            : journal.restEndsAt!;
        final currentRest = restEnd.difference(journal.restStartedAt!);
        await transaction.update(
          'workout_sets',
          {
            'rest_duration_after_seconds': currentRest.inSeconds
                .clamp(0, 3600)
                .toInt(),
          },
          where: 'id = ?',
          whereArgs: [journal.currentSetId],
        );
      }
    });
    await clearWorkoutJournal(sessionId);
  }

  @override
  Future<void> saveWorkoutJournal(WorkoutJournal journal) async {
    final database = await appDatabase.database;
    await database.insert('app_state', {
      'key': _journalKey(journal.sessionId),
      'value': journal.encode(),
      'updated_at': journal.updatedAt.millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<WorkoutJournal?> loadWorkoutJournal(String sessionId) async {
    final database = await appDatabase.database;
    final rows = await database.query(
      'app_state',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [_journalKey(sessionId)],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    try {
      return WorkoutJournal.decode(rows.first['value']! as String);
    } on Object {
      await clearWorkoutJournal(sessionId);
      return null;
    }
  }

  @override
  Future<void> clearWorkoutJournal(String sessionId) async {
    final database = await appDatabase.database;
    await database.delete(
      'app_state',
      where: 'key = ?',
      whereArgs: [_journalKey(sessionId)],
    );
  }

  @override
  Future<List<ReminderSchedule>> loadReminders() async {
    final database = await appDatabase.database;
    final rows = await database.query(
      'reminder_schedules',
      orderBy: 'weekday ASC',
    );
    if (rows.length == 7) {
      return rows.map(ReminderSchedule.fromMap).toList(growable: false);
    }
    final defaults = ReminderSchedule.defaults();
    final existing = {
      for (final row in rows)
        row['weekday'] as int: ReminderSchedule.fromMap(row),
    };
    return defaults
        .map((value) => existing[value.weekday] ?? value)
        .toList(growable: false);
  }

  @override
  Future<void> saveReminder(ReminderSchedule schedule) async {
    final database = await appDatabase.database;
    await database.insert(
      'reminder_schedules',
      schedule.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
