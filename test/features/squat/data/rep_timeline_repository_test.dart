import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:motionfit_squat/core/database/app_database.dart';
import 'package:motionfit_squat/features/squat/data/sqlite_workout_repository.dart';
import 'package:motionfit_squat/features/squat/domain/models/rep_record.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_enums.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_session.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_set.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  test('rep timeline and workout video metadata survive a restart', () async {
    final harness = await _RepositoryHarness.open('rep-timeline-roundtrip-');
    try {
      final startedAt = DateTime.utc(2026, 8, 11, 9);
      final session = _session(
        id: 'roundtrip',
        startedAt: startedAt,
        analyticsSessionId: 'analytics-roundtrip',
      );
      final set = _setFor(session);
      final videoPath = p.join(
        harness.directory.path,
        'motionfit_workout_videos',
        'workout_roundtrip.mp4',
      );
      final rep = _rep(
        session: session,
        set: set,
        sequenceNumber: 7,
        videoStartMilliseconds: 1200,
        videoBottomMilliseconds: 1900,
        videoEndMilliseconds: 2600,
        primaryIssue: FormIssue.excessiveTorsoLean,
        detectedIssues: const [FormIssue.excessiveTorsoLean],
        depthQuality: RepQuality.good,
        upperBodyQuality: RepQuality.needsImprovement,
        kneeAlignmentQuality: RepQuality.good,
      );

      await harness.repository.createSession(session, set);
      await harness.repository.saveProgress(
        rep: rep,
        set: set.copyWith(completedReps: 1),
        session: session.copyWith(totalReps: 1),
      );
      await harness.repository.saveWorkoutVideo(
        sessionId: session.id,
        path: videoPath,
        durationMilliseconds: 120000,
      );
      await harness.database.close();

      harness.reopen();
      final restored = await harness.repository.loadSession(session.id);

      expect(restored, isNotNull);
      expect(restored!.session.analyticsSessionId, 'analytics-roundtrip');
      expect(restored.session.videoPath, videoPath);
      expect(restored.session.videoDurationMilliseconds, 120000);
      expect(restored.reps, hasLength(1));

      final restoredRep = restored.reps.single;
      expect(restoredRep.sequenceNumber, 7);
      expect(restoredRep.videoStartMilliseconds, 1200);
      expect(restoredRep.videoBottomMilliseconds, 1900);
      expect(restoredRep.videoEndMilliseconds, 2600);
      expect(restoredRep.primaryIssue, FormIssue.excessiveTorsoLean);
      expect(restoredRep.depthQuality, RepQuality.good);
      expect(restoredRep.upperBodyQuality, RepQuality.needsImprovement);
      expect(restoredRep.kneeAlignmentQuality, RepQuality.good);

      final analysis = restored.repAnalyses.single;
      expect(analysis.repNumber, 7);
      expect(analysis.setNumber, 1);
      expect(analysis.startTime, const Duration(milliseconds: 1200));
      expect(analysis.bottomTime, const Duration(milliseconds: 1900));
      expect(analysis.endTime, const Duration(milliseconds: 2600));
      expect(analysis.primaryIssue, FormIssue.excessiveTorsoLean);
      expect(analysis.result, RepAnalysisResult.needsImprovement);
    } finally {
      await harness.dispose();
    }
  });

  test('deleting a managed workout video preserves rep analysis', () async {
    final harness = await _RepositoryHarness.open('rep-video-delete-');
    try {
      final startedAt = DateTime.utc(2026, 8, 11, 10);
      final session = _session(id: 'delete_video', startedAt: startedAt);
      final set = _setFor(session);
      final managedDirectory = Directory(
        p.join(harness.directory.path, 'motionfit_workout_videos'),
      );
      await managedDirectory.create(recursive: true);
      final video = File(
        p.join(managedDirectory.path, 'workout_delete_video.mp4'),
      );
      await video.writeAsBytes(const [0, 1, 2, 3], flush: true);

      await harness.repository.createSession(session, set);
      await harness.repository.saveProgress(
        rep: _rep(
          session: session,
          set: set,
          sequenceNumber: 1,
          videoStartMilliseconds: 400,
          videoBottomMilliseconds: 1000,
          videoEndMilliseconds: 1700,
          primaryIssue: FormIssue.insufficientDepth,
          detectedIssues: const [FormIssue.insufficientDepth],
          depthQuality: RepQuality.needsImprovement,
        ),
        set: set.copyWith(completedReps: 1),
        session: session.copyWith(totalReps: 1),
      );
      await harness.repository.saveWorkoutVideo(
        sessionId: session.id,
        path: video.path,
        durationMilliseconds: 8000,
      );

      expect(await harness.repository.deleteWorkoutVideo(session.id), isTrue);
      expect(await video.exists(), isFalse);

      final restored = await harness.repository.loadSession(session.id);
      expect(restored, isNotNull);
      expect(restored!.session.videoPath, isNull);
      expect(restored.session.videoDurationMilliseconds, isNull);
      expect(restored.reps, hasLength(1));
      expect(
        restored.reps.single.primaryIssue,
        FormIssue.insufficientDepth,
      );
      expect(restored.repAnalyses, hasLength(1));
    } finally {
      await harness.dispose();
    }
  });

  test('video-less legacy-style rep remains loadable as text analysis', () async {
    final harness = await _RepositoryHarness.open('rep-timeline-legacy-');
    try {
      final startedAt = DateTime.utc(2026, 8, 11, 11);
      final session = _session(id: 'legacy', startedAt: startedAt);
      final set = _setFor(session);
      await harness.repository.createSession(session, set);

      final database = await harness.database.database;
      await database.insert('rep_records', {
        'id': 'legacy-rep',
        'session_id': session.id,
        'set_id': set.id,
        'rep_index': 1,
        'started_at': startedAt
            .add(const Duration(seconds: 2))
            .millisecondsSinceEpoch,
        'bottom_at': startedAt
            .add(const Duration(seconds: 3))
            .millisecondsSinceEpoch,
        'completed_at': startedAt
            .add(const Duration(seconds: 4))
            .millisecondsSinceEpoch,
        'duration_milliseconds': 2000,
        'depth_score': 64.0,
        'control_score': 86.0,
        'balance_score': null,
        'overall_form_score': 75.0,
        'detected_issues': '["insufficientDepth"]',
        'camera_angle': CameraAngle.side.name,
        'confidence': 0.88,
      });
      await database.update(
        'workout_sets',
        {'completed_reps': 1},
        where: 'id = ?',
        whereArgs: [set.id],
      );
      await database.update(
        'workout_sessions',
        {'total_reps': 1},
        where: 'id = ?',
        whereArgs: [session.id],
      );

      final restored = await harness.repository.loadSession(session.id);

      expect(restored, isNotNull);
      expect(restored!.session.videoPath, isNull);
      expect(restored.session.videoDurationMilliseconds, isNull);
      final restoredRep = restored.reps.single;
      expect(restoredRep.sequenceNumber, isNull);
      expect(restoredRep.videoStartMilliseconds, isNull);
      expect(restoredRep.videoBottomMilliseconds, isNull);
      expect(restoredRep.videoEndMilliseconds, isNull);
      expect(restoredRep.primaryIssue, isNull);
      expect(restoredRep.depthQuality, RepQuality.unavailable);
      expect(restoredRep.upperBodyQuality, RepQuality.unavailable);
      expect(restoredRep.kneeAlignmentQuality, RepQuality.unavailable);

      final analysis = restored.repAnalyses.single;
      expect(analysis.repNumber, 1);
      expect(analysis.startTime, const Duration(seconds: 2));
      expect(analysis.bottomTime, const Duration(seconds: 3));
      expect(analysis.endTime, const Duration(seconds: 4));
      expect(analysis.primaryIssue, FormIssue.insufficientDepth);
      expect(analysis.result, RepAnalysisResult.needsImprovement);
    } finally {
      await harness.dispose();
    }
  });

  test('v4 migration adds nullable timeline and video defaults', () async {
    final directory = await Directory.systemTemp.createTemp(
      'rep-timeline-v4-migration-',
    );
    final databasePath = p.join(directory.path, 'motionfit.db');
    AppDatabase? appDatabase;
    try {
      final legacy = await databaseFactoryFfi.openDatabase(
        databasePath,
        options: OpenDatabaseOptions(
          version: 4,
          onCreate: (database, _) => _createV4WorkoutSchema(database),
        ),
      );
      final startedAt = DateTime.utc(2026, 8, 10, 9);
      await legacy.insert('workout_sessions', _legacySessionRow(startedAt));
      await legacy.insert('workout_sets', _legacySetRow(startedAt));
      await legacy.insert('rep_records', _legacyRepRow(startedAt));
      await legacy.close();

      appDatabase = AppDatabase(
        factory: databaseFactoryFfi,
        path: databasePath,
      );
      final upgraded = await appDatabase.database;
      final repository = SqliteWorkoutRepository(appDatabase);
      final restored = await repository.loadSession('v4-session');

      expect(await upgraded.getVersion(), AppDatabase.schemaVersion);
      expect(restored, isNotNull);
      expect(restored!.session.analyticsSessionId, isNull);
      expect(restored.session.videoPath, isNull);
      expect(restored.session.videoDurationMilliseconds, isNull);
      final rep = restored.reps.single;
      expect(rep.sequenceNumber, isNull);
      expect(rep.videoStartMilliseconds, isNull);
      expect(rep.videoBottomMilliseconds, isNull);
      expect(rep.videoEndMilliseconds, isNull);
      expect(rep.primaryIssue, isNull);
      expect(rep.depthQuality, RepQuality.unavailable);
      expect(rep.upperBodyQuality, RepQuality.unavailable);
      expect(rep.kneeAlignmentQuality, RepQuality.unavailable);
    } finally {
      await appDatabase?.close();
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    }
  });
}

