import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:motionfit_squat/core/database/app_database.dart';
import 'package:motionfit_squat/features/challenges/data/challenge_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  test('corrupt legacy challenge data is skipped and reported', () async {
    final directory = await Directory.systemTemp.createTemp(
      'motionfit-challenge-parse-test-',
    );
    final database = AppDatabase(
      factory: databaseFactoryFfi,
      path: '${directory.path}/motionfit.db',
    );
    final reasons = <String>[];
    final repository = ChallengeRepository(
      database,
      onError: (_, _, reason) => reasons.add(reason),
    );

    try {
      final raw = await database.database;
      final now = DateTime.now().millisecondsSinceEpoch;
      await raw.insert('challenges', {
        'id': 'corrupt',
        'type': 'sevenDay',
        'status': 'active',
        'started_at': now,
        'ends_at': now,
        'target_reps': 0,
        'daily_goals': '{not-json',
        'weekdays': '[]',
        'notification_enabled': 0,
        'created_at': now,
      });

      expect(await repository.loadAll(), isEmpty);
      expect(reasons, contains('challenge_data_parse'));
    } finally {
      await database.close();
      await directory.delete(recursive: true);
    }
  });

  test('invalid install reference is repaired instead of throwing', () async {
    final directory = await Directory.systemTemp.createTemp(
      'motionfit-challenge-reference-test-',
    );
    final database = AppDatabase(
      factory: databaseFactoryFfi,
      path: '${directory.path}/motionfit.db',
    );
    final reasons = <String>[];
    final repository = ChallengeRepository(
      database,
      onError: (_, _, reason) => reasons.add(reason),
    );

    try {
      final raw = await database.database;
      await raw.insert('app_state', {
        'key': 'challenge_install_reference',
        'value': 'legacy-invalid-value',
        'updated_at': 0,
      });

      final repaired = await repository.installReferenceDate();
      final stored = await raw.query(
        'app_state',
        where: 'key = ?',
        whereArgs: ['challenge_install_reference'],
      );

      expect(repaired.difference(DateTime.now()).inSeconds.abs(), lessThan(2));
      expect(int.tryParse(stored.single['value']! as String), isNotNull);
      expect(reasons, contains('challenge_install_reference_parse'));
    } finally {
      await database.close();
      await directory.delete(recursive: true);
    }
  });
}
