import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:motionfit_squat/core/database/app_database.dart';
import 'package:motionfit_squat/features/body_progress/data/body_progress_repository.dart';
import 'package:motionfit_squat/features/body_progress/domain/body_progress_photo.dart';
import 'package:motionfit_squat/features/form_progress/data/form_pose_repository.dart';
import 'package:motionfit_squat/features/form_progress/domain/form_pose_snapshot.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Covers the rule the automatic capture depends on: one Body Progress photo
/// per day, and one Form Progress pose per day per exercise, no matter how many
/// times the user works out or how often a callback fires.
BodyProgressPhoto autoPhoto({
  required String id,
  required DateTime at,
  required String file,
  BodyView view = BodyView.front,
}) => BodyProgressPhoto(
  id: id,
  capturedAt: at,
  capturedOn: BodyProgressPhoto.dayKey(at),
  bodyView: view,
  imageFile: file,
  imageWidth: 640,
  imageHeight: 480,
  source: BodyProgressSource.auto,
  sessionId: 'session-$id',
  createdAt: at,
);

FormPoseSnapshot pose({
  required String sessionId,
  required DateTime at,
  double score = 62,
}) => FormPoseSnapshot(
  sessionId: sessionId,
  repId: '$sessionId:1',
  capturedAt: at,
  capturedOn: FormPoseSnapshot.dayKey(at),
  formScore: score,
  accuracy: 0.8,
  primaryIssue: null,
  landmarks: List.generate(
    33,
    (index) => FormPosePoint(x: 0.5, y: index / 33, confidence: 0.9),
  ),
  sourceWidth: 640,
  sourceHeight: 480,
  mirrored: true,
  createdAt: at,
);

Future<void> seedSession(AppDatabase database, String id) async {
  final raw = await database.database;
  await raw.insert('workout_sessions', {
    'id': id,
    'started_at': DateTime(2026, 9, 10, 7).millisecondsSinceEpoch,
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
    'created_at': DateTime(2026, 9, 10, 7).millisecondsSinceEpoch,
  });
}