class _RepositoryHarness {
  _RepositoryHarness._(this.directory, this.database, this.repository);

  final Directory directory;
  late AppDatabase database;
  late SqliteWorkoutRepository repository;

  static Future<_RepositoryHarness> open(String prefix) async {
    final directory = await Directory.systemTemp.createTemp(prefix);
    final database = AppDatabase(
      factory: databaseFactoryFfi,
      path: p.join(directory.path, 'motionfit.db'),
    );
    await database.database;
    return _RepositoryHarness._(
      directory,
      database,
      SqliteWorkoutRepository(database),
    );
  }

  void reopen() {
    database = AppDatabase(
      factory: databaseFactoryFfi,
      path: p.join(directory.path, 'motionfit.db'),
    );
    repository = SqliteWorkoutRepository(database);
  }

  Future<void> dispose() async {
    await database.close();
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }
}

WorkoutSession _session({
  required String id,
  required DateTime startedAt,
  String? analyticsSessionId,
}) => WorkoutSession(
  id: id,
  startedAt: startedAt,
  plannedSetCount: 1,
  plannedRepsPerSet: 5,
  plannedRestSeconds: 30,
  completedSetCount: 0,
  totalReps: 0,
  activeDurationSeconds: 0,
  restDurationSeconds: 0,
  totalDurationSeconds: 0,
  averageRepDurationMilliseconds: 0,
  completed: false,
  interrupted: false,
  createdAt: startedAt,
  analyticsSessionId: analyticsSessionId,
);

