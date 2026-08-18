import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:motionfit_squat/core/diagnostics/crash_reporting_service.dart';
import 'package:motionfit_squat/features/settings/domain/reminder_schedule.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

enum NotificationPermissionResult {
  granted,
  denied,
  permanentlyDenied,
  unavailable,
}

enum ChallengeNotificationNamespace {
  squat(4200),
  pushup(4210),
  plank(4220);

  const ChallengeNotificationNamespace(this.baseId);

  final int baseId;

  String get payload => 'motionfit://challenge/$name';
}

class NotificationService {
  NotificationService({
    FlutterLocalNotificationsPlugin? plugin,
    CrashReportingService? crashReporting,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       _crashReporting = crashReporting;

  static const _channelId = 'motionfit_workout_reminders';
  static const _channelName = 'Workout reminders';
  static const _channelDescription = 'MotionFit workout reminders';
  static const _notificationBaseId = 4100;
  static const _streakRiskNotificationId = 4300;

  final FlutterLocalNotificationsPlugin _plugin;
  final CrashReportingService? _crashReporting;
  Future<void>? _initialization;
  bool _initialized = false;
  bool _timezoneDataInitialized = false;
  String? _timezoneIdentifier;
  int? _timezoneOffsetMinutes;

  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;
    final pending = _initialization;
    if (pending != null) return pending;

    final initialization = _initialize();
    _initialization = initialization;
    try {
      await initialization;
    } finally {
      if (identical(_initialization, initialization)) {
        _initialization = null;
      }
    }
  }

  Future<void> _initialize() async {
    _initializeTimezoneData();
    await _refreshTimezone();
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('ic_notification'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(settings: settings);
    _initialized = true;
  }

  Future<bool> refreshTimezone() async {
    _initializeTimezoneData();
    return _refreshTimezone();
  }

  Future<bool> _refreshTimezone() async {
    final info = await FlutterTimezone.getLocalTimezone();
    try {
      timezone.setLocalLocation(timezone.getLocation(info.identifier));
    } on ArgumentError {
      timezone.setLocalLocation(timezone.UTC);
    }
    final offsetMinutes = timezone.TZDateTime.now(
      timezone.local,
    ).timeZoneOffset.inMinutes;
    final changed =
        info.identifier != _timezoneIdentifier ||
        offsetMinutes != _timezoneOffsetMinutes;
    _timezoneIdentifier = info.identifier;
    _timezoneOffsetMinutes = offsetMinutes;
    return changed;
  }

  Future<NotificationPermissionResult> requestPermission() async {
    unawaited(
      _crashReporting?.setCustomKey('notification_state', 'requesting'),
    );
    unawaited(_crashReporting?.log('reminder_prompt_started'));
    try {
      await initialize();
      final result = await _requestPlatformPermission();
      unawaited(
        _crashReporting?.setCustomKey(
          'notification_state',
          'permission_${result.name}',
        ),
      );
      return result;
    } on Object catch (error, stackTrace) {
      unawaited(
        _crashReporting?.recordNonFatal(
          error,
          stackTrace,
          reason: 'notification_permission_request',
        ),
      );
      unawaited(
        _crashReporting?.setCustomKey('notification_state', 'unavailable'),
      );
      return NotificationPermissionResult.unavailable;
    } finally {
      unawaited(_crashReporting?.log('reminder_prompt_completed'));
    }
  }

  Future<NotificationPermissionResult> _requestPlatformPermission() async {
    if (Platform.isAndroid) {
      final plugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted = await plugin?.requestNotificationsPermission();
      if (granted == null) return NotificationPermissionResult.unavailable;
      if (!granted) return _deniedPermissionResult();
      return NotificationPermissionResult.granted;
    }
    if (Platform.isIOS) {
      final plugin = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final granted = await plugin?.requestPermissions(
        alert: true,
        badge: false,
        sound: true,
      );
      if (granted == null) return NotificationPermissionResult.unavailable;
      if (granted) return NotificationPermissionResult.granted;
      return _deniedPermissionResult(denialIsPermanent: true);
    }
    return NotificationPermissionResult.unavailable;
  }

  Future<NotificationPermissionResult> permissionStatus() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return NotificationPermissionResult.unavailable;
    }
    try {
      final status = await Permission.notification.status;
      if (status.isGranted || status.isLimited || status.isProvisional) {
        return NotificationPermissionResult.granted;
      }
      if (status.isPermanentlyDenied || status.isRestricted) {
        return NotificationPermissionResult.permanentlyDenied;
      }
      return NotificationPermissionResult.denied;
    } on Object {
      return NotificationPermissionResult.unavailable;
    }
  }

