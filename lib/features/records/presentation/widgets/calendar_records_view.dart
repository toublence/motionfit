import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:motionfit_squat/app/localization/generated/app_localizations.dart';
import 'package:motionfit_squat/app/theme/exercise_colors.dart';
import 'package:motionfit_squat/app/theme/motionfit_tokens.dart';
import 'package:motionfit_squat/core/widgets/coach_ui.dart';
import 'package:motionfit_squat/features/exercise/domain/exercise_type.dart';
import 'package:motionfit_squat/features/records/presentation/models/growth_workout_record.dart';

class CalendarRecordsView extends StatefulWidget {
  const CalendarRecordsView({
    required this.records,
    required this.onRefresh,
    required this.onStartWorkout,
    super.key,
  });

  final List<GrowthWorkoutRecord> records;
  final Future<void> Function() onRefresh;
  final VoidCallback onStartWorkout;

  @override
  State<CalendarRecordsView> createState() => _CalendarRecordsViewState();
}

class _CalendarRecordsViewState extends State<CalendarRecordsView> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = _initialSelectedDate(widget.records);
  }

  @override
  void didUpdateWidget(CalendarRecordsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final today = _dateOnly(DateTime.now());
    final hadToday = oldWidget.records.any(
      (record) => record.isValid && _dateOnly(record.startedAt) == today,
    );
    final hasToday = widget.records.any(
      (record) => record.isValid && _dateOnly(record.startedAt) == today,
    );
    if (!hadToday && hasToday) _selectedDate = today;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final validRecords =
        widget.records.where((record) => record.isValid).toList()
          ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    final latest = validRecords.firstOrNull;
    final selectedRecords =
        validRecords
            .where((record) => _dateOnly(record.startedAt) == _selectedDate)
            .toList()
          ..sort((a, b) => a.startedAt.compareTo(b.startedAt));

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsetsDirectional.only(bottom: context.tokens.spaceXl),
        children: [
          _StreakSummary(
            records: validRecords,
            latest: latest,
            emptyMessage: l10n.recordsEmptyBody,
          ),
          SizedBox(height: context.tokens.spaceXl),
          _WorkoutGrass(
            records: validRecords,
            selectedDate: _selectedDate,
            onSelectDate: (date) => setState(() => _selectedDate = date),
          ),
          SizedBox(height: context.tokens.spaceXl),
          CoachSectionHeader(title: l10n.recordsWorkoutRecords),
          const SizedBox(height: 7),
          Text(
            _selectedDateLabel(l10n, _selectedDate),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          _SelectedDayRecords(records: selectedRecords),
          if (validRecords.isEmpty) ...[
            SizedBox(height: context.tokens.spaceLg),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: widget.onStartWorkout,
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(l10n.recordsStartWorkout),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StreakSummary extends StatelessWidget {
  const _StreakSummary({
    required this.records,
    required this.latest,
    required this.emptyMessage,
  });

  final List<GrowthWorkoutRecord> records;
  final GrowthWorkoutRecord? latest;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final streak = _currentWorkoutStreak(records);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '🔥 ${l10n.streakLabel} · ${l10n.streakDays(streak)}',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 7),
        if (latest == null)
          Text(
            emptyMessage,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          )
        else
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: ExerciseColors.of(latest!.exerciseType),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _latestCompletionText(context, latest!),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _WorkoutGrass extends StatefulWidget {
  const _WorkoutGrass({
    required this.records,
    required this.selectedDate,
    required this.onSelectDate,
  });

  final List<GrowthWorkoutRecord> records;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectDate;

  @override
  State<_WorkoutGrass> createState() => _WorkoutGrassState();
}

class _WorkoutGrassState extends State<_WorkoutGrass> {
  static const _weekCount = 16;
  static const _weeksPerSwipe = 4;
  final PageController _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final today = _dateOnly(DateTime.now());
    final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));
    final byDate = <DateTime, List<GrowthWorkoutRecord>>{};
    for (final record in widget.records) {
      final date = _dateOnly(record.startedAt);
      byDate.putIfAbsent(date, () => []).add(record);
    }
    final visibleStart = _periodStart(thisWeekStart, _page);
    final visibleEnd = visibleStart.add(
      const Duration(days: _weekCount * 7 - 1),
    );
    final trainedDays = byDate.keys
        .where(
          (date) => !date.isBefore(visibleStart) && !date.isAfter(visibleEnd),
        )
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: CoachSectionHeader(title: l10n.recordsConsistency)),
            if (_page > 0)
              TextButton(
                onPressed: () => _pageController.animateToPage(
                  0,
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                ),
                child: Text(l10n.recordsToday),
              ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 144,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _WeekdayLabels(),
              const SizedBox(width: 4),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  reverse: true,
                  onPageChanged: (page) => setState(() => _page = page),
                  itemBuilder: (context, page) => _GrassPeriod(
                    firstWeekStart: _periodStart(thisWeekStart, page),
                    byDate: byDate,
                    today: today,
                    selectedDate: widget.selectedDate,
                    onSelectDate: widget.onSelectDate,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _page == 0
              ? l10n.recordsRecentWeeksSummary(trainedDays)
              : l10n.recordsRangeSummary(
                  DateFormat.MMMd(l10n.localeName).format(visibleStart),
                  DateFormat.MMMd(l10n.localeName).format(visibleEnd),
                  trainedDays,
                ),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  DateTime _periodStart(DateTime currentWeekStart, int page) => currentWeekStart
      .subtract(Duration(days: 7 * (_weekCount - 1 + page * _weeksPerSwipe)));
}

class _WeekdayLabels extends StatelessWidget {
  const _WeekdayLabels();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 22),
    child: Column(
      children: List.generate(7, (dayIndex) {
        final weekday = dayIndex + DateTime.monday;
        return SizedBox(
          width: 22,
          height: 16,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              MaterialLocalizations.of(context).narrowWeekdays[weekday % 7],
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      }),
    ),
  );
}

class _GrassPeriod extends StatelessWidget {
  const _GrassPeriod({
    required this.firstWeekStart,
    required this.byDate,
    required this.today,
    required this.selectedDate,
    required this.onSelectDate,
  });

  static const _weekCount = 16;
  final DateTime firstWeekStart;
  final Map<DateTime, List<GrowthWorkoutRecord>> byDate;
  final DateTime today;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectDate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final weekWidth = constraints.maxWidth / _weekCount;
        final cellSize = math
            .min(13.0, math.max(9.0, weekWidth - 3))
            .toDouble();
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(_weekCount, (weekIndex) {
            final weekStart = firstWeekStart.add(Duration(days: weekIndex * 7));
            final monthDate = _monthLabelDate(weekStart, weekIndex == 0);
            return Expanded(
              child: Column(
                children: [
                  SizedBox(
                    height: 22,
                    child: monthDate == null
                        ? null
                        : OverflowBox(
                            maxWidth: 60,
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              DateFormat.MMM(l10n.localeName).format(monthDate),
                              maxLines: 1,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    fontSize: 9,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ),
                  ),
                  for (var dayIndex = 0; dayIndex < 7; dayIndex++)
                    _GrassCell(
                      date: weekStart.add(Duration(days: dayIndex)),
                      records:
                          byDate[weekStart.add(Duration(days: dayIndex))] ??
                          const [],
                      today: today,
                      selected:
                          weekStart.add(Duration(days: dayIndex)) ==
                          selectedDate,
                      future: weekStart
                          .add(Duration(days: dayIndex))
                          .isAfter(today),
                      size: cellSize,
                      onSelect: onSelectDate,
                    ),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  DateTime? _monthLabelDate(DateTime weekStart, bool firstWeek) {
    for (var day = 0; day < 7; day++) {
      final date = weekStart.add(Duration(days: day));
      if (date.day == 1) return date;
    }
    return firstWeek ? weekStart : null;
  }
}

class _GrassCell extends StatelessWidget {
  const _GrassCell({
    required this.date,
    required this.records,
    required this.today,
    required this.selected,
    required this.future,
    required this.size,
    required this.onSelect,
  });

  final DateTime date;
  final List<GrowthWorkoutRecord> records;
  final DateTime today;
  final bool selected;
  final bool future;
  final double size;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final exerciseTypes = records.map((record) => record.exerciseType).toSet();
    final orderedTypes = ExerciseType.values
        .where(exerciseTypes.contains)
        .toList(growable: false);
    final colors = Theme.of(context).colorScheme;
    final exerciseNames = orderedTypes
        .map((type) => _exerciseLabel(AppLocalizations.of(context), type))
        .join(', ');
    final borderColor = selected
        ? colors.onSurface
        : date == today
        ? colors.onSurfaceVariant
        : future
        ? colors.outlineVariant.withValues(alpha: .22)
        : colors.outlineVariant;
    final borderWidth = selected
        ? 1.6
        : date == today
        ? 1.2
        : .45;

    return Semantics(
      label: _selectedDateLabel(AppLocalizations.of(context), date),
      value: exerciseNames.isEmpty ? null : exerciseNames,
      selected: selected,
      button: !future,
      child: Tooltip(
        message: exerciseNames.isEmpty
            ? _selectedDateLabel(AppLocalizations.of(context), date)
            : '${_selectedDateLabel(AppLocalizations.of(context), date)} · '
                  '$exerciseNames',
        child: InkWell(
          onTap: future ? null : () => onSelect(date),
          borderRadius: BorderRadius.circular(3),
          child: SizedBox(
            height: 16,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: size,
                height: size,
                padding: EdgeInsets.all(borderWidth),
                decoration: BoxDecoration(
                  color: future
                      ? colors.surface.withValues(alpha: .08)
                      : orderedTypes.isEmpty
                      ? colors.surfaceContainerHighest.withValues(alpha: .58)
                      : null,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: borderColor, width: borderWidth),
                ),
                child: orderedTypes.isEmpty
                    ? null
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(1.5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final type in orderedTypes)
                              Expanded(
                                child: ColoredBox(
                                  color: ExerciseColors.of(type),
                                ),
                              ),
                          ],
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

class _SelectedDayRecords extends StatelessWidget {
  const _SelectedDayRecords({required this.records});

  final List<GrowthWorkoutRecord> records;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (records.isEmpty) {
      return Text(
        l10n.recordsNoWorkoutOnDay,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var index = 0; index < records.length; index++) ...[
            _WorkoutRecordRow(record: records[index]),
            if (index < records.length - 1)
              const Divider(height: 1, indent: 44),
          ],
        ],
      ),
    );
  }
}

class _WorkoutRecordRow extends StatelessWidget {
  const _WorkoutRecordRow({required this.record});

  final GrowthWorkoutRecord record;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final score = record.averageFormScore?.round();
    return InkWell(
      onTap: () => context.push(record.detailRoute),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(14, 13, 10, 13),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: ExerciseColors.of(record.exerciseType),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _recordSummary(l10n, record),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            if (score != null) ...[
              const SizedBox(width: 8),
              Text(
                '${l10n.formShort} $score',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
            const SizedBox(width: 2),
            const Icon(Icons.chevron_right_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}

int _currentWorkoutStreak(Iterable<GrowthWorkoutRecord> records) {
  final dates = records
      .where((record) => record.isValid)
      .map((record) => _dateOnly(record.startedAt))
      .toSet();
  final today = _dateOnly(DateTime.now());
  var cursor = dates.contains(today)
      ? today
      : today.subtract(const Duration(days: 1));
  var streak = 0;
  while (dates.contains(cursor)) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}

DateTime _initialSelectedDate(List<GrowthWorkoutRecord> records) {
  final today = _dateOnly(DateTime.now());
  final valid = records.where((record) => record.isValid).toList()
    ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  if (valid.any((record) => _dateOnly(record.startedAt) == today)) return today;
  return valid.isEmpty ? today : _dateOnly(valid.first.startedAt);
}

String _latestCompletionText(BuildContext context, GrowthWorkoutRecord record) {
  final l10n = AppLocalizations.of(context);
  final date = _dateOnly(record.startedAt);
  final prefix = date == _dateOnly(DateTime.now())
      ? l10n.recordsToday
      : DateFormat.MMMd(l10n.localeName).format(date);
  return '$prefix · ${_exerciseLabel(l10n, record.exerciseType)} '
      '${_exerciseAmount(l10n, record)}';
}

String _recordSummary(AppLocalizations l10n, GrowthWorkoutRecord record) {
  final exercise = _exerciseLabel(l10n, record.exerciseType);
  final amount = _exerciseAmount(l10n, record);
  if (record.exerciseType == ExerciseType.plank) return '$exercise $amount';
  return '$exercise $amount · ${l10n.unitSets(record.completedSetCount)} · '
      '${_compactDuration(l10n, record.activeDurationSeconds)}';
}

String _exerciseAmount(AppLocalizations l10n, GrowthWorkoutRecord record) =>
    record.exerciseType == ExerciseType.plank
    ? l10n.unitSeconds(record.totalReps)
    : l10n.unitReps(record.totalReps);

String _exerciseLabel(AppLocalizations l10n, ExerciseType type) =>
    switch (type) {
      ExerciseType.squat => l10n.navSquat,
      ExerciseType.pushup => l10n.exercisePushup,
      ExerciseType.plank => l10n.exercisePlank,
    };

String _selectedDateLabel(AppLocalizations l10n, DateTime date) =>
    '${DateFormat.MMMMd(l10n.localeName).format(date)} · '
    '${DateFormat.EEEE(l10n.localeName).format(date)}';

String _compactDuration(AppLocalizations l10n, int seconds) =>
    seconds < Duration.secondsPerMinute
    ? l10n.unitSeconds(seconds)
    : '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