WorkoutSet _setFor(WorkoutSession session) => WorkoutSet(
  id: '${session.id}-set-1',
  sessionId: session.id,
  setIndex: 1,
  startedAt: session.startedAt,
  targetReps: session.plannedRepsPerSet,
  completedReps: 0,
  activeDurationSeconds: 0,
  restDurationAfterSeconds: 0,
);

RepRecord _rep({
  required WorkoutSession session,
  required WorkoutSet set,
  required int sequenceNumber,
  required int videoStartMilliseconds,
  required int videoBottomMilliseconds,
  required int videoEndMilliseconds,
  required FormIssue primaryIssue,
  required List<FormIssue> detectedIssues,
  RepQuality depthQuality = RepQuality.good,
  RepQuality upperBodyQuality = RepQuality.good,
  RepQuality kneeAlignmentQuality = RepQuality.good,
}) => RepRecord(
  id: '${session.id}-rep-$sequenceNumber',
  sessionId: session.id,
  setId: set.id,
  repIndex: 1,
  startedAt: session.startedAt.add(
    Duration(milliseconds: videoStartMilliseconds),
  ),
  bottomAt: session.startedAt.add(
    Duration(milliseconds: videoBottomMilliseconds),
  ),
  completedAt: session.startedAt.add(
    Duration(milliseconds: videoEndMilliseconds),
  ),
  durationMilliseconds: videoEndMilliseconds - videoStartMilliseconds,
  depthScore: 90,
  controlScore: 84,
  balanceScore: 88,
  overallFormScore: 87,
  detectedIssues: detectedIssues,
  cameraAngle: CameraAngle.oblique,
  confidence: 0.92,
  sequenceNumber: sequenceNumber,
  videoStartMilliseconds: videoStartMilliseconds,
  videoBottomMilliseconds: videoBottomMilliseconds,
  videoEndMilliseconds: videoEndMilliseconds,
  primaryIssue: primaryIssue,
  depthQuality: depthQuality,
  upperBodyQuality: upperBodyQuality,
  kneeAlignmentQuality: kneeAlignmentQuality,
);

