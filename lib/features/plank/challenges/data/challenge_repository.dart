import 'package:motionfit_squat/core/database/app_database.dart';
import 'package:motionfit_squat/features/plank/challenges/domain/challenge.dart';
import 'package:sqflite/sqflite.dart';

class ChallengeRepository {
  const ChallengeRepository(this.appDatabase, {this.onError});

  final AppDatabase appDatabase;
  final void Function(Object error, StackTrace stackTrace, String reason)?
  onError;

  Future<List<Challenge>> loadAll() async {
    final database = await appDatabase.database;
    final rows = await database.query('challenges', orderBy: 'created_at DESC');
    final challenges = <Challenge>[];
    for (final row in rows) {
      try {
        challenges.add(Challenge.fromMap(row));
      } on Object catch (error, stackTrace) {
        onError?.call(error, stackTrace, 'challenge_data_parse');
      }
    }
    return challenges;
  }

  Future<void> start(Challenge challenge) async {
    final database = await appDatabase.database;
    await database.transaction((transaction) async {
      final active = Sqflite.firstIntValue(
        await transaction.rawQuery(
          "SELECT COUNT(*) FROM challenges WHERE status = 'active'",
        ),
      );
      if ((active ?? 0) > 0) {
        throw StateError('Only one challenge can be active.');
      }
      await transaction.insert(
        'challenges',
        challenge.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    });
  }

  Future<void> update(Challenge challenge) async {
    final database = await appDatabase.database;
    await database.update(
      'challenges',
      challenge.toMap(),
      where: 'id = ?',
      whereArgs: [challenge.id],
    );
  }

  Future<void> delete(String id) async {
    final database = await appDatabase.database;
    await database.delete('challenges', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteByType(ChallengeType type) async {
    final database = await appDatabase.database;
    await database.delete(
      'challenges',
      where: 'type = ?',
      whereArgs: [type.name],
    );
  }

  Future<bool> isBadgeSeen() async {
    final database = await appDatabase.database;
    final rows = await database.query(
      'app_state',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: ['challenge_tab_seen'],
      limit: 1,
    );
    return rows.isNotEmpty && rows.first['value'] == 'true';
  }

  Future<void> markBadgeSeen() async {
    final database = await appDatabase.database;
    await database.insert('app_state', {
      'key': 'challenge_tab_seen',
      'value': 'true',
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<bool> isRecommendationDismissed() async {
    final database = await appDatabase.database;
    final rows = await database.query(
      'app_state',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: ['challenge_recommendation_dismissed'],
      limit: 1,
    );
    return rows.isNotEmpty && rows.first['value'] == 'true';
  }

  Future<void> dismissRecommendation() async {
    final database = await appDatabase.database;
    await database.insert('app_state', {
      'key': 'challenge_recommendation_dismissed',
      'value': 'true',
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<DateTime> installReferenceDate() async {
    final database = await appDatabase.database;
    final rows = await database.query(
      'app_state',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: ['challenge_install_reference'],
      limit: 1,
    );
    if (rows.isNotEmpty) {
      final raw = rows.first['value'];
      final milliseconds = raw is String ? int.tryParse(raw) : null;
      if (milliseconds != null) {
        return DateTime.fromMillisecondsSinceEpoch(milliseconds);
      }
      onError?.call(
        FormatException('Invalid challenge install reference'),
        StackTrace.current,
        'challenge_install_reference_parse',
      );
    }
    final now = DateTime.now();
    await database.insert('app_state', {
      'key': 'challenge_install_reference',
      'value': '${now.millisecondsSinceEpoch}',
      'updated_at': now.millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    return now;
  }
}
