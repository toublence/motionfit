import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motionfit_squat/app/localization/generated/app_localizations.dart';
import 'package:motionfit_squat/core/providers.dart';
import 'package:motionfit_squat/core/widgets/responsive_page.dart';
import 'package:motionfit_squat/features/records/application/records_providers.dart';
import 'package:motionfit_squat/features/records/presentation/widgets/calendar_records_view.dart';
import 'package:motionfit_squat/features/records/presentation/widgets/record_components.dart';
import 'package:motionfit_squat/features/settings/application/preferences_controller.dart';
import 'package:motionfit_squat/features/squat/application/workout_preparation.dart';
import 'package:motionfit_squat/features/squat/presentation/workout_preparation_launcher.dart';

class RecordsScreen extends ConsumerStatefulWidget {
  const RecordsScreen({this.onStartWorkout, super.key});

  final VoidCallback? onStartWorkout;

  @override
  ConsumerState<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends ConsumerState<RecordsScreen> {
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    ref.read(analyticsServiceProvider).screenView('records');
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sessions = ref.watch(allSessionsProvider);
    final selectedDate = ref.watch(selectedRecordDateProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.recordsTitle)),
      body: SafeArea(
        top: false,
        child: ResponsivePage(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 8),
          child: switch (sessions) {
            AsyncData(:final value) when value.isEmpty => RecordEmptyState(
              title: l10n.recordsEmptyTitle,
              body: l10n.recordsEmptyBody,
              actionLabel: l10n.recordsStartWorkout,
              onAction: _startWorkout,
            ),
            AsyncData(:final value) => CalendarRecordsView(
              sessions: value,
              visibleMonth: _visibleMonth,
              selectedDate: selectedDate,
              onPreviousMonth: () => _moveMonth(-1),
              onNextMonth: () => _moveMonth(1),
              onSelectDate: (date) =>
                  ref.read(selectedRecordDateProvider.notifier).select(date),
              onRefresh: _refreshSessions,
            ),
            AsyncError() => RecordErrorState(
              title: l10n.errorGenericTitle,
              body: l10n.recordsLoadError,
              retryLabel: l10n.commonRetry,
              onRetry: () => ref.invalidate(allSessionsProvider),
            ),
            _ => RecordLoadingState(label: l10n.recordsLoading),
          },
        ),
      ),
    );
  }

  void _moveMonth(int offset) {
    final next = DateTime(_visibleMonth.year, _visibleMonth.month + offset);
    setState(() => _visibleMonth = next);
    ref.read(selectedRecordDateProvider.notifier).select(next);
  }

  Future<void> _refreshSessions() async {
    ref.invalidate(allSessionsProvider);
    ref.invalidate(workoutStatisticsProvider);
    await ref.read(allSessionsProvider.future);
  }

  Future<void> _startWorkout() async {
    final callback = widget.onStartWorkout;
    if (callback != null) {
      callback();
      return;
    }
    final plan = ref.read(preferencesControllerProvider).lastWorkoutPlan;
    await openWorkoutPreparation(
      context,
      ref,
      WorkoutPreparation.newWorkout(plan),
    );
  }
}