Future<void> _createV4WorkoutSchema(Database database) async {
  await database.execute('''
    CREATE TABLE workout_sessions (
      id TEXT PRIMARY KEY,
      started_at INTEGER NOT NULL,
      ended_at INTEGER,
      planned_set_count INTEGER NOT NULL,
      planned_reps_per_set INTEGER NOT NULL,
      planned_rest_seconds INTEGER NOT NULL,
      completed_set_count INTEGER NOT NULL DEFAULT 0,
      total_reps INTEGER NOT NULL DEFAULT 0,
      active_duration_seconds INTEGER NOT NULL DEFAULT 0,
      rest_duration_seconds INTEGER NOT NULL DEFAULT 0,
      total_duration_seconds INTEGER NOT NULL DEFAULT 0,
      average_rep_duration_milliseconds INTEGER NOT NULL DEFAULT 0,
      completed INTEGER NOT NULL DEFAULT 0,
      interrupted INTEGER NOT NULL DEFAULT 0,
      created_at INTEGER NOT NULL
    )
  ''');
  await database.execute('''
    CREATE TABLE workout_sets (
      id TEXT PRIMARY KEY,
      session_id TEXT NOT NULL REFERENCES workout_sessions(id) ON DELETE CASCADE,
      set_index INTEGER NOT NULL,
      started_at INTEGER NOT NULL,
      ended_at INTEGER,
      target_reps INTEGER NOT NULL,
      completed_reps INTEGER NOT NULL DEFAULT 0,
      active_duration_seconds INTEGER NOT NULL DEFAULT 0,
      rest_duration_after_seconds INTEGER NOT NULL DEFAULT 0,
      UNIQUE(session_id, set_index)
    )
  ''');
  await database.execute('''
    CREATE TABLE rep_records (
      id TEXT PRIMARY KEY,
      session_id TEXT NOT NULL REFERENCES workout_sessions(id) ON DELETE CASCADE,
      set_id TEXT NOT NULL REFERENCES workout_sets(id) ON DELETE CASCADE,
      rep_index INTEGER NOT NULL,
      started_at INTEGER NOT NULL,
      bottom_at INTEGER,
      completed_at INTEGER NOT NULL,
      duration_milliseconds INTEGER NOT NULL,
      depth_score REAL,
      control_score REAL,
      balance_score REAL,
      overall_form_score REAL,
      detected_issues TEXT NOT NULL DEFAULT '[]',
      camera_angle TEXT NOT NULL,
      confidence REAL NOT NULL,
      UNIQUE(set_id, rep_index)
    )
  ''');
}

Map<String, Object?> _legacySessionRow(DateTime startedAt) => {
  'id': 'v4-session',
  'started_at': startedAt.millisecondsSinceEpoch,
  'ended_at': startedAt.add(const Duration(minutes: 1)).millisecondsSinceEpoch,
  'planned_set_count': 1,
  'planned_reps_per_set': 5,
  'planned_rest_seconds': 30,
  'completed_set_count': 1,
  'total_reps': 1,
  'active_duration_seconds': 30,
  'rest_duration_seconds': 0,
  'total_duration_seconds': 30,
  'average_rep_duration_milliseconds': 2000,
  'completed': 1,
  'interrupted': 0,
  'created_at': startedAt.millisecondsSinceEpoch,
};

Map<String, Object?> _legacySetRow(DateTime startedAt) => {
  'id': 'v4-set',
  'session_id': 'v4-session',
  'set_index': 1,
  'started_at': startedAt.millisecondsSinceEpoch,
  'ended_at': startedAt.add(const Duration(seconds: 30)).millisecondsSinceEpoch,
  'target_reps': 5,
  'completed_reps': 1,
  'active_duration_seconds': 30,
  'rest_duration_after_seconds': 0,
};

Map<String, Object?> _legacyRepRow(DateTime startedAt) => {
  'id': 'v4-rep',
  'session_id': 'v4-session',
  'set_id': 'v4-set',
  'rep_index': 1,
  'started_at': startedAt
      .add(const Duration(seconds: 2))
      .millisecondsSinceEpoch,
  'bottom_at': startedAt
      .add(const Duration(seconds: 3))
      .millisecondsSinceEpoch,
  'completed_at': startedAt
      .add(const Duration(seconds: 4))
      .millisecondsSinceEpoch,
  'duration_milliseconds': 2000,
  'depth_score': 68.0,
  'control_score': 80.0,
  'balance_score': null,
  'overall_form_score': 74.0,
  'detected_issues': '["insufficientDepth"]',
  'camera_angle': 'side',
  'confidence': 0.9,
};
