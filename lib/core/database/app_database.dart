import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase({DatabaseFactory? factory, String? path})
    : _factory = factory ?? databaseFactory,
      _path = path;

  final DatabaseFactory _factory;
  final String? _path;
  Database? _database;

  static const schemaVersion = 8;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final path =
        _path ?? p.join(await _factory.getDatabasesPath(), 'motionfit.db');
    _database = await _factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: schemaVersion,
        onConfigure: (database) async {
          await database.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: _createSchema,
        onUpgrade: _migrate,
      ),
    );
    return _database!;
  }

  Future<void> _createSchema(Database database, int version) async {
    await database.execute('''
      CREATE TABLE workout_plans (
        id TEXT PRIMARY KEY,
        set_count INTEGER NOT NULL CHECK(set_count BETWEEN 1 AND 20),
        target_reps_per_set INTEGER NOT NULL CHECK(target_reps_per_set BETWEEN 1 AND 300),
        rest_duration_seconds INTEGER NOT NULL CHECK(rest_duration_seconds BETWEEN 0 AND 600),
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
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
        sequence_number INTEGER,
        video_start_milliseconds INTEGER,
        video_bottom_milliseconds INTEGER,
        video_end_milliseconds INTEGER,
        primary_issue TEXT,
        depth_quality TEXT NOT NULL DEFAULT 'unavailable',
        upper_body_quality TEXT NOT NULL DEFAULT 'unavailable',
        knee_alignment_quality TEXT NOT NULL DEFAULT 'unavailable',
        UNIQUE(set_id, rep_index)
      )
    ''');
    await database.execute('''
      CREATE TABLE reminder_schedules (
        id INTEGER PRIMARY KEY,
        weekday INTEGER NOT NULL UNIQUE CHECK(weekday BETWEEN 1 AND 7),
        enabled INTEGER NOT NULL DEFAULT 0 CHECK(enabled IN (0, 1)),
        hour INTEGER NOT NULL CHECK(hour BETWEEN 0 AND 23),
        minute INTEGER NOT NULL CHECK(minute BETWEEN 0 AND 59)
      )
    ''');
    await database.execute('''
      CREATE TABLE app_state (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    await _createChallengeSchema(database);
    await _createLegacyArchiveSchema(database);
    await _createProgressSchema(database);
    await database.execute(
      'CREATE INDEX idx_sessions_started_at ON workout_sessions(started_at DESC)',
    );
    await database.execute(
      'CREATE INDEX idx_sets_session_id ON workout_sets(session_id, set_index)',
    );
    await database.execute(
      'CREATE INDEX idx_reps_session_id ON rep_records(session_id, completed_at)',
    );
  }

  Future<void> _migrate(
    Database database,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion > newVersion) {
      throw StateError('Database downgrade is not supported.');
    }
    if (oldVersion < 2) {
      final rows = await database.query(
        'workout_sessions',
        columns: ['id'],
        where:
            'completed = 0 AND interrupted = 1 AND '
            'total_reps < planned_set_count * planned_reps_per_set',
        orderBy: 'started_at DESC',
        limit: 1,
      );
      if (rows.isNotEmpty) {
        final sessionId = rows.first['id']! as String;
        await database.update(
          'workout_sessions',
          {'ended_at': null, 'interrupted': 0},
          where: 'id = ?',
          whereArgs: [sessionId],
        );
        await database.update(
          'workout_sets',
          {'ended_at': null},
          where:
              'session_id = ? AND set_index = '
              '(SELECT MAX(set_index) FROM workout_sets WHERE session_id = ?)',
          whereArgs: [sessionId, sessionId],
        );
      }
    }
    if (oldVersion < 3) {
      await _createChallengeSchema(database);
    }
    if (oldVersion < 4) {
      await database.delete(
        'challenges',
        where: 'type = ?',
        whereArgs: ['weekly'],
      );
    }
    if (oldVersion < 5) {
      await _addColumnIfMissing(
        database,
        table: 'workout_sessions',
        column: 'analytics_session_id',
        definition: 'TEXT',
      );
      await _addColumnIfMissing(
        database,
        table: 'workout_sessions',
        column: 'video_path',
        definition: 'TEXT',
      );
      await _addColumnIfMissing(
        database,
        table: 'workout_sessions',
        column: 'video_duration_milliseconds',
        definition: 'INTEGER',
      );
      for (final column in <(String, String)>[
        ('sequence_number', 'INTEGER'),
        ('video_start_milliseconds', 'INTEGER'),
        ('video_bottom_milliseconds', 'INTEGER'),
        ('video_end_milliseconds', 'INTEGER'),
        ('primary_issue', 'TEXT'),
        ('depth_quality', "TEXT NOT NULL DEFAULT 'unavailable'"),
        ('upper_body_quality', "TEXT NOT NULL DEFAULT 'unavailable'"),
        ('knee_alignment_quality', "TEXT NOT NULL DEFAULT 'unavailable'"),
      ]) {
        await _addColumnIfMissing(
          database,
          table: 'rep_records',
          column: column.$1,
          definition: column.$2,
        );
      }
    }
    if (oldVersion < 6) {
      await _createLegacyArchiveSchema(database);
    }
    if (oldVersion < 7) {
      await _createProgressSchema(database);
    }
    if (oldVersion < 8) {
      // No _createProgressSchema call here. It also builds the one-per-day
      // index, and on a version 7 database the column that index needs does
      // not exist yet. An upgrade from below 7 already ran it above, with the
      // current definition.
      for (final column in <(String, String)>[
        ('source', "TEXT NOT NULL DEFAULT 'manual'"),
        ('session_id', 'TEXT'),
      ]) {
        await _addColumnIfMissing(
          database,
          table: 'body_progress_photos',
          column: column.$1,
          definition: column.$2,
        );
      }
      for (final column in <(String, String)>[
        ('captured_on', "TEXT NOT NULL DEFAULT ''"),
        ('accuracy', 'REAL'),
        ('source_type', "TEXT NOT NULL DEFAULT 'freeWorkout'"),
      ]) {
        await _addColumnIfMissing(
          database,
          table: 'form_pose_snapshots',
          column: column.$1,
          definition: column.$2,
        );
      }
      // Existing rows predate the day key. Backfill from the capture time so
      // the one-per-day index has a value to work with.
      await database.execute(
        "UPDATE form_pose_snapshots SET captured_on = "
        "strftime('%Y-%m-%d', captured_at / 1000, 'unixepoch', 'localtime') "
        "WHERE captured_on = ''",
      );
      // Version 7 stored one row per session, so a day with several workouts
      // now holds duplicates. Keep the earliest, which matches the rule the
      // automatic capture follows, or the unique index below cannot be built
      // and the upgrade would fail the app on launch.
      await database.execute('''
        DELETE FROM form_pose_snapshots
        WHERE rowid NOT IN (
          SELECT MIN(rowid) FROM form_pose_snapshots GROUP BY captured_on
        )
      ''');
      await database.execute(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_form_pose_one_per_day '
        "ON form_pose_snapshots(captured_on) WHERE captured_on <> ''",
      );
    }
  }

  Future<void> _addColumnIfMissing(
    Database database, {
    required String table,
    required String column,
    required String definition,
  }) async {
    final tables = await database.query(
      'sqlite_master',
      columns: ['name'],
      where: 'type = ? AND name = ?',
      whereArgs: ['table', table],
      limit: 1,
    );
    if (tables.isEmpty) return;
    final columns = await database.rawQuery('PRAGMA table_info($table)');
    if (columns.any((entry) => entry['name'] == column)) return;
    await database.execute('ALTER TABLE $table ADD COLUMN $column $definition');
  }

  Future<void> _createChallengeSchema(Database database) async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS challenges (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL CHECK(type IN ('sevenDay', 'weekly', 'cumulative')),
        status TEXT NOT NULL CHECK(status IN ('active', 'completed', 'ended', 'cancelled')),
        started_at INTEGER NOT NULL,
        ends_at INTEGER NOT NULL,
        target_reps INTEGER NOT NULL DEFAULT 0 CHECK(target_reps >= 0),
        daily_goals TEXT NOT NULL DEFAULT '[]',
        weekdays TEXT NOT NULL DEFAULT '[]',
        notification_enabled INTEGER NOT NULL DEFAULT 0 CHECK(notification_enabled IN (0, 1)),
        created_at INTEGER NOT NULL
      )
    ''');
    await database.execute('''
      CREATE UNIQUE INDEX IF NOT EXISTS idx_one_active_challenge
      ON challenges(status) WHERE status = 'active'
    ''');
  }

  /// Body Progress photos and Form Progress representative poses.
  ///
  /// Every exercise database shares this class, so both tables exist in each
  /// file. Body Progress rows are written only through the shared squat
  /// database; Form Progress rows stay next to the session they describe.
  Future<void> _createProgressSchema(Database database) async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS body_progress_photos (
        id TEXT PRIMARY KEY,
        captured_at INTEGER NOT NULL,
        captured_on TEXT NOT NULL,
        body_view TEXT NOT NULL CHECK(body_view IN ('front', 'side', 'back')),
        image_file TEXT NOT NULL,
        image_width INTEGER NOT NULL DEFAULT 0,
        image_height INTEGER NOT NULL DEFAULT 0,
        source TEXT NOT NULL DEFAULT 'manual' CHECK(source IN ('auto', 'manual')),
        session_id TEXT,
        created_at INTEGER NOT NULL,
        UNIQUE(captured_on, body_view)
      )
    ''');
    await database.execute(
      'CREATE INDEX IF NOT EXISTS idx_body_progress_captured_at '
      'ON body_progress_photos(captured_at)',
    );
    await database.execute('''
      CREATE TABLE IF NOT EXISTS form_pose_snapshots (
        session_id TEXT PRIMARY KEY REFERENCES workout_sessions(id) ON DELETE CASCADE,
        rep_id TEXT,
        captured_at INTEGER NOT NULL,
        captured_on TEXT NOT NULL DEFAULT '',
        form_score REAL,
        accuracy REAL,
        primary_issue TEXT,
        landmarks TEXT NOT NULL,
        source_width INTEGER NOT NULL DEFAULT 0,
        source_height INTEGER NOT NULL DEFAULT 0,
        mirrored INTEGER NOT NULL DEFAULT 0 CHECK(mirrored IN (0, 1)),
        source_type TEXT NOT NULL DEFAULT 'freeWorkout',
        created_at INTEGER NOT NULL
      )
    ''');
    await database.execute(
      'CREATE INDEX IF NOT EXISTS idx_form_pose_captured_at '
      'ON form_pose_snapshots(captured_at)',
    );
    // One representative pose per calendar day. The automatic capture relies on
    // this to stay idempotent across repeated sessions on the same day.
    await database.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_form_pose_one_per_day '
      "ON form_pose_snapshots(captured_on) WHERE captured_on <> ''",
    );
  }

  Future<void> _createLegacyArchiveSchema(Database database) async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS legacy_import_archive (
        id TEXT PRIMARY KEY,
        exercise_type TEXT NOT NULL,
        source_key TEXT NOT NULL,
        source_payload TEXT NOT NULL,
        imported_at INTEGER NOT NULL
      )
    ''');
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