  Future<NotificationPermissionResult> _deniedPermissionResult({
    bool denialIsPermanent = false,
  }) async {
    try {
      final status = await Permission.notification.status;
      if (denialIsPermanent ||
          status.isPermanentlyDenied ||
          status.isRestricted) {
        return NotificationPermissionResult.permanentlyDenied;
      }
    } on Object {
      if (denialIsPermanent) {
        return NotificationPermissionResult.permanentlyDenied;
      }
    }
    return NotificationPermissionResult.denied;
  }

  Future<void> scheduleWeekly({
    required ReminderSchedule schedule,
    required String title,
    required String body,
  }) async {
    await initialize();
    await _scheduleWeekly(schedule: schedule, title: title, body: body);
  }

  Future<void> _scheduleWeekly({
    required ReminderSchedule schedule,
    required String title,
    required String body,
  }) async {
    if (!schedule.enabled) {
      await _plugin.cancel(id: _notificationBaseId + schedule.weekday);
      return;
    }
    // Prefer an exact alarm so the reminder fires at the chosen minute. If the
    // OS denies exact-alarm scheduling, retry with an inexact alarm so the
    // reminder is still delivered (just less precisely) instead of failing.
    // Scheduling with the same ID replaces the existing pending notification;
    // keep the old one intact if both scheduling attempts fail.
    try {
      await _zonedSchedule(
        schedule: schedule,
        title: title,
        body: body,
        scheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } on PlatformException {
      await _zonedSchedule(
        schedule: schedule,
        title: title,
        body: body,
        scheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  Future<void> _zonedSchedule({
    required ReminderSchedule schedule,
    required String title,
    required String body,
    required AndroidScheduleMode scheduleMode,
  }) {
    return _plugin.zonedSchedule(
      id: _notificationBaseId + schedule.weekday,
      title: title,
      body: body,
      scheduledDate: _nextOccurrence(schedule),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBanner: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: scheduleMode,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: 'motionfit://workout',
    );
  }

  Future<void> rescheduleAll({
    required List<ReminderSchedule> schedules,
    required String title,
    required String body,
  }) async {
    await initialize();
    await _refreshTimezone();
    for (final schedule in schedules) {
      await _scheduleWeekly(schedule: schedule, title: title, body: body);
    }
  }

  Future<void> cancelWeekday(int weekday) async {
    await initialize();
    await _plugin.cancel(id: _notificationBaseId + weekday);
  }

  Future<void> syncStreakRiskReminder({
    required bool enabled,
    required int currentStreak,
    required bool streakAtRisk,
    required String title,
    required String body,
  }) async {
    await initialize();
    if (!enabled || currentStreak <= 0) {
      await _plugin.cancel(id: _streakRiskNotificationId);
      return;
    }

    final now = timezone.TZDateTime.now(timezone.local);
    final dayOffset = streakAtRisk ? 0 : 1;
    final scheduledDate = timezone.TZDateTime(
      timezone.local,
      now.year,
      now.month,
      now.day + dayOffset,
      20,
    );
    if (!scheduledDate.isAfter(now)) {
      await _plugin.cancel(id: _streakRiskNotificationId);
      return;
    }

    Future<void> schedule(AndroidScheduleMode mode) => _plugin.zonedSchedule(
      id: _streakRiskNotificationId,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBanner: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: mode,
      payload: 'motionfit://workout',
    );
    try {
      // The plugin replaces a pending notification with the same ID, avoiding
      // a cancel-then-schedule gap if the platform rejects both attempts.
      await schedule(AndroidScheduleMode.exactAllowWhileIdle);
    } on PlatformException {
      await schedule(AndroidScheduleMode.inexactAllowWhileIdle);
    }
  }

  Future<void> cancelStreakRiskReminder() async {
    await initialize();
    await _plugin.cancel(id: _streakRiskNotificationId);
  }

  Future<void> scheduleChallengeReminder({
    required String title,
    required String body,
    List<int> weekdays = const [],
    ChallengeNotificationNamespace namespace =
        ChallengeNotificationNamespace.squat,
  }) async {
    await initialize();
    await cancelChallengeReminder(namespace: namespace);
    if (weekdays.isEmpty) {
      await _scheduleChallengeNotification(
        id: namespace.baseId,
        date: _nextDailyAtEight(),
        match: DateTimeComponents.time,
        title: title,
        body: body,
        payload: namespace.payload,
      );
      return;
    }
    for (final weekday in weekdays) {
      await _scheduleChallengeNotification(
        id: namespace.baseId + weekday,
        date: _nextOccurrence(
          ReminderSchedule(
            id: weekday,
            weekday: weekday,
            enabled: true,
            hour: 20,
            minute: 0,
          ),
        ),
        match: DateTimeComponents.dayOfWeekAndTime,
        title: title,
        body: body,
        payload: namespace.payload,
      );
    }
  }

  Future<void> cancelChallengeReminder({
    ChallengeNotificationNamespace namespace =
        ChallengeNotificationNamespace.squat,
  }) async {
    await initialize();
    for (var id = namespace.baseId; id <= namespace.baseId + 7; id++) {
      await _plugin.cancel(id: id);
    }
  }

  Future<void> _scheduleChallengeNotification({
    required int id,
    required timezone.TZDateTime date,
    required DateTimeComponents match,
    required String title,
    required String body,
    required String payload,
  }) async {
    Future<void> schedule(AndroidScheduleMode mode) => _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: date,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBanner: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: mode,
      matchDateTimeComponents: match,
      payload: payload,
    );
    try {
      await schedule(AndroidScheduleMode.exactAllowWhileIdle);
    } on PlatformException {
      await schedule(AndroidScheduleMode.inexactAllowWhileIdle);
    }
  }

  timezone.TZDateTime _nextDailyAtEight() {
    final now = timezone.TZDateTime.now(timezone.local);
    var result = timezone.TZDateTime(
      timezone.local,
      now.year,
      now.month,
      now.day,
      20,
    );
    if (!result.isAfter(now)) result = result.add(const Duration(days: 1));
    return result;
  }

  timezone.TZDateTime nextOccurrence(ReminderSchedule schedule) {
    _initializeTimezoneData();
    return _nextOccurrence(schedule);
  }

  void _initializeTimezoneData() {
    if (_timezoneDataInitialized) return;
    timezone_data.initializeTimeZones();
    timezone.setLocalLocation(timezone.UTC);
    _timezoneDataInitialized = true;
  }

  timezone.TZDateTime _nextOccurrence(ReminderSchedule schedule) {
    final now = timezone.TZDateTime.now(timezone.local);
    var result = timezone.TZDateTime(
      timezone.local,
      now.year,
      now.month,
      now.day,
      schedule.hour,
      schedule.minute,
    );
    while (result.weekday != schedule.weekday || !result.isAfter(now)) {
      result = timezone.TZDateTime(
        timezone.local,
        result.year,
        result.month,
        result.day + 1,
        schedule.hour,
        schedule.minute,
      );
    }
    return result;
  }
}
