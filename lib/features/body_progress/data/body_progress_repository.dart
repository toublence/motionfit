import 'dart:io';

import 'package:motionfit_squat/core/database/app_database.dart';
import 'package:motionfit_squat/features/body_progress/domain/body_progress_photo.dart';
import 'package:sqflite/sqflite.dart';

/// Stores the Body Progress photo index.
///
/// Image bytes stay in the private directory owned by the native capture
/// plugin; only the file name is persisted so a restored application container
/// with a new absolute path still resolves.
class BodyProgressRepository {
  const BodyProgressRepository(this.appDatabase, {this.onError});

  final AppDatabase appDatabase;
  final void Function(Object error, StackTrace stackTrace, String reason)?
  onError;

  Future<List<BodyProgressPhoto>> loadPhotos({BodyView? bodyView}) async {
    final database = await appDatabase.database;
    final rows = await database.query(
      'body_progress_photos',
      where: bodyView == null ? null : 'body_view = ?',
      whereArgs: bodyView == null ? null : [bodyView.name],
      orderBy: 'captured_at ASC',
    );
    final photos = <BodyProgressPhoto>[];
    for (final row in rows) {
      try {
        photos.add(BodyProgressPhoto.fromMap(row));
      } on Object catch (error, stackTrace) {
        onError?.call(error, stackTrace, 'body_progress_photo_parse');
      }
    }
    return photos;
  }

  /// Writes [photo] as the representative entry for its day and view.
  ///
  /// An existing entry for the same day and view is replaced and its image is
  /// removed, which keeps the timeline to one photo per day per view.
  Future<void> savePhoto(
    BodyProgressPhoto photo, {
    required Directory directory,
  }) async {
    final database = await appDatabase.database;
    final replaced = <String>[];
    await database.transaction((transaction) async {
      final existing = await transaction.query(
        'body_progress_photos',
        columns: ['id', 'image_file'],
        where: 'captured_on = ? AND body_view = ?',
        whereArgs: [photo.capturedOn, photo.bodyView.name],
      );
      for (final row in existing) {
        final file = row['image_file'] as String?;
        if (file != null && file != photo.imageFile) replaced.add(file);
      }
      await transaction.delete(
        'body_progress_photos',
        where: 'captured_on = ? AND body_view = ?',
        whereArgs: [photo.capturedOn, photo.bodyView.name],
      );
      await transaction.insert(
        'body_progress_photos',
        photo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
    for (final file in replaced) {
      await _deleteImage(directory, file);
    }
  }

  /// True when a photo already exists for [dayKey] and [bodyView].
  Future<bool> hasPhotoOn(String dayKey, BodyView bodyView) async {
    final database = await appDatabase.database;
    final rows = await database.query(
      'body_progress_photos',
      columns: ['id'],
      where: 'captured_on = ? AND body_view = ?',
      whereArgs: [dayKey, bodyView.name],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  /// Writes [photo] only when that day and view is still empty.
  ///
  /// This is what keeps the automatic capture idempotent. A repeated workout,
  /// an app resume, or a duplicated completion callback all hit the same day
  /// key and leave the first entry alone. A manual retake still goes through
  /// [savePhoto] and replaces it deliberately.
  ///
  /// Returns true when the photo was stored.
  Future<bool> savePhotoIfAbsent(BodyProgressPhoto photo) async {
    final database = await appDatabase.database;
    final inserted = await database.insert(
      'body_progress_photos',
      photo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    return inserted != 0;
  }

  Future<void> deletePhoto(String id, {required Directory directory}) async {
    final database = await appDatabase.database;
    final rows = await database.query(
      'body_progress_photos',
      columns: ['image_file'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    await database.delete(
      'body_progress_photos',
      where: 'id = ?',
      whereArgs: [id],
    );
    final file = rows.isEmpty ? null : rows.first['image_file'] as String?;
    if (file != null) await _deleteImage(directory, file);
  }

  /// Removes every photo row and image. Used by data deletion flows.
  Future<void> deleteAll({required Directory directory}) async {
    final database = await appDatabase.database;
    final rows = await database.query(
      'body_progress_photos',
      columns: ['image_file'],
    );
    await database.delete('body_progress_photos');
    for (final row in rows) {
      final file = row['image_file'] as String?;
      if (file != null) await _deleteImage(directory, file);
    }
  }

  Future<void> _deleteImage(Directory directory, String fileName) async {
    try {
      final file = File('${directory.path}${Platform.pathSeparator}$fileName');
      if (file.existsSync()) await file.delete();
    } on Object catch (error, stackTrace) {
      // A stale image only wastes disk; the index is already consistent.
      onError?.call(error, stackTrace, 'body_progress_image_delete');
    }
  }
}
