import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:motionfit_squat/app/localization/generated/app_localizations.dart';
import 'package:motionfit_squat/core/database/app_database.dart';
import 'package:motionfit_squat/core/notifications/notification_service.dart';
import 'package:motionfit_squat/features/plank/workout/domain/models/workout_plan.dart'
    as plank;
import 'package:motionfit_squat/features/pushup/domain/models/workout_plan.dart'
    as pushup;
import 'package:motionfit_squat/features/settings/data/preferences_service.dart';
import 'package:motionfit_squat/features/settings/domain/reminder_schedule.dart';
import 'package:motionfit_squat/features/settings/domain/user_preferences.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_plan.dart'
    as squat;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

typedef LegacyValueReader = Future<Map<String, String>> Function();

class LegacyCapacitorMigration {
  LegacyCapacitorMigration({
    required this.squatDatabase,
    required this.pushupDatabase,
    required this.plankDatabase,
    required this.preferencesService,
    required this.notificationService,
    SharedPreferencesAsync? migrationPreferences,
    LegacyValueReader? valueReader,
  }) : _migrationPreferences = migrationPreferences ?? SharedPreferencesAsync(),
       _valueReader = valueReader ?? _readNativeValues;

  static const _channel = MethodChannel(
    'fit.motionfit.app/legacy_capacitor_storage',
  );
  static const _migrationMarker = 'legacy_capacitor_migration_v1';
  static const _noDataAttemptKey = 'legacy_capacitor_migration_empty_attempts';

  static const _historyKeys = <String, String>{
    'squat_history_v1': 'squat',
    'pushup_history_v1': 'pushup',
    'plank_history_v1': 'plank',
    'lunge_history_v1': 'lunge',
    'crunch_history_v1': 'crunch',
    'side_lateral_raise_history_v1': 'side-lateral-raise',
  };

  final AppDatabase squatDatabase;
  final AppDatabase pushupDatabase;
  final AppDatabase plankDatabase;
  final PreferencesService preferencesService;
  final NotificationService notificationService;
  final SharedPreferencesAsync _migrationPreferences;
  final LegacyValueReader _valueReader;

  Future<void> run() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    if (await _migrationPreferences.getString(_migrationMarker) != null) {
      return;
    }

    final values = await _valueReader();
    final emptyAttempts = values.isEmpty
        ? (await _migrationPreferences.getInt(_noDataAttemptKey) ?? 0) + 1
        : 0;
    if (values.isEmpty) {
      await _migrationPreferences.setInt(_noDataAttemptKey, emptyAttempts);
    }
    final databases = <String, Database>{
      'squat': await squatDatabase.database,
      'pushup': await pushupDatabase.database,
      'plank': await plankDatabase.database,
    };
    final importedAt = DateTime.now().millisecondsSinceEpoch;

    await _archiveAllValues(
      database: databases['squat']!,
      values: values,
      importedAt: importedAt,
    );
    final importedSessions = await _importWorkoutHistory(
      databases: databases,
      values: values,
      importedAt: importedAt,
    );
    final preferences = await _importPreferences(values, databases);
    final importedReminders = await _importReminders(
      values['motionfit.reminders.v1'],
      databases['squat']!,
    );

    // Capacitor used different request IDs. Cancel those before recreating
    // schedules under the existing notification channel and Flutter IDs.
    await notificationService.cancelLegacyCapacitorReminders();
    final schedules = await _loadReminders(databases['squat']!);
    if (schedules.any((schedule) => schedule.enabled)) {
      final locale = _localeFor(preferences.locale);
      final copy = lookupAppLocalizations(locale);
      await notificationService.rescheduleAll(
        schedules: schedules,
        title: copy.notificationReminderTitle,
        body: copy.notificationReminderBody,
      );
    }

