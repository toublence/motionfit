import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:motionfit_squat/core/database/app_database.dart';
import 'package:motionfit_squat/features/body_progress/data/body_progress_repository.dart';
import 'package:motionfit_squat/features/body_progress/domain/body_progress_photo.dart';
import 'package:motionfit_squat/features/form_progress/data/form_pose_repository.dart';
import 'package:motionfit_squat/features/form_progress/domain/form_pose_snapshot.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Creates a database at the pre-progress schema so the upgrade path is
/// exercised the way an installed app hits it, not just a fresh install.
Future<void> seedVersion6(String path) async {
  final database = await databaseFactoryFfi.openDatabase(
    path,
    options: OpenDatabaseOptions(
      version: 6,
      onCreate: (database, version) async {
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
            completed INTEGER NOT NULL DEFAULT 0 CHECK(completed IN (0, 1)),
            interrupted INTEGER NOT NULL DEFAULT 0 CHECK(interrupted IN (0, 1)),
            created_at INTEGER NOT NULL,
            analytics_session_id TEXT,
            video_path TEXT,
            video_duration_milliseconds INTEGER
          )
        ''');
        await database.insert('workout_sessions', {
          'id': 'legacy-session',
          'started_at': DateTime.utc(2026, 1, 2).millisecondsSinceEpoch,
          'planned_set_count': 3,
          'planned_reps_per_set': 10,
          'planned_rest_seconds': 60,
          'completed_set_count': 3,
          'total_reps': 30,
          'active_duration_seconds': 300,
          'rest_duration_seconds': 120,
          'total_duration_seconds': 420,
          'average_rep_duration_milliseconds': 2000,
          'completed': 1,
          'interrupted': 0,
          'created_at': DateTime.utc(2026, 1, 2).millisecondsSinceEpoch,
        });
      },
    ),
  );
  await database.close();
}

void main() {
  sqfliteFfiInit();

  late Directory directory;
  late AppDatabase database;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('motionfit-progress-');
    await seedVersion6('${directory.path}/motionfit.db');
    database = AppDatabase(
      factory: databaseFactoryFfi,
      path: '${directory.path}/motionfit.db',
    );
  });

  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  test('upgrading from version 6 adds the progress tables', () async {
    final raw = await database.database;
    final tables = (await raw.query(
      'sqlite_master',
      columns: ['name'],
      where: "type = 'table'",
    )).map((row) => row['name'] as String).toSet();

    expect(tables, contains('body_progress_photos'));
    expect(tables, contains('form_pose_snapshots'));
  });

  test('an upgrade keeps the workout rows that were already there', () async {
    final raw = await database.database;
    final sessions = await raw.query('workout_sessions');

    expect(sessions, hasLength(1));
    expect(sessions.single['id'], 'legacy-session');
    expect(sessions.single['total_reps'], 30);
  });

  test('a photo is stored and read back after the upgrade', () async {
    final repository = BodyProgressRepository(database);
    final captured = DateTime(2026, 6, 1, 9);
    final photo = BodyProgressPhoto(
      id: 'p1',
      capturedAt: captured,
      capturedOn: BodyProgressPhoto.dayKey(captured),
      bodyView: BodyView.front,
      imageFile: 'body_1.jpg',
      imageWidth: 1200,
      imageHeight: 1600,
      createdAt: captured,
    );

    await repository.savePhoto(photo, directory: directory);
    final stored = await repository.loadPhotos();

    expect(stored, hasLength(1));
    expect(stored.single.imageFile, 'body_1.jpg');
    expect(stored.single.bodyView, BodyView.front);
  });

  test('a second photo on the same day and view replaces the first', () async {
    final repository = BodyProgressRepository(database);
    final morning = DateTime(2026, 6, 1, 9);
    final evening = DateTime(2026, 6, 1, 20);

    await repository.savePhoto(
      BodyProgressPhoto(
        id: 'p1',
        capturedAt: morning,
        capturedOn: BodyProgressPhoto.dayKey(morning),
        bodyView: BodyView.front,
        imageFile: 'body_1.jpg',
        imageWidth: 1200,
        imageHeight: 1600,
        createdAt: morning,
      ),
      directory: directory,
    );
    await repository.savePhoto(
      BodyProgressPhoto(
        id: 'p2',
        capturedAt: evening,
        capturedOn: BodyProgressPhoto.dayKey(evening),
        bodyView: BodyView.front,
        imageFile: 'body_2.jpg',
        imageWidth: 1200,
        imageHeight: 1600,
        createdAt: evening,
      ),
      directory: directory,
    );

    final stored = await repository.loadPhotos();
    expect(stored, hasLength(1));
    expect(stored.single.imageFile, 'body_2.jpg');
  });

  test('the same day keeps one photo per body view', () async {
    final repository = BodyProgressRepository(database);
    final captured = DateTime(2026, 6, 1, 9);

    for (final view in BodyView.values) {
      await repository.savePhoto(
        BodyProgressPhoto(
          id: 'p-${view.name}',
          capturedAt: captured,
          capturedOn: BodyProgressPhoto.dayKey(captured),
          bodyView: view,
          imageFile: 'body_${view.name}.jpg',
          imageWidth: 1200,
          imageHeight: 1600,
          createdAt: captured,
        ),
        directory: directory,
      );
    }

    expect(await repository.loadPhotos(), hasLength(3));
    expect(
      await repository.loadPhotos(bodyView: BodyView.side),
      hasLength(1),
    );
  });

  test('deleting a session removes its pose snapshot', () async {
    final repository = FormPoseRepository(database);
    final captured = DateTime(2026, 6, 1, 9);
    await repository.save(
      FormPoseSnapshot(
        sessionId: 'legacy-session',
        repId: 'legacy-session:3',
        capturedAt: captured,
        capturedOn: FormPoseSnapshot.dayKey(captured),
        formScore: 72,
        accuracy: 0.85,
        primaryIssue: null,
        landmarks: List.generate(
          33,
          (index) => FormPosePoint(x: 0.5, y: index / 33, confidence: 0.8),
        ),
        sourceWidth: 640,
        sourceHeight: 480,
        mirrored: false,
        createdAt: captured,
      ),
    );

    expect(await repository.load('legacy-session'), isNotNull);

    final raw = await database.database;
    await raw.delete(
      'workout_sessions',
      where: 'id = ?',
      whereArgs: ['legacy-session'],
    );

    expect(await repository.load('legacy-session'), isNull);
    expect(await repository.loadAll(), isEmpty);
  });

  test('upgrading from version 7 keeps one pose per day', () async {
    // Version 7 stored one pose per session, so a day with three workouts left
    // three rows. The upgrade has to collapse them before it can add the
    // one-per-day index, or the app fails to launch.
    final legacyPath = '${directory.path}/motionfit_v7.db';
    final seeded = await databaseFactoryFfi.openDatabase(
      legacyPath,
      options: OpenDatabaseOptions(
        version: 7,
        onCreate: (database, version) async {
          await database.execute('''
            CREATE TABLE form_pose_snapshots (
              session_id TEXT PRIMARY KEY,
              rep_id TEXT,
              captured_at INTEGER NOT NULL,
              form_score REAL,
              primary_issue TEXT,
              landmarks TEXT NOT NULL,
              source_width INTEGER NOT NULL DEFAULT 0,
              source_height INTEGER NOT NULL DEFAULT 0,
              mirrored INTEGER NOT NULL DEFAULT 0,
              created_at INTEGER NOT NULL
            )
          ''');
          final day = DateTime(2026, 9, 10);
          for (var index = 0; index < 3; index++) {
            await database.insert('form_pose_snapshots', {
              'session_id': 'legacy-$index',
              'rep_id': 'legacy-$index:1',
              'captured_at': day
                  .add(Duration(hours: 7 + index * 4))
                  .millisecondsSinceEpoch,
              'form_score': 60.0 + index,
              'landmarks': '[]',
              'source_width': 640,
              'source_height': 480,
              'mirrored': 1,
              'created_at': day.millisecondsSinceEpoch,
            });
          }
          // A different day must survive the collapse untouched.
          await database.insert('form_pose_snapshots', {
            'session_id': 'legacy-next-day',
            'rep_id': 'legacy-next-day:1',
            'captured_at':
                DateTime(2026, 9, 11, 7).millisecondsSinceEpoch,
            'form_score': 70.0,
            'landmarks': '[]',
            'source_width': 640,
            'source_height': 480,
            'mirrored': 1,
            'created_at': DateTime(2026, 9, 11).millisecondsSinceEpoch,
          });
        },
      ),
    );
    await seeded.close();

    final upgraded = AppDatabase(
      factory: databaseFactoryFfi,
      path: legacyPath,
    );
    addTearDown(upgraded.close);
    final rows = await (await upgraded.database).query(
      'form_pose_snapshots',
      orderBy: 'captured_at ASC',
    );

    expect(rows, hasLength(2));
    expect(rows.first['session_id'], 'legacy-0');
    expect(rows.first['captured_on'], '2026-09-10');
    expect(rows.last['session_id'], 'legacy-next-day');
    expect(rows.last['captured_on'], '2026-09-11');
  });
}
