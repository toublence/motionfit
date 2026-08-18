import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:motionfit_squat/core/database/app_database.dart';
import 'package:motionfit_squat/features/squat/data/sqlite_workout_repository.dart';
import 'package:motionfit_squat/features/squat/domain/models/rep_record.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_enums.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_plan.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_session.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_set.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  test('camera failure session is hidden and can be discarded', () async {
    final directory = await Directory.systemTemp.createTemp(
      'motionfit-discard-session-test-',
    );
    final database = AppDatabase(
      factory: databaseFactoryFfi,
      path: '${directory.path}/motionfit.db',
    );
    final repository = SqliteWorkoutRepository(database);
    final session = _session(
      id: 'camera-failure',
      startedAt: DateTime.utc(2026, 8, 4),
      totalReps: 0,
      completedSets: 0,
      activeSeconds: 0,
      restSeconds: 0,
      totalSeconds: 0,
    );

    try {
      await repository.createSession(session, _setFor(session));
      expect(await repository.loadSessions(), isEmpty);
      expect(await repository.loadRecoverableSession(), isNull);

      await repository.discardSession(session.id);

      expect(await repository.loadSession(session.id), isNull);
    } finally {
      await database.close();
      await directory.delete(recursive: true);
    }
  });

  test('corrupt legacy workout plan is ignored and reported', () async {
    final directory = await Directory.systemTemp.createTemp(
      'motionfit-plan-parse-test-',
    );
    final database = AppDatabase(
      factory: databaseFactoryFfi,
      path: '${directory.path}/motionfit.db',
    );
    final reasons = <String>[];
    final repository = SqliteWorkoutRepository(
      database,
      onError: (_, _, reason) => reasons.add(reason),
    );

    try {
      final raw = await database.database;
      final now = DateTime.now().millisecondsSinceEpoch;
      await raw.insert('workout_plans', {
        'id': 'legacy-corrupt',
        'set_count': 3,
        'target_reps_per_set': 10,
        'rest_duration_seconds': 60,
        'created_at': 'not-an-integer',
        'updated_at': now,
      });

      expect(await repository.loadLatestPlan(), isNull);
      expect(reasons, contains('workout_plan_parse'));
    } finally {
      await database.close();
      await directory.delete(recursive: true);
    }
  });

  test('v2 migration restores only the latest unfinished workout', () async {
    final directory = await Directory.systemTemp.createTemp(
      'motionfit-db-migration-test-',
    );
    final databasePath = '${directory.path}/motionfit.db';
    AppDatabase? appDatabase;

    try {
      final legacy = await databaseFactoryFfi.openDatabase(
        databasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (database, _) async {
            await database.execute('''
              CREATE TABLE workout_sessions (
                id TEXT PRIMARY KEY,
                started_at INTEGER NOT NULL,
                ended_at INTEGER,
                planned_set_count INTEGER NOT NULL,
                planned_reps_per_set INTEGER NOT NULL,
                total_reps INTEGER NOT NULL,
                completed INTEGER NOT NULL,
                interrupted INTEGER NOT NULL
              )
            ''');
            await database.execute('''
              CREATE TABLE workout_sets (
                id TEXT PRIMARY KEY,
                session_id TEXT NOT NULL,
                set_index INTEGER NOT NULL,
                ended_at INTEGER
              )
            ''');
          },
        ),
      );
      final olderStartedAt = DateTime.utc(2026, 7, 23, 9);
      final latestStartedAt = DateTime.utc(2026, 7, 23, 10);
      for (final session in [
        ('older', olderStartedAt, 4),
        ('latest', latestStartedAt, 20),
      ]) {
        await legacy.insert('workout_sessions', {
          'id': session.$1,
          'started_at': session.$2.millisecondsSinceEpoch,
          'ended_at': session.$2
              .add(const Duration(minutes: 5))
              .millisecondsSinceEpoch,
          'planned_set_count': 3,
          'planned_reps_per_set': 10,
          'total_reps': session.$3,
          'completed': 0,
          'interrupted': 1,
        });
        await legacy.insert('workout_sets', {
          'id': '${session.$1}-set',
          'session_id': session.$1,
          'set_index': 1,
          'ended_at': session.$2
              .add(const Duration(minutes: 5))
              .millisecondsSinceEpoch,
        });
      }
      await legacy.close();

      appDatabase = AppDatabase(
        factory: databaseFactoryFfi,
        path: databasePath,
      );
      final upgraded = await appDatabase.database;
      final sessions = await upgraded.query(
        'workout_sessions',
        orderBy: 'started_at ASC',
      );
      final sets = await upgraded.query(
        'workout_sets',
        orderBy: 'session_id ASC',
      );
      final sessionsById = {
        for (final session in sessions) session['id'] as String: session,
      };
      final setsBySessionId = {
        for (final set in sets) set['session_id'] as String: set,
      };

      expect(sessionsById['older']!['interrupted'], 1);
      expect(sessionsById['older']!['ended_at'], isNotNull);
      expect(sessionsById['latest']!['interrupted'], 0);
      expect(sessionsById['latest']!['ended_at'], isNull);
      expect(setsBySessionId['older']!['ended_at'], isNotNull);
      expect(setsBySessionId['latest']!['ended_at'], isNull);
    } finally {
      await appDatabase?.close();
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    }
  });

  test('workout plan and progress survive a database restart', () async {
    final directory = await Directory.systemTemp.createTemp(
      'motionfit-db-test-',
    );
    final databasePath = '${directory.path}/motionfit.db';
    AppDatabase? database;

    try {
      database = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
      var repository = SqliteWorkoutRepository(database);
      final startedAt = DateTime.utc(2026, 7, 21, 9);
      final plan = WorkoutPlan(
        id: 'plan-1',
        setCount: 3,
        targetRepsPerSet: 10,
        restDurationSeconds: 60,
        createdAt: startedAt,
        updatedAt: startedAt,
      );
      final initialSession = WorkoutSession(
        id: 'session-1',
        startedAt: startedAt,
        plannedSetCount: 3,
        plannedRepsPerSet: 10,
        plannedRestSeconds: 60,
        completedSetCount: 0,
        totalReps: 0,
        activeDurationSeconds: 0,
        restDurationSeconds: 0,
        totalDurationSeconds: 0,
        averageRepDurationMilliseconds: 0,
        completed: false,
        interrupted: false,
        createdAt: startedAt,
      );
      final initialSet = WorkoutSet(
        id: 'set-1',
        sessionId: initialSession.id,
        setIndex: 1,
        startedAt: startedAt,
        targetReps: 10,
        completedReps: 0,
        activeDurationSeconds: 0,
        restDurationAfterSeconds: 0,
      );
      final rep = RepRecord(
        id: 'rep-1',
        sessionId: initialSession.id,
        setId: initialSet.id,
        repIndex: 1,
        startedAt: startedAt.add(const Duration(seconds: 2)),
        bottomAt: startedAt.add(const Duration(seconds: 3)),
        completedAt: startedAt.add(const Duration(seconds: 4)),
        durationMilliseconds: 2000,
        depthScore: 72,
        controlScore: 91,
        balanceScore: null,
        overallFormScore: 81.5,
        detectedIssues: const [FormIssue.insufficientDepth],
        cameraAngle: CameraAngle.side,
        confidence: 0.94,
      );
      final savedSet = initialSet.copyWith(
        completedReps: 1,
        activeDurationSeconds: 4,
      );
      final savedSession = initialSession.copyWith(
        totalReps: 1,
        activeDurationSeconds: 4,
        totalDurationSeconds: 4,
        averageRepDurationMilliseconds: 2000,
      );

      await repository.savePlan(plan);
      await repository.createSession(initialSession, initialSet);
      await repository.saveProgress(
        rep: rep,
        set: savedSet,
        session: savedSession,
      );
      await database.close();

      database = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
      repository = SqliteWorkoutRepository(database);

      final restoredPlan = await repository.loadLatestPlan();
      final restored = await repository.loadSession(initialSession.id);
      final recoverable = await repository.loadRecoverableSession();

      expect(restoredPlan?.id, plan.id);
      expect(restoredPlan?.plannedTotalReps, 30);
      expect(restored, isNotNull);
      expect(restored!.session.totalReps, 1);
      expect(restored.sets.single.completedReps, 1);
      expect(restored.reps.single.detectedIssues, const [
        FormIssue.insufficientDepth,
      ]);
      expect(restored.reps.single.balanceScore, isNull);
      expect(recoverable?.session.id, initialSession.id);

      final rawDatabase = await database.database;
      final schemaRows = await rawDatabase.query(
        'sqlite_master',
        columns: ['sql'],
        where: "type = 'table' AND name NOT LIKE 'sqlite_%'",
      );
      final schema = schemaRows
          .map((row) => row['sql'] as String? ?? '')
          .join('\n')
          .toLowerCase();
      expect(schema, isNot(contains(' blob')));
      expect(schema, isNot(contains('image')));
      expect(schema, isNot(contains('pixel')));
      expect(schema, isNot(contains('landmark')));

      await repository.markInterrupted(
        initialSession.id,
        startedAt.add(const Duration(minutes: 1)),
      );
      expect(await repository.loadRecoverableSession(), isNull);
      expect(
        (await repository.loadSession(initialSession.id))!.session.interrupted,
        isTrue,
      );
    } finally {
      await database?.close();
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    }
  });

  test(
    'multiple sessions aggregate by day and preserve interrupted durations',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'motionfit-statistics-test-',
      );
      final databasePath = '${directory.path}/motionfit.db';
      AppDatabase? database;

      try {
        database = AppDatabase(factory: databaseFactoryFfi, path: databasePath);
        final repository = SqliteWorkoutRepository(database);
        final firstMorning = DateTime(2026, 7, 20, 9);
        final firstEvening = DateTime(2026, 7, 20, 18);
        final secondMorning = DateTime(2026, 7, 21, 8);
        final sessions = [
          _session(
            id: 'day-1-complete',
            startedAt: firstMorning,
            totalReps: 10,
            completedSets: 2,
            activeSeconds: 120,
            restSeconds: 60,
            totalSeconds: 180,
            completed: true,
          ),
          _session(
            id: 'day-1-interrupted',
            startedAt: firstEvening,
            totalReps: 4,
            completedSets: 1,
            activeSeconds: 50,
            restSeconds: 10,
            totalSeconds: 0,
          ),
          _session(
            id: 'day-2-complete',
            startedAt: secondMorning,
            totalReps: 8,
            completedSets: 1,
            activeSeconds: 90,
            restSeconds: 30,
            totalSeconds: 120,
            completed: true,
          ),
        ];
        for (final session in sessions) {
          await repository.createSession(session, _setFor(session));
        }
        await repository.markInterrupted(
          'day-1-interrupted',
          firstEvening.add(const Duration(seconds: 75)),
        );

        final statistics = await repository.loadStatistics();
        final firstDay = statistics.dailyTotals.singleWhere(
          (total) =>
              total.date.year == 2026 &&
              total.date.month == 7 &&
              total.date.day == 20,
        );
        final secondDay = statistics.dailyTotals.singleWhere(
          (total) =>
              total.date.year == 2026 &&
              total.date.month == 7 &&
              total.date.day == 21,
        );
        final interrupted = (await repository.loadSession(
          'day-1-interrupted',
        ))!.session;
        final firstDaySessions = await repository.loadSessions(
          from: DateTime(2026, 7, 20),
          to: DateTime(2026, 7, 21),
        );

        expect(statistics.totalReps, 22);
        expect(statistics.workoutDays, 2);
        expect(statistics.totalActiveSeconds, 260);
        expect(statistics.averageSetCount, closeTo(4 / 3, 0.0001));
        expect(statistics.averageReps, closeTo(22 / 3, 0.0001));
        expect(firstDay.sessionCount, 2);
        expect(firstDay.totalReps, 14);
        expect(firstDay.activeDurationSeconds, 170);
        expect(secondDay.sessionCount, 1);
        expect(secondDay.totalReps, 8);
        expect(secondDay.activeDurationSeconds, 90);
        expect(firstDaySessions, hasLength(2));
        expect(interrupted.interrupted, isTrue);
        expect(interrupted.completed, isFalse);
        expect(interrupted.activeDurationSeconds, 50);
        expect(interrupted.restDurationSeconds, 10);
        expect(interrupted.totalDurationSeconds, 75);
        expect(
          interrupted.endedAt,
          firstEvening.add(const Duration(seconds: 75)),
        );
      } finally {
        await database?.close();
        if (await directory.exists()) {
          await directory.delete(recursive: true);
        }
      }
    },
  );
}