    // An empty first read may be a transient WebView startup condition. Retry
    // on later launches before accepting that this is a fresh installation.
    if (values.isEmpty && emptyAttempts < 3) return;
    await _migrationPreferences.setString(
      _migrationMarker,
      jsonEncode({
        'version': 1,
        'completedAt': importedAt,
        'legacyValueCount': values.length,
        'result': values.isEmpty ? 'noData' : 'imported',
        'importedSessions': importedSessions,
        'importedReminders': importedReminders,
      }),
    );
  }

  static Future<Map<String, String>> _readNativeValues() async {
    final result = await _channel.invokeMapMethod<String, dynamic>(
      'readAllValues',
    );
    if (result == null) return const {};
    return {
      for (final entry in result.entries)
        if (entry.value is String) entry.key: entry.value! as String,
    };
  }

  Future<void> _archiveAllValues({
    required Database database,
    required Map<String, String> values,
    required int importedAt,
  }) async {
    await database.transaction((transaction) async {
      for (final entry in values.entries) {
        await transaction.insert('legacy_import_archive', {
          'id': 'legacy_value_${_safeId(entry.key)}',
          'exercise_type': 'app',
          'source_key': entry.key,
          'source_payload': entry.value,
          'imported_at': importedAt,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    });
  }

  Future<int> _importWorkoutHistory({
    required Map<String, Database> databases,
    required Map<String, String> values,
    required int importedAt,
  }) async {
    final records = <_LegacyWorkoutRecord>[];
    final seen = <String>{};
    final consolidated = _decodeList(values['motionfit.workoutLogs.v1']);
    for (final payload in consolidated) {
      final exercise = '${payload['exerciseType'] ?? ''}'.trim();
      if (exercise.isEmpty) continue;
      final record = _LegacyWorkoutRecord(
        exercise: exercise,
        sourceKey: 'motionfit.workoutLogs.v1',
        payload: payload,
      );
      records.add(record);
      seen.add(record.dedupeKey);
    }
    for (final entry in _historyKeys.entries) {
      for (final payload in _decodeList(values[entry.key])) {
        final record = _LegacyWorkoutRecord(
          exercise: entry.value,
          sourceKey: entry.key,
          payload: payload,
        );
        if (seen.add(record.dedupeKey)) records.add(record);
      }
    }

    var imported = 0;
    for (final record in records) {
      final database = databases[record.exercise] ?? databases['squat']!;
      await database.insert('legacy_import_archive', {
        'id': record.archiveId,
        'exercise_type': record.exercise,
        'source_key': record.sourceKey,
        'source_payload': jsonEncode(record.payload),
        'imported_at': importedAt,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
      if (!databases.containsKey(record.exercise)) continue;
      if (await _insertVisibleSession(database, record)) imported += 1;
    }
    return imported;
  }

  Future<bool> _insertVisibleSession(
    Database database,
    _LegacyWorkoutRecord record,
  ) async {
    final payload = record.payload;
    final sessionData = _asMap(payload['sessionData']);
    final endedAt = _timestamp(
      payload['performedAt'] ?? payload['endedAt'] ?? payload['id'],
    );
    if (endedAt == null) return false;

    final duration = _firstInt([
      payload['durationSec'],
      payload['totalSeconds'],
      payload['totalWorkoutSeconds'],
      payload['totalActiveSeconds'],
      payload['totalPlankSeconds'],
      payload['totalHoldSeconds'],
      _millisecondsToSeconds(payload['durationMs']),
    ]);
    final activeDuration = _firstInt([
      payload['activeDurationSec'],
      payload['totalActiveSeconds'],
      payload['totalWorkoutSeconds'],
      payload['totalPlankSeconds'],
      payload['totalHoldSeconds'],
      duration,
    ]);
    final restDuration = _firstInt([
      payload['restDurationSec'],
      payload['totalRestSeconds'],
      payload['restSeconds'],
    ]);
    final targetSets = _positiveInt(
      sessionData['targetSets'] ?? payload['targetSets'],
      fallback: 1,
      maximum: 20,
    );
    final completedSets = _positiveInt(
      sessionData['completedSets'] ?? payload['completedSets'],
      fallback: 1,
      maximum: 20,
    );
    var totalReps = _firstInt([
      payload['reps'],
      sessionData['totalReps'],
      payload['totalReps'],
      payload['actualCount'],
    ]);
    if (record.exercise == 'plank' && totalReps <= 0 && activeDuration > 0) {
      totalReps = completedSets;
    }
    if (totalReps <= 0) return false;
    final targetReps = _positiveInt(
      sessionData['targetReps'] ??
          sessionData['targetDurationSec'] ??
          payload['targetReps'] ??
          payload['targetDurationSeconds'] ??
          (record.exercise == 'plank' ? activeDuration : totalReps),
      fallback: totalReps,
      maximum: record.exercise == 'plank' ? 300 : 100,
    );
    final totalDuration = duration > 0
        ? duration
        : activeDuration + restDuration;
    final startedAt =
        _timestamp(payload['startedAt']) ??
        endedAt.subtract(Duration(seconds: totalDuration));
    final completed = '${payload['status'] ?? 'completed'}' == 'completed';
    final sessionId = record.sessionId;
    final setId = '${sessionId}_set_1';

    return database.transaction((transaction) async {
      final existing = Sqflite.firstIntValue(
        await transaction.rawQuery(
          'SELECT COUNT(*) FROM workout_sessions WHERE id = ?',
          [sessionId],
        ),
      );
      if ((existing ?? 0) > 0) return false;
      await transaction.insert('workout_sessions', {
        'id': sessionId,
        'started_at': startedAt.millisecondsSinceEpoch,
        'ended_at': endedAt.millisecondsSinceEpoch,
        'planned_set_count': targetSets,
        'planned_reps_per_set': targetReps,
        'planned_rest_seconds': _nonNegativeInt(
          payload['restSeconds'],
          fallback: 0,
          maximum: 600,
        ),
        'completed_set_count': completedSets,
        'total_reps': totalReps,
        'active_duration_seconds': activeDuration,
        'rest_duration_seconds': restDuration,
        'total_duration_seconds': totalDuration,
        'average_rep_duration_milliseconds': activeDuration > 0
            ? (activeDuration * 1000 / totalReps).round()
            : 0,
        'completed': completed ? 1 : 0,
        'interrupted': completed ? 0 : 1,
        'created_at': endedAt.millisecondsSinceEpoch,
        'analytics_session_id': null,
        'video_path': null,
        'video_duration_milliseconds': null,
      });
      await transaction.insert('workout_sets', {
        'id': setId,
        'session_id': sessionId,
        'set_index': 1,
        'started_at': startedAt.millisecondsSinceEpoch,
        'ended_at': endedAt.millisecondsSinceEpoch,
        'target_reps': totalReps,
        'completed_reps': totalReps,
        'active_duration_seconds': activeDuration,
        'rest_duration_after_seconds': restDuration,
      });
      return true;
    });
  }

  Future<UserPreferences> _importPreferences(
    Map<String, String> values,
    Map<String, Database> databases,
  ) async {
    final existing = await preferencesService.load();
    if (values.isEmpty || await preferencesService.hasSavedPreferences()) {
      return existing;
    }

    final reminder = _decodeMap(values['motionfit.reminders.v1']);
    final freemium = _decodeMap(values['motionfit.freemium.v2']);
    final ads = _asMap(freemium['ads']);
    final setup = <String, Map<String, dynamic>>{
      for (final exercise in ['squat', 'pushup', 'plank'])
        exercise: _legacySetup(values, exercise),
    };
    final locale = _normalizeLocale(values['locale']);
    final voiceValue = [
      setup['squat']?['feedbackVoiceEnabled'],
      setup['pushup']?['feedbackVoiceEnabled'],
      setup['plank']?['feedbackVoiceEnabled'],
    ].whereType<bool>().firstOrNull;
    final now = DateTime.now();
    final squatPlan = squat.WorkoutPlan(
      id: 'legacy_import',
      setCount: _positiveInt(
        setup['squat']?['targetSets'],
        fallback: 1,
        maximum: 20,
      ),
      targetRepsPerSet: _positiveInt(
        setup['squat']?['targetReps'],
        fallback: 5,
        maximum: 100,
      ),
      restDurationSeconds: _nonNegativeInt(
        setup['squat']?['restSeconds'],
        fallback: 15,
        maximum: 600,
      ),
      createdAt: now,
      updatedAt: now,
    ).normalized();
    final pushupPlan = pushup.WorkoutPlan(
      id: 'legacy_import',
      setCount: _positiveInt(
        setup['pushup']?['targetSets'],
        fallback: 1,
        maximum: 20,
      ),
      targetRepsPerSet: _positiveInt(
        setup['pushup']?['targetReps'],
        fallback: 5,
        maximum: 100,
      ),
      restDurationSeconds: _nonNegativeInt(
        setup['pushup']?['restSeconds'],
        fallback: 15,
        maximum: 600,
      ),
      createdAt: now,
      updatedAt: now,
    ).normalized();
    final plankSeconds = _firstInt([
      setup['plank']?['targetDurationSeconds'],
      _minutesToSeconds(setup['plank']?['workoutMinutes']),
      30,
    ]);
    final plankPlan = plank.WorkoutPlan(
      id: 'legacy_import',
      setCount: _positiveInt(
        setup['plank']?['targetSets'],
        fallback: 1,
        maximum: 20,
      ),
      targetRepsPerSet: plankSeconds.clamp(1, 300),
      restDurationSeconds: _nonNegativeInt(
        setup['plank']?['restSeconds'],
        fallback: 30,
        maximum: 600,
      ),
      createdAt: now,
      updatedAt: now,
    ).normalized();
    final installedAt =
        _timestamp(freemium['createdAt']) ?? existing.installedAt;
    final lastInterstitial = _timestamp(ads['lastInterstitialShownAt']);
    final migrated = existing.copyWith(
      locale: locale,
      useSystemLocale: locale == null,
      voiceCoachingEnabled: voiceValue,
      onboardingCompleted: _bool(values['firstWorkoutOnboardingSeen']),
      cameraGuideSeen: _bool(values['motionfit.cameraSetupSeen.squat']),
      pushupCameraGuideSeen: _bool(values['motionfit.cameraSetupSeen.pushup']),
      plankCameraGuideSeen: _bool(values['motionfit.cameraSetupSeen.plank']),
      installedAt: installedAt,
      lastInterstitialShownAt: lastInterstitial,
      postWorkoutReminderPromptedAtWorkoutCount:
          reminder['firstWorkoutPromptSeen'] == true ? 1 : 0,
      postWorkoutReminderDeferred:
          reminder['firstWorkoutPromptDismissed'] == true,
      lastWorkoutPlan: squatPlan,
      pushupLastWorkoutPlan: pushupPlan,
      plankLastWorkoutPlan: plankPlan,
    );
    await preferencesService.save(migrated);
    await _insertPlanIfEmpty(databases['squat']!, squatPlan.toMap());
    await _insertPlanIfEmpty(databases['pushup']!, pushupPlan.toMap());
    await _insertPlanIfEmpty(databases['plank']!, plankPlan.toMap());
    return migrated;
  }

  Future<void> _insertPlanIfEmpty(
    Database database,
    Map<String, Object?> plan,
  ) async {
    final count = Sqflite.firstIntValue(
      await database.rawQuery('SELECT COUNT(*) FROM workout_plans'),
    );
    if ((count ?? 0) == 0) await database.insert('workout_plans', plan);
  }

  Future<int> _importReminders(String? source, Database database) async {
    if (source == null || source.isEmpty) return 0;
    final existing = Sqflite.firstIntValue(
      await database.rawQuery('SELECT COUNT(*) FROM reminder_schedules'),
    );
    if ((existing ?? 0) > 0) return 0;
    final reminder = _decodeMap(source);
    final legacyWeekdays =
        (reminder['weekdays'] as List?)
            ?.whereType<num>()
            .map((value) => value.toInt())
            .toSet() ??
        const <int>{};
    final parts = '${reminder['time'] ?? '19:00'}'.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 19 : 19;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    var imported = 0;
    for (var weekday = 1; weekday <= 7; weekday += 1) {
      final legacyWeekday = weekday == DateTime.sunday ? 1 : weekday + 1;
      final schedule = ReminderSchedule(
        id: weekday,
        weekday: weekday,
        enabled: legacyWeekdays.contains(legacyWeekday),
        hour: hour.clamp(0, 23),
        minute: minute.clamp(0, 59),
      );
      await database.insert(
        'reminder_schedules',
        schedule.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      if (schedule.enabled) imported += 1;
    }
    return imported;
  }

  Future<List<ReminderSchedule>> _loadReminders(Database database) async {
    final rows = await database.query(
      'reminder_schedules',
      orderBy: 'weekday ASC',
    );
    if (rows.isEmpty) return ReminderSchedule.defaults();
    return rows.map(ReminderSchedule.fromMap).toList(growable: false);
  }

  static Map<String, dynamic> _legacySetup(
    Map<String, String> values,
    String exercise,
  ) {
    final setup = _decodeMap(values['motionfit.lastSetup.$exercise']);
    Object? scalar(String suffix) => values['${exercise}_$suffix'];
    setup.putIfAbsent('targetSets', () {
      if (exercise == 'plank') return scalar('targetReps');
      return scalar('targetSets');
    });
    setup.putIfAbsent('targetReps', () => scalar('targetReps'));
    setup.putIfAbsent('workoutMinutes', () => scalar('workoutMinutes'));
    setup.putIfAbsent('restSeconds', () => scalar('restSeconds'));
    setup.putIfAbsent(
      'feedbackVoiceEnabled',
      () => _nullableBool(scalar('feedbackVoice')),
    );
    return setup;
  }

  static Locale _localeFor(String? locale) {
    if (locale == 'zh_Hant') {
      return const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant');
    }
    return Locale(locale ?? 'en');
  }

  static String? _normalizeLocale(String? raw) {
    if (raw == null) return null;
    final value = raw.trim().replaceAll('-', '_');
    if (value == 'zh_Hant' || value == 'zh_TW') return 'zh_Hant';
    final language = value.split('_').first;
    return UserPreferences.supportedLocales.contains(language)
        ? language
        : null;
  }

  static Map<String, dynamic> _decodeMap(String? source) {
    if (source == null || source.isEmpty) return <String, dynamic>{};
    try {
      return _asMap(jsonDecode(source));
    } on Object {
      return <String, dynamic>{};
    }
  }

  static List<Map<String, dynamic>> _decodeList(String? source) {
    if (source == null || source.isEmpty) return const [];
    try {
      final decoded = jsonDecode(source);
      if (decoded is! List) return const [];
      return decoded.map(_asMap).where((value) => value.isNotEmpty).toList();
    } on Object {
      return const [];
    }
  }

  static Map<String, dynamic> _asMap(Object? value) => value is Map
      ? value.map((key, value) => MapEntry('$key', value))
      : <String, dynamic>{};

  static DateTime? _timestamp(Object? value) {
    if (value is num && value.isFinite) {
      return DateTime.fromMillisecondsSinceEpoch(value.round());
    }
    final text = '$value'.trim();
    final numeric = int.tryParse(text);
    if (numeric != null && numeric > 100000000000) {
      return DateTime.fromMillisecondsSinceEpoch(numeric);
    }
    return DateTime.tryParse(text);
  }

  static int _positiveInt(
    Object? value, {
    required int fallback,
    required int maximum,
  }) {
    final parsed = value is num ? value.round() : int.tryParse('$value');
    return (parsed ?? fallback).clamp(1, maximum);
  }

  static int _nonNegativeInt(
    Object? value, {
    required int fallback,
    required int maximum,
  }) {
    final parsed = value is num ? value.round() : int.tryParse('$value');
    return (parsed ?? fallback).clamp(0, maximum);
  }

  static int _firstInt(List<Object?> values) {
    for (final value in values) {
      final parsed = value is num ? value.round() : int.tryParse('$value');
      if (parsed != null && parsed >= 0) return parsed;
    }
    return 0;
  }

  static int? _millisecondsToSeconds(Object? value) {
    final milliseconds = value is num ? value : num.tryParse('$value');
    return milliseconds == null ? null : (milliseconds / 1000).round();
  }

  static int? _minutesToSeconds(Object? value) {
    final minutes = value is num ? value : num.tryParse('$value');
    return minutes == null ? null : (minutes * 60).round();
  }

  static bool _bool(Object? value) => _nullableBool(value) ?? false;

  static bool? _nullableBool(Object? value) {
    if (value is bool) return value;
    final normalized = '$value'.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
    return null;
  }

  static String _safeId(Object? value) {
    final normalized = '$value'.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    return normalized.isEmpty ? 'unknown' : normalized;
  }
}

class _LegacyWorkoutRecord {
  const _LegacyWorkoutRecord({
    required this.exercise,
    required this.sourceKey,
    required this.payload,
  });

  final String exercise;
  final String sourceKey;
  final Map<String, dynamic> payload;

  String get sourceId =>
      '${payload['sessionId'] ?? payload['logId'] ?? payload['id'] ?? payload['performedAt'] ?? payload['endedAt'] ?? ''}';

  String get dedupeKey =>
      '$exercise:${LegacyCapacitorMigration._safeId(sourceId)}';

  String get sessionId =>
      'legacy_${LegacyCapacitorMigration._safeId(exercise)}_${LegacyCapacitorMigration._safeId(sourceId)}';

  String get archiveId =>
      'legacy_archive_${LegacyCapacitorMigration._safeId(sourceKey)}_${LegacyCapacitorMigration._safeId(exercise)}_${LegacyCapacitorMigration._safeId(sourceId)}';
}
