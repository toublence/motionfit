import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:motionfit_squat/app/theme/exercise_colors.dart';
import 'package:motionfit_squat/features/pushup/localization/generated/pushup_localizations.dart';
import 'package:motionfit_squat/features/pushup/providers.dart';
import 'package:motionfit_squat/core/widgets/coach_ui.dart';
import 'package:motionfit_squat/core/widgets/responsive_page.dart';
import 'package:motionfit_squat/features/pushup/records/application/records_providers.dart';
import 'package:motionfit_squat/features/pushup/records/domain/retention_metrics.dart';
import 'package:motionfit_squat/features/pushup/records/domain/workout_session_details.dart';
import 'package:motionfit_squat/features/pushup/records/presentation/widgets/record_formatters.dart';
import 'package:motionfit_squat/features/settings/application/preferences_controller.dart';
import 'package:motionfit_squat/features/pushup/application/workout_preparation.dart';
import 'package:motionfit_squat/features/pushup/domain/models/workout_plan.dart';
import 'package:motionfit_squat/features/pushup/domain/services/workout_session_policy.dart';
import 'package:motionfit_squat/features/pushup/presentation/workout_preparation_launcher.dart';

class PushupHomeScreen extends ConsumerStatefulWidget {
  const PushupHomeScreen({super.key});

  @override
  ConsumerState<PushupHomeScreen> createState() => _PushupHomeScreenState();
}