WorkoutSession _session({
  required String id,
  required DateTime startedAt,
  required int totalReps,
  required int completedSets,
  required int activeSeconds,
  required int restSeconds,
  required int totalSeconds,
  bool completed = false,
}) => WorkoutSession(
  id: id,
  startedAt: startedAt,
  endedAt: completed ? startedAt.add(Duration(seconds: totalSeconds)) : null,
  plannedSetCount: 3,
  plannedRepsPerSet: 10,
  plannedRestSeconds: 60,
  completedSetCount: completedSets,
  totalReps: totalReps,
  activeDurationSeconds: activeSeconds,
  restDurationSeconds: restSeconds,
  totalDurationSeconds: totalSeconds,
  averageRepDurationMilliseconds: totalReps == 0
      ? 0
      : (activeSeconds * 1000 / totalReps).round(),
  completed: completed,
  interrupted: false,
  createdAt: startedAt,
);

WorkoutSet _setFor(WorkoutSession session) => WorkoutSet(
  id: '${session.id}-set-1',
  sessionId: session.id,
  setIndex: 1,
  startedAt: session.startedAt,
  endedAt: session.endedAt,
  targetReps: session.plannedRepsPerSet,
  completedReps: session.totalReps,
  activeDurationSeconds: session.activeDurationSeconds,
  restDurationAfterSeconds: session.restDurationSeconds,
);
