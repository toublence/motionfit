import 'package:motionfit_squat/core/database/app_database.dart';
import 'package:motionfit_squat/features/form_progress/domain/form_pose_snapshot.dart';
import 'package:sqflite/sqflite.dart';

/// Reads and writes the representative pose of a workout.
///
/// One row per session, stored next to that session in its own exercise
/// database, so a deleted session removes its snapshot through the existing
/// foreign key cascade.
class FormPoseRepository {
  const FormPoseRepository(this.appDatabase, {this.onError});

  final AppDatabase appDatabase;
  final void Function(Object error, StackTrace stackTrace, String reason)?
  onError;

  Future<void> save(FormPoseSnapshot snapshot) async {
    final database = await appDatabase.database;
    try {
      await database.insert(
        'form_pose_snapshots',
        snapshot.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } on Object catch (error, stackTrace) {
      // A missing snapshot only removes a picture from Form Progress. It must
      // never fail the workout that produced it.
      onError?.call(error, stackTrace, 'form_pose_snapshot_save');
    }
  }

  /// True when a representative pose already exists for [dayKey].
  ///
  /// Each exercise keeps its own database, so a day key is unique per exercise
  /// and this enforces the one-per-day-per-exercise rule.
  Future<bool> hasSnapshotOn(String dayKey) async {
    final database = await appDatabase.database;
    final rows = await database.query(
      'form_pose_snapshots',
      columns: ['session_id'],
      where: 'captured_on = ?',
      whereArgs: [dayKey],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  /// Writes [snapshot] only when its day is still empty.
  ///
  /// Keeps the automatic capture idempotent across repeated sessions, resumes,
  /// and duplicated rep callbacks. Failures are swallowed for the same reason
  /// [save] swallows them: a missing snapshot must never fail a workout.
  ///
  /// Returns true when the snapshot was stored.
  Future<bool> saveIfAbsent(FormPoseSnapshot snapshot) async {
    try {
      final database = await appDatabase.database;
      final inserted = await database.insert(
        'form_pose_snapshots',
        snapshot.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      return inserted != 0;
    } on Object catch (error, stackTrace) {
      onError?.call(error, stackTrace, 'form_pose_snapshot_save');
      return false;
    }
  }

  Future<Map<String, FormPoseSnapshot>> loadAll() async {
    final database = await appDatabase.database;
    final rows = await database.query(
      'form_pose_snapshots',
      orderBy: 'captured_at ASC',
    );
    final snapshots = <String, FormPoseSnapshot>{};
    for (final row in rows) {
      try {
        final snapshot = FormPoseSnapshot.fromMap(row);
        snapshots[snapshot.sessionId] = snapshot;
      } on Object catch (error, stackTrace) {
        onError?.call(error, stackTrace, 'form_pose_snapshot_parse');
      }
    }
    return snapshots;
  }

  Future<FormPoseSnapshot?> load(String sessionId) async {
    final database = await appDatabase.database;
    final rows = await database.query(
      'form_pose_snapshots',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    try {
      return FormPoseSnapshot.fromMap(rows.first);
    } on Object catch (error, stackTrace) {
      onError?.call(error, stackTrace, 'form_pose_snapshot_parse');
      return null;
    }
  }
}
