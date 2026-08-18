import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motionfit_squat/core/notifications/notification_service.dart';
import 'package:motionfit_squat/core/providers.dart';
import 'package:motionfit_squat/features/settings/application/preferences_controller.dart';
import 'package:motionfit_squat/features/settings/domain/reminder_schedule.dart';

final reminderControllerProvider =
    AsyncNotifierProvider<ReminderController, List<ReminderSchedule>>(
      ReminderController.new,
    );

class ReminderController extends AsyncNotifier<List<ReminderSchedule>> {
  Future<void> _pendingOperation = Future.value();

  @override
  Future<List<ReminderSchedule>> build() =>
      ref.watch(workoutRepositoryProvider).loadReminders();

  Future<NotificationPermissionResult> setEnabled({
    required int weekday,
    required bool enabled,
    required String title,
    required String body,
    String source = 'settings',
  }) => _runExclusive(() async {
    if (enabled) {
      final permission = await _requestPermission(source: source);
      if (permission != NotificationPermissionResult.granted) {
        return permission;
      }
    }
    final schedules = _current();
    final index = schedules.indexWhere((value) => value.weekday == weekday);
    if (index < 0) return NotificationPermissionResult.unavailable;
    final previous = schedules[index];
    final updated = previous.copyWith(enabled: enabled);
    try {
      await _saveAndSchedule(
        previous: previous,
        updated: updated,
        title: title,
        body: body,
      );
    } on Object {
      ref.read(analyticsServiceProvider).reminderScheduleFailed(source: source);
      rethrow;
    }
    schedules[index] = updated;
    state = AsyncData(List.unmodifiable(schedules));
    if (!schedules.any((schedule) => schedule.enabled)) {
      try {
        await ref.read(notificationServiceProvider).cancelStreakRiskReminder();
      } on Object {
        // Retry cleanup during the next environment refresh.
      }
    }
    if (enabled && !previous.enabled) {
      ref.read(analyticsServiceProvider)
        ..reminderScheduled(source: source)
        ..reminderEnabled(
          weekday: updated.weekday,
          hour: updated.hour,
          minute: updated.minute,
          source: source,
        );
    } else if (!enabled && previous.enabled) {
      ref.read(analyticsServiceProvider).reminderDisabled(source: source);
    }
    return NotificationPermissionResult.granted;
  });