class _PushupHomeScreenState extends ConsumerState<PushupHomeScreen> {
  int? _lastCompletedWorkoutCount;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final plan = ref
          .read(preferencesControllerProvider)
          .pushupLastWorkoutPlan;
      ref.read(analyticsServiceProvider)
        ..screenView('workout_setup')
        ..workoutSetupViewed(
          plannedSets: plan.setCount,
          plannedRepsPerSet: plan.targetRepsPerSet,
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = PushupLocalizations.of(context);
    final preferences = ref.watch(preferencesControllerProvider);
    final plan = preferences.pushupLastWorkoutPlan;
    final recoverable = ref.watch(recoverableSessionProvider);
    final retention = ref.watch(retentionMetricsProvider);
    final sessions = ref.watch(allSessionsProvider);
    final retentionMetrics = switch (retention) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final completedWorkoutCount = retentionMetrics?.completedWorkoutCount;
    if (completedWorkoutCount != null) {
      final previous = _lastCompletedWorkoutCount;
      _lastCompletedWorkoutCount = completedWorkoutCount;
      if (previous != null && completedWorkoutCount > previous) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && preferences.hapticsEnabled) {
            HapticFeedback.mediumImpact();
          }
        });
      }
    }
    final canStartNew = recoverable is AsyncData<WorkoutSessionDetails?>;
    final sessionValues = switch (sessions) {
      AsyncData(:final value) => value,
      _ => const <WorkoutSessionDetails>[],
    };
    Future<void> updatePlan(WorkoutPlan next) async {
      if (preferences.hapticsEnabled) HapticFeedback.selectionClick();
      try {
        await ref
            .read(preferencesControllerProvider.notifier)
            .setPushupWorkoutPlan(next);
      } on Object {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorGenericBody)));
      }
    }

    Future<void> pick({
      required String title,
      required int value,
      required int min,
      required int max,
      required ValueChanged<int> onChanged,
      String Function(int)? formatter,
    }) async {
      final selected = await showModalBottomSheet<int>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) => _ValuePickerSheet(
          title: title,
          initialValue: value,
          minimum: min,
          maximum: max,
          formatter: formatter,
        ),
      );
      if (selected != null && mounted) onChanged(selected);
    }

    Future<void> editPlan() async {
      final field = await showModalBottomSheet<_PlanField>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(l10n.homeSetsLabel),
                trailing: Text(l10n.unitSets(plan.setCount)),
                onTap: () => Navigator.pop(sheetContext, _PlanField.sets),
              ),
              ListTile(
                title: Text(l10n.homeRepsPerSetLabel),
                trailing: Text(l10n.unitReps(plan.targetRepsPerSet)),
                onTap: () => Navigator.pop(sheetContext, _PlanField.reps),
              ),
              ListTile(
                title: Text(l10n.homeRestTimeLabel),
                trailing: Text(l10n.unitSeconds(plan.restDurationSeconds)),
                onTap: () => Navigator.pop(sheetContext, _PlanField.rest),
              ),
            ],
          ),
        ),
      );
      if (!mounted || field == null) return;
      switch (field) {
        case _PlanField.sets:
          await pick(
            title: l10n.homeSetsLabel,
            value: plan.setCount,
            min: WorkoutPlan.minSets,
            max: WorkoutPlan.maxSets,
            onChanged: (value) => updatePlan(plan.copyWith(setCount: value)),
          );
          break;
        case _PlanField.reps:
          await pick(
            title: l10n.homeRepsPerSetLabel,
            value: plan.targetRepsPerSet,
            min: WorkoutPlan.minReps,
            max: WorkoutPlan.maxReps,
            onChanged: (value) =>
                updatePlan(plan.copyWith(targetRepsPerSet: value)),
          );
          break;
        case _PlanField.rest:
          await pick(
            title: l10n.homeRestTimeLabel,
            value: plan.restDurationSeconds,
            min: WorkoutPlan.minRestSeconds,
            max: WorkoutPlan.maxRestSeconds,
            formatter: l10n.unitSeconds,
            onChanged: (value) =>
                updatePlan(plan.copyWith(restDurationSeconds: value)),
          );
          break;
      }
    }

    return Scaffold(
      body: SafeArea(
        child: ResponsivePage(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 18, 20, 20),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MotionEyebrow(l10n.appName),
                const SizedBox(height: 20),
                _WeekActivityOverview(
                  metrics: retentionMetrics,
                  sessions: sessionValues,
                ),
                const SizedBox(height: 22),
                const MotionRule(),
                const SizedBox(height: 20),
                _TodayRecord(
                  metrics: retentionMetrics,
                  sessions: sessionValues,
                ),
                const SizedBox(height: 22),
                const MotionRule(),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: MotionEyebrow(
                        l10n.homeWorkoutSetup,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    TextButton(
                      onPressed: editPlan,
                      child: Text(l10n.commonEdit),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${l10n.navPushup} ${l10n.unitReps(plan.setCount * plan.targetRepsPerSet)}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${l10n.unitSets(plan.setCount)} × '
                  '${l10n.unitReps(plan.targetRepsPerSet)} · '
                  '${l10n.homeRestTimeLabel} ${l10n.unitSeconds(plan.restDurationSeconds)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: canStartNew
                        ? () => openWorkoutPreparation(
                            context,
                            ref,
                            WorkoutPreparation.newWorkout(plan),
                          )
                        : null,
                    icon: const Icon(Icons.play_arrow_rounded, size: 19),
                    label: Text('${l10n.navPushup} ${l10n.commonStart}'),
                  ),
                ),
                if (recoverable case AsyncData(value: final details?)) ...[
                  const SizedBox(height: 12),
                  _RecoverableWorkoutCard(details: details),
                ],
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TodayRecord extends StatelessWidget {
  const _TodayRecord({required this.metrics, required this.sessions});

  final RetentionMetrics? metrics;
  final List<WorkoutSessionDetails> sessions;

  @override
  Widget build(BuildContext context) {
    final l10n = PushupLocalizations.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final completedToday =
        sessions.where((details) {
          final session = details.session;
          if (!WorkoutSessionPolicy.canUpdateChallenge(session)) return false;
          final completedAt = (session.endedAt ?? session.startedAt).toLocal();
          return DateTime(
                completedAt.year,
                completedAt.month,
                completedAt.day,
              ) ==
              today;
        }).toList()..sort(
          (a, b) => (b.session.endedAt ?? b.session.startedAt).compareTo(
            a.session.endedAt ?? a.session.startedAt,
          ),
        );
    final latest = completedToday.isEmpty ? null : completedToday.first;
    final activeSeconds = completedToday.fold<int>(
      0,
      (total, details) => total + details.session.activeDurationSeconds,
    );
    final scores = completedToday
        .expand((details) => details.reps)
        .map((rep) => rep.overallFormScore)
        .whereType<double>()
        .toList();
    final averageScore = scores.isEmpty
        ? null
        : scores.reduce((a, b) => a + b) / scores.length;
    final summary = metrics == null
        ? l10n.commonLoading
        : completedToday.isEmpty
        ? l10n.recordsEmptyBody
        : [
            l10n.unitReps(metrics!.todayReps),
            l10n.unitSets(metrics!.todaySets),
            if (averageScore != null)
              '${l10n.formScore} ${formatFormScore(context, averageScore)}',
            if (activeSeconds > 0) formatRecordDuration(l10n, activeSeconds),
          ].join('  ·  ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: MotionEyebrow(l10n.homeTodayTitle)),
            if (latest != null)
              TextButton.icon(
                key: const ValueKey('home-view-latest-result'),
                onPressed: () => context.push(
                  '/records/pushup/session/${latest.session.id}',
                ),
                icon: const Icon(Icons.chevron_right_rounded, size: 18),
                iconAlignment: IconAlignment.end,
                label: Text(l10n.homeViewResult),
              ),
          ],
        ),
        const SizedBox(height: 7),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            summary,
            maxLines: 1,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
      ],
    );
  }
}

class _WeekActivityOverview extends StatelessWidget {
  const _WeekActivityOverview({required this.metrics, required this.sessions});

  final RetentionMetrics? metrics;
  final List<WorkoutSessionDetails> sessions;

