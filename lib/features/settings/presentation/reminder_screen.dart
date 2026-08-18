import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motionfit_squat/app/localization/generated/app_localizations.dart';
import 'package:motionfit_squat/features/exercise/application/combined_workout_metrics.dart';
import 'package:motionfit_squat/core/notifications/notification_service.dart';
import 'package:motionfit_squat/core/providers.dart';
import 'package:motionfit_squat/core/widgets/async_value_view.dart';
import 'package:motionfit_squat/core/widgets/responsive_page.dart';
import 'package:motionfit_squat/features/settings/application/reminder_controller.dart';
import 'package:motionfit_squat/features/settings/domain/reminder_schedule.dart';

class ReminderScreen extends ConsumerStatefulWidget {
  const ReminderScreen({super.key});

  @override
  ConsumerState<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends ConsumerState<ReminderScreen> {
  String? _refreshedLocale;
  bool _actionInProgress = false;

  @override
  void initState() {
    super.initState();
    ref.read(analyticsServiceProvider).screenView('reminder_settings');
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final schedules = ref.watch(reminderControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.reminderTitle)),
      body: SafeArea(
        top: false,
        child: AsyncValueView<List<ReminderSchedule>>(
          value: schedules,
          loadingLabel: localizations.commonLoading,
          errorTitle: localizations.errorGenericTitle,
          errorBody: localizations.errorGenericBody,
          retryLabel: localizations.commonRetry,
          onRetry: () => ref.invalidate(reminderControllerProvider),
          data: (values) {
            _queueEnvironmentRefresh(localizations);
            final enabledSchedules =
                values.where((schedule) => schedule.enabled).toList()
                  ..sort((a, b) => a.weekday.compareTo(b.weekday));
            return ResponsivePage(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 12),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_actionInProgress) ...[
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        semanticsLabel: localizations.commonLoading,
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      localizations.reminderTime,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 10,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final schedule in values)
                              Expanded(
                                child: _WeekdayControl(
                                  dayLabel: _weekdayShort(
                                    localizations,
                                    schedule.weekday,
                                  ),
                                  selected: schedule.enabled,
                                  enabled: !_actionInProgress,
                                  onToggle: () =>
                                      _setEnabled(schedule, !schedule.enabled),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (enabledSchedules.isEmpty)
                      Card(
                        child: ListTile(
                          minTileHeight: 60,
                          leading: const Icon(Icons.schedule_rounded),
                          title: Text(localizations.reminderTime),
                          subtitle: Text(localizations.reminderNoneScheduled),
                        ),
                      )
                    else
                      Card(
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            for (
                              var i = 0;
                              i < enabledSchedules.length;
                              i++
                            ) ...[
                              if (i > 0) const Divider(height: 1),
                              ListTile(
                                minTileHeight: 64,
                                enabled: !_actionInProgress,
                                leading: const Icon(Icons.schedule_rounded),
                                title: Text(
                                  _weekdayFull(
                                    localizations,
                                    enabledSchedules[i].weekday,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _formatTime(enabledSchedules[i]),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.chevron_right_rounded),
                                  ],
                                ),
                                onTap: () =>
                                    _pickTimeForDay(enabledSchedules[i]),
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _setEnabled(ReminderSchedule schedule, bool enabled) async {
    final localizations = AppLocalizations.of(context);
    setState(() => _actionInProgress = true);
    try {
      final result = await ref
          .read(reminderControllerProvider.notifier)
          .setEnabled(
            weekday: schedule.weekday,
            enabled: enabled,
            title: localizations.notificationReminderTitle,
            body: localizations.notificationReminderBody,
          );
      if (!mounted) return;
      if (result == NotificationPermissionResult.granted) {
        if (enabled) {
          await _refreshEnvironment(localizations, reportError: false);
          if (!mounted) return;
        }
        _showMessage(localizations.reminderSaved);
      } else {
        _showPermissionMessage(
          result == NotificationPermissionResult.denied ||
                  result == NotificationPermissionResult.permanentlyDenied
              ? localizations.permissionNotificationDenied
              : localizations.reminderPermissionNeeded,
        );
      }
    } on Object {
      if (mounted) _showMessage(localizations.errorGenericBody);
    } finally {
      if (mounted) setState(() => _actionInProgress = false);
    }
  }

  Future<void> _pickTimeForDay(ReminderSchedule schedule) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: schedule.hour, minute: schedule.minute),
      helpText: AppLocalizations.of(context).reminderTime,
    );
    if (selected == null || !mounted) return;
    final localizations = AppLocalizations.of(context);
    await _runScheduleAction(
      () => ref
          .read(reminderControllerProvider.notifier)
          .setTime(
            weekday: schedule.weekday,
            hour: selected.hour,
            minute: selected.minute,
            title: localizations.notificationReminderTitle,
            body: localizations.notificationReminderBody,
          ),
    );
  }

  Future<void> _runScheduleAction(Future<void> Function() action) async {
    final localizations = AppLocalizations.of(context);
    setState(() => _actionInProgress = true);
    try {
      await action();
      if (!mounted) return;
      if (!ref.read(reminderControllerProvider).hasError) {
        _showMessage(localizations.reminderSaved);
      }
    } on Object {
      if (mounted) _showMessage(localizations.errorGenericBody);
    } finally {
      if (mounted) setState(() => _actionInProgress = false);
    }
  }

  void _queueEnvironmentRefresh(AppLocalizations localizations) {
    final locale = Localizations.localeOf(context).toString();
    if (_refreshedLocale == locale) return;
    _refreshedLocale = locale;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_refreshEnvironment(localizations));
    });
  }

  Future<void> _refreshEnvironment(
    AppLocalizations localizations, {
    bool reportError = true,
  }) async {
    try {
      final metrics = await ref.read(combinedWorkoutMetricsProvider.future);
      if (!mounted) return;
      await ref
          .read(reminderControllerProvider.notifier)
          .refreshForEnvironment(
            title: localizations.notificationReminderTitle,
            body: localizations.notificationReminderBody,
            force: true,
            currentStreak: metrics.currentStreak,
            streakAtRisk: metrics.streakAtRisk,
            streakRiskBody: localizations.notificationStreakReminderBody(
              metrics.currentStreak,
            ),
          );
    } on Object {
      if (reportError && mounted) {
        _showMessage(localizations.errorGenericBody);
      }
    }
  }

  String _formatTime(ReminderSchedule schedule) {
    return MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay(hour: schedule.hour, minute: schedule.minute),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
  }

  String _weekdayShort(AppLocalizations localizations, int weekday) =>
      switch (weekday) {
        DateTime.monday => localizations.weekdayMondayShort,
        DateTime.tuesday => localizations.weekdayTuesdayShort,
        DateTime.wednesday => localizations.weekdayWednesdayShort,
        DateTime.thursday => localizations.weekdayThursdayShort,
        DateTime.friday => localizations.weekdayFridayShort,
        DateTime.saturday => localizations.weekdaySaturdayShort,
        DateTime.sunday => localizations.weekdaySundayShort,
        _ => localizations.commonNotAvailable,
      };

  String _weekdayFull(AppLocalizations localizations, int weekday) =>
      switch (weekday) {
        DateTime.monday => localizations.weekdayMonday,
        DateTime.tuesday => localizations.weekdayTuesday,
        DateTime.wednesday => localizations.weekdayWednesday,
        DateTime.thursday => localizations.weekdayThursday,
        DateTime.friday => localizations.weekdayFriday,
        DateTime.saturday => localizations.weekdaySaturday,
        DateTime.sunday => localizations.weekdaySunday,
        _ => localizations.commonNotAvailable,
      };

  void _showPermissionMessage(String message) {
    final localizations = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(
            label: localizations.permissionOpenSettings,
            onPressed: () {
              unawaited(ref.read(permissionServiceProvider).openSettings());
            },
          ),
        ),
      );
  }

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _WeekdayControl extends StatelessWidget {
  const _WeekdayControl({
    required this.dayLabel,
    required this.selected,
    required this.enabled,
    required this.onToggle,
  });

  final String dayLabel;
  final bool selected;
  final bool enabled;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Semantics(
        selected: selected,
        button: true,
        label: dayLabel,
        child: Material(
          color: selected ? colors.primary : colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: enabled ? onToggle : null,
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 48,
              width: double.infinity,
              child: Center(
                child: Text(
                  dayLabel,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: selected ? colors.onPrimary : colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