void main() {
  sqfliteFfiInit();

  late Directory directory;
  late AppDatabase database;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('motionfit-auto-');
    database = AppDatabase(
      factory: databaseFactoryFfi,
      path: '${directory.path}/motionfit.db',
    );
  });

  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  group('Body Progress daily rule', () {
    test('the first workout of the day stores a photo', () async {
      final repository = BodyProgressRepository(database);
      final morning = DateTime(2026, 9, 10, 7);

      expect(
        await repository.hasPhotoOn(
          BodyProgressPhoto.dayKey(morning),
          BodyView.front,
        ),
        isFalse,
      );
      final stored = await repository.savePhotoIfAbsent(
        autoPhoto(id: 'a', at: morning, file: 'a.jpg'),
      );

      expect(stored, isTrue);
      expect(await repository.loadPhotos(), hasLength(1));
    });

    test('a second workout the same day stores nothing', () async {
      final repository = BodyProgressRepository(database);
      final morning = DateTime(2026, 9, 10, 7);
      final evening = DateTime(2026, 9, 10, 19);

      await repository.savePhotoIfAbsent(
        autoPhoto(id: 'a', at: morning, file: 'a.jpg'),
      );
      final second = await repository.savePhotoIfAbsent(
        autoPhoto(id: 'b', at: evening, file: 'b.jpg'),
      );

      expect(second, isFalse);
      final photos = await repository.loadPhotos();
      expect(photos, hasLength(1));
      expect(
        photos.single.imageFile,
        'a.jpg',
        reason: 'the first capture of the day wins',
      );
    });

    test('a repeated callback for one session stores nothing', () async {
      final repository = BodyProgressRepository(database);
      final at = DateTime(2026, 9, 10, 7);
      final photo = autoPhoto(id: 'a', at: at, file: 'a.jpg');

      expect(await repository.savePhotoIfAbsent(photo), isTrue);
      expect(await repository.savePhotoIfAbsent(photo), isFalse);
      expect(await repository.loadPhotos(), hasLength(1));
    });

    test('the next day stores a new photo', () async {
      final repository = BodyProgressRepository(database);

      await repository.savePhotoIfAbsent(
        autoPhoto(id: 'a', at: DateTime(2026, 9, 10, 7), file: 'a.jpg'),
      );
      final next = await repository.savePhotoIfAbsent(
        autoPhoto(id: 'b', at: DateTime(2026, 9, 11, 7), file: 'b.jpg'),
      );

      expect(next, isTrue);
      expect(await repository.loadPhotos(), hasLength(2));
    });

    test('a manual retake still replaces the automatic photo', () async {
      final repository = BodyProgressRepository(database);
      final at = DateTime(2026, 9, 10, 7);

      await repository.savePhotoIfAbsent(
        autoPhoto(id: 'a', at: at, file: 'a.jpg'),
      );
      await repository.savePhoto(
        BodyProgressPhoto(
          id: 'manual',
          capturedAt: at,
          capturedOn: BodyProgressPhoto.dayKey(at),
          bodyView: BodyView.front,
          imageFile: 'manual.jpg',
          imageWidth: 1200,
          imageHeight: 1600,
          createdAt: at,
        ),
        directory: directory,
      );

      final photos = await repository.loadPhotos();
      expect(photos, hasLength(1));
      expect(photos.single.imageFile, 'manual.jpg');
      expect(photos.single.isAutomatic, isFalse);
    });
  });

  group('Form Progress daily rule', () {
    test('the first scored rep of the day stores a pose', () async {
      final repository = FormPoseRepository(database);
      await seedSession(database, 'session-1');
      final at = DateTime(2026, 9, 10, 7);

      expect(
        await repository.hasSnapshotOn(FormPoseSnapshot.dayKey(at)),
        isFalse,
      );
      final stored = await repository.saveIfAbsent(
        pose(sessionId: 'session-1', at: at),
      );

      expect(stored, isTrue);
      expect(await repository.loadAll(), hasLength(1));
    });

    test('a second session the same day stores nothing', () async {
      final repository = FormPoseRepository(database);
      await seedSession(database, 'session-1');
      await seedSession(database, 'session-2');

      await repository.saveIfAbsent(
        pose(sessionId: 'session-1', at: DateTime(2026, 9, 10, 7), score: 62),
      );
      final second = await repository.saveIfAbsent(
        pose(sessionId: 'session-2', at: DateTime(2026, 9, 10, 19), score: 91),
      );

      expect(second, isFalse);
      final stored = await repository.loadAll();
      expect(stored, hasLength(1));
      expect(
        stored.values.single.sessionId,
        'session-1',
        reason: 'the first session of the day wins, even if a later one scores '
            'higher',
      );
    });

    test('a repeated callback for one session stores nothing', () async {
      final repository = FormPoseRepository(database);
      await seedSession(database, 'session-1');
      final snapshot = pose(
        sessionId: 'session-1',
        at: DateTime(2026, 9, 10, 7),
      );

      expect(await repository.saveIfAbsent(snapshot), isTrue);
      expect(await repository.saveIfAbsent(snapshot), isFalse);
      expect(await repository.loadAll(), hasLength(1));
    });

    test('the next day stores a new pose', () async {
      final repository = FormPoseRepository(database);
      await seedSession(database, 'session-1');
      await seedSession(database, 'session-2');

      await repository.saveIfAbsent(
        pose(sessionId: 'session-1', at: DateTime(2026, 9, 10, 7)),
      );
      final next = await repository.saveIfAbsent(
        pose(sessionId: 'session-2', at: DateTime(2026, 9, 11, 7)),
      );

      expect(next, isTrue);
      expect(await repository.loadAll(), hasLength(2));
    });

    test('a different exercise database keeps its own daily entry', () async {
      // Each exercise owns a separate database file, which is what makes the
      // day key alone enough to mean "one per exercise per day".
      final pushupDatabase = AppDatabase(
        factory: databaseFactoryFfi,
        path: '${directory.path}/motionfit_pushup.db',
      );
      addTearDown(pushupDatabase.close);
      await seedSession(database, 'squat-1');
      await seedSession(pushupDatabase, 'pushup-1');
      final at = DateTime(2026, 9, 10, 7);

      final squatStored = await FormPoseRepository(
        database,
      ).saveIfAbsent(pose(sessionId: 'squat-1', at: at));
      final pushupStored = await FormPoseRepository(
        pushupDatabase,
      ).saveIfAbsent(pose(sessionId: 'pushup-1', at: at));

      expect(squatStored, isTrue);
      expect(pushupStored, isTrue);
    });
  });
}