  Future<NotificationPermissionResult> enableEveryDayAtTime({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) => _runExclusive(() async {
    const source = 'post_workout';
    final permission = await _requestPermission(source: source);
    if (permission != NotificationPermissionResult.granted) {
      return permission;
    }

    final previous = _current();
    final updated = previous
        .map(
          (schedule) =>
              schedule.copyWith(enabled: true, hour: hour, minute: minute),
        )
        .toList(growable: false);
    try {
      for (final schedule in updated) {
        await ref.read(workoutRepositoryProvider).saveReminder(schedule);
      }
      await ref
          .read(notificationServiceProvider)
          .rescheduleAll(schedules: updated, title: title, body: body);
    } on Object catch (error, stackTrace) {
      ref.read(analyticsServiceProvider).reminderScheduleFailed(source: source);
      await _restoreSchedules(previous, title: title, body: body);
      Error.throwWithStackTrace(error, stackTrace);
    }
    state = AsyncData(List.unmodifiable(updated));
    ref.read(analyticsServiceProvider)
      ..reminderScheduled(source: source)
      ..reminderEnabled(
        weekday: DateTime.now().weekday,
        hour: hour,
        minute: minute,
        source: source,
      );
    return NotificationPermissionResult.granted;
  });

  Future<void> setTime({
    required int weekday,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) => _runExclusive(
    () => _setTime(
      weekday: weekday,
      hour: hour,
      minute: minute,
      title: title,
      body: body,
    ),
  );

  Future<void> applyTimeToAll({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) => _runExclusive(() async {
    final previous = _current();
    final updated = previous
        .map((value) => value.copyWith(hour: hour, minute: minute))
        .toList(growable: false);
    try {
      for (final schedule in updated) {
        await ref.read(workoutRepositoryProvider).saveReminder(schedule);
      }
      await ref
          .read(notificationServiceProvider)
          .rescheduleAll(schedules: updated, title: title, body: body);
    } on Object catch (error, stackTrace) {
      await _restoreSchedules(previous, title: title, body: body);
      Error.throwWithStackTrace(error, stackTrace);
    }
    state = AsyncData(List.unmodifiable(updated));
  });

  Future<void> copyTime({
    required int fromWeekday,
    required int toWeekday,
    required String title,
    required String body,
  }) => _runExclusive(() async {
    final schedules = _current();
    final source = schedules
        .where((value) => value.weekday == fromWeekday)
        .first;
    await _setTime(
      weekday: toWeekday,
      hour: source.hour,
      minute: source.minute,
      title: title,
      body: body,
    );
  });

  DateTime? nextReminder() {
    final enabled = _current().where((value) => value.enabled).toList();
    if (enabled.isEmpty) return null;
    final service = ref.read(notificationServiceProvider);
    final candidates = enabled.map(service.nextOccurrence).toList()
      ..sort((a, b) => a.compareTo(b));
    return candidates.first;
  }

  Future<void> refreshForEnvironment({
    required String title,
    required String body,
    bool force = false,
    int? currentStreak,
    bool? streakAtRisk,
    String? streakRiskBody,
  }) => _runExclusive(() async {
    final service = ref.read(notificationServiceProvider);
    final recoveredInitialization = !service.isInitialized;
    await service.initialize();
    final changed = await service.refreshTimezone();
    final schedules = _current();
    if (changed || recoveredInitialization || force) {
      await service.rescheduleAll(
        schedules: schedules,
        title: title,
        body: body,
      );
    }
    if (currentStreak != null &&
        streakAtRisk != null &&
        streakRiskBody != null) {
      await service.syncStreakRiskReminder(
        enabled: schedules.any((schedule) => schedule.enabled),
        currentStreak: currentStreak,
        streakAtRisk: streakAtRisk,
        title: title,
        body: streakRiskBody,
      );
    }
  });

  List<ReminderSchedule> _current() => switch (state) {
    AsyncData(:final value) => List.of(value),
    _ => ReminderSchedule.defaults(),
  };

  Future<void> _rememberPermissionResult(
    NotificationPermissionResult result,
  ) async {
    final denied =
        result == NotificationPermissionResult.denied ||
        result == NotificationPermissionResult.permanentlyDenied;
    if (!denied && result != NotificationPermissionResult.granted) return;
    try {
      await ref
          .read(preferencesControllerProvider.notifier)
          .setReminderPermissionDenied(denied);
    } on Object {
      // Reminder scheduling should not fail because eligibility persistence did.
    }
  }

  Future<NotificationPermissionResult> _requestPermission({
    required String source,
  }) async {
    final notifications = ref.read(notificationServiceProvider);
    final analytics = ref.read(analyticsServiceProvider);
    final previouslyDenied = ref
        .read(preferencesControllerProvider)
        .postWorkoutReminderPermissionDenied;
    if (previouslyDenied) {
      final status = await notifications.permissionStatus();
      await _rememberPermissionResult(status);
      analytics.reminderPermissionResult(result: status.name, source: source);
      return status;
    }
    analytics.reminderPermissionRequested(source: source);
    final result = await notifications.requestPermission();
    await _rememberPermissionResult(result);
    analytics.reminderPermissionResult(result: result.name, source: source);
    return result;
  }

  Future<void> _setTime({
    required int weekday,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final schedules = _current();
    final index = schedules.indexWhere((value) => value.weekday == weekday);
    if (index < 0) return;
    final previous = schedules[index];
    final updated = previous.copyWith(hour: hour, minute: minute);
    await _saveAndSchedule(
      previous: previous,
      updated: updated,
      title: title,
      body: body,
    );
    schedules[index] = updated;
    state = AsyncData(List.unmodifiable(schedules));
  }

  Future<void> _saveAndSchedule({
    required ReminderSchedule previous,
    required ReminderSchedule updated,
    required String title,
    required String body,
  }) async {
    try {
      await ref.read(workoutRepositoryProvider).saveReminder(updated);
      await ref
          .read(notificationServiceProvider)
          .scheduleWeekly(schedule: updated, title: title, body: body);
    } on Object catch (error, stackTrace) {
      await _restoreSchedules([previous], title: title, body: body);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> _restoreSchedules(
    List<ReminderSchedule> schedules, {
    required String title,
    required String body,
  }) async {
    for (final schedule in schedules) {
      try {
        await ref.read(workoutRepositoryProvider).saveReminder(schedule);
      } on Object {
        // Continue so the OS schedule is also restored when possible.
      }
    }
    try {
      await ref
          .read(notificationServiceProvider)
          .rescheduleAll(schedules: schedules, title: title, body: body);
    } on Object {
      // The original operation error remains the actionable failure.
    }
  }

  Future<T> _runExclusive<T>(Future<T> Function() operation) async {
    final previous = _pendingOperation;
    final release = Completer<void>();
    _pendingOperation = release.future;
    await previous;
    try {
      return await operation();
    } finally {
      release.complete();
    }
  }
}