  @override
  Widget build(BuildContext context) {
    final l10n = PushupLocalizations.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(Duration(days: today.weekday - 1));
    final workoutDates = sessions
        .where(
          (details) => WorkoutSessionPolicy.canUpdateChallenge(details.session),
        )
        .map((details) {
          final session = details.session;
          final value = (session.endedAt ?? session.startedAt).toLocal();
          return DateTime(value.year, value.month, value.day);
        })
        .toSet();
    final weekEnd = start.add(const Duration(days: 6));
    final weeklyDays = workoutDates
        .where((date) => !date.isBefore(start) && !date.isAfter(weekEnd))
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                child: Text(
                  l10n.challengeThisWeekProgress(weeklyDays, 3),
                  key: ValueKey(weeklyDays),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            if ((metrics?.currentStreak ?? 0) > 1)
              Text(
                '🔥 ${l10n.streakDays(metrics!.currentStreak)}',
                style: Theme.of(context).textTheme.labelMedium,
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          weeklyDays == 0
              ? l10n.challengeWeeklyDescription
              : weeklyDays >= 3
              ? l10n.challengeTodayCompleted
              : l10n.challengeThisWeekProgress(weeklyDays, 3),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: List.generate(7, (index) {
            final day = start.add(Duration(days: index));
            final completed = workoutDates.contains(day);
            final isToday = day == today;
            final color = completed
                ? ExerciseColors.pushup
                : Theme.of(context).colorScheme.outlineVariant;
            return Expanded(
              child: Semantics(
                label: DateFormat.EEEE(l10n.localeName).format(day),
                value: completed ? l10n.recordsCalendarWorkoutDay : null,
                child: Column(
                  children: [
                    Text(
                      DateFormat.E(l10n.localeName).format(day),
                      maxLines: 1,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isToday
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: isToday ? FontWeight.w800 : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: completed ? color : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(color: color),
                      ),
                      child: completed
                          ? Icon(
                              Icons.check_rounded,
                              size: 17,
                              color: Theme.of(context).colorScheme.onPrimary,
                            )
                          : isToday
                          ? Icon(Icons.circle, size: 7, color: color)
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

enum _PlanField { sets, reps, rest }

class _ValuePickerSheet extends StatefulWidget {
  const _ValuePickerSheet({
    required this.title,
    required this.initialValue,
    required this.minimum,
    required this.maximum,
    this.formatter,
  });

  final String title;
  final int initialValue;
  final int minimum;
  final int maximum;
  final String Function(int)? formatter;

  @override
  State<_ValuePickerSheet> createState() => _ValuePickerSheetState();
}

class _ValuePickerSheetState extends State<_ValuePickerSheet> {
  late int value = widget.initialValue;
  late final FixedExtentScrollController _controller =
      FixedExtentScrollController(
        initialItem: widget.initialValue - widget.minimum,
      );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectIndex(int index) {
    final next = widget.minimum + index;
    if (next == value) return;
    HapticFeedback.selectionClick();
    setState(() => value = next);
  }

  void _selectByTap(int index) {
    _controller.animateToItem(
      index,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = PushupLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, value),
                  child: Text(l10n.commonDone),
                ),
              ],
            ),
            SizedBox(
              height: 190,
              child: ListWheelScrollView.useDelegate(
                itemExtent: 48,
                physics: const FixedExtentScrollPhysics(),
                controller: _controller,
                onSelectedItemChanged: _selectIndex,
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: widget.maximum - widget.minimum + 1,
                  builder: (context, index) {
                    final item = widget.minimum + index;
                    final selected = item == value;
                    final label = widget.formatter?.call(item) ?? '$item';
                    return Semantics(
                      button: true,
                      selected: selected,
                      label: label,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 2,
                        ),
                        child: Material(
                          color: selected
                              ? colors.primaryContainer
                              : Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: selected
                                  ? colors.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: InkWell(
                            onTap: () => _selectByTap(index),
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Center(
                                  child: Text(
                                    label,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: selected
                                              ? colors.onPrimaryContainer
                                              : colors.onSurfaceVariant,
                                          fontWeight: selected
                                              ? FontWeight.w800
                                              : FontWeight.w500,
                                        ),
                                  ),
                                ),
                                if (selected)
                                  PositionedDirectional(
                                    end: 16,
                                    child: Icon(
                                      Icons.check_rounded,
                                      size: 22,
                                      color: colors.primary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecoverableWorkoutCard extends ConsumerWidget {
  const _RecoverableWorkoutCard({required this.details});

  final WorkoutSessionDetails details;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = PushupLocalizations.of(context);
    final currentSet = details.sets.isEmpty ? null : details.sets.last;
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.pause_circle_outline_rounded,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(l10n.workoutStatePaused),
        subtitle: Text(
          l10n.workoutSetProgress(
            currentSet?.setIndex ?? 1,
            details.session.plannedSetCount,
          ),
        ),
        trailing: FilledButton.tonal(
          onPressed: () => openWorkoutPreparation(
            context,
            ref,
            WorkoutPreparation.recovery(details),
          ),
          child: Text(l10n.workoutResume),
        ),
      ),
    );
  }
}
