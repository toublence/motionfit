import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motionfit_squat/app/localization/generated/app_localizations.dart';
import 'package:motionfit_squat/app/theme/motionfit_tokens.dart';
import 'package:motionfit_squat/core/widgets/coach_ui.dart';
import 'package:motionfit_squat/features/records/domain/workout_session_details.dart';
import 'package:motionfit_squat/features/records/presentation/widgets/monthly_workout_calendar.dart';
import 'package:motionfit_squat/features/records/presentation/widgets/record_formatters.dart';
import 'package:motionfit_squat/features/squat/domain/models/rep_record.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_enums.dart';

class CalendarRecordsView extends StatelessWidget {
  const CalendarRecordsView({
    required this.sessions,
    required this.visibleMonth,
    required this.selectedDate,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onSelectDate,
    required this.onRefresh,
    super.key,
  });

  final List<WorkoutSessionDetails> sessions;
  final DateTime visibleMonth;
  final DateTime selectedDate;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onSelectDate;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final workoutDates = sessions
        .map((details) => _dateOnly(details.session.startedAt.toLocal()))
        .toSet();
    final selectedSessions =
        sessions
            .where(
              (details) =>
                  _dateOnly(details.session.startedAt.toLocal()) ==
                  selectedDate,
            )
            .toList()
          ..sort((a, b) => b.session.startedAt.compareTo(a.session.startedAt));
    final recentSessions = sessions.toList()
      ..sort((a, b) => b.session.startedAt.compareTo(a.session.startedAt));

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsetsDirectional.only(bottom: context.tokens.spaceXl),
        children: [
          _WeeklySummary(sessions: sessions),
          SizedBox(height: context.tokens.spaceLg),
          CoachSectionHeader(title: l10n.recordsRecentWorkouts),
          const SizedBox(height: 10),
          for (
            var index = 0;
            index < recentSessions.length.clamp(0, 3);
            index++
          ) ...[
            _SessionRow(details: recentSessions[index]),
            if (index < recentSessions.length.clamp(0, 3) - 1)
              const SizedBox(height: 8),
          ],
          SizedBox(height: context.tokens.space20),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            ),
            child: ExpansionTile(
              key: const ValueKey('records-calendar-expansion'),
              initiallyExpanded: false,
              leading: const Icon(Icons.calendar_month_outlined),
              title: Text(l10n.recordsCalendarTitle),
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              children: [
                MonthlyWorkoutCalendar(
                  visibleMonth: visibleMonth,
                  selectedDate: selectedDate,
                  workoutDates: workoutDates,
                  onPreviousMonth: onPreviousMonth,
                  onNextMonth: onNextMonth,
                  onSelectDate: onSelectDate,
                ),
                const SizedBox(height: 12),
                if (selectedSessions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      l10n.recordsCalendarNoWorkoutSelected,
                      textAlign: TextAlign.center,
                    ),
                  )
                else ...[
                  _DailySummary(date: selectedDate, sessions: selectedSessions),
                  const SizedBox(height: 12),
                  for (
                    var index = 0;
                    index < selectedSessions.length;
                    index++
                  ) ...[
                    _SessionRow(details: selectedSessions[index]),
                    if (index != selectedSessions.length - 1)
                      const SizedBox(height: 8),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklySummary extends StatelessWidget {
  const _WeeklySummary({required this.sessions});

  final List<WorkoutSessionDetails> sessions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final nextWeekStart = weekStart.add(const Duration(days: 7));
    final previousWeekStart = weekStart.subtract(const Duration(days: 7));
    final weekly = sessions.where((details) {
      final startedAt = details.session.startedAt.toLocal();
      return !startedAt.isBefore(weekStart) &&
          startedAt.isBefore(nextWeekStart);
    }).toList();
    final previousWeekly = sessions.where((details) {
      final startedAt = details.session.startedAt.toLocal();
      return !startedAt.isBefore(previousWeekStart) &&
          startedAt.isBefore(weekStart);
    }).toList();
    final reps = weekly.fold<int>(
      0,
      (sum, details) => sum + details.session.totalReps,
    );
    final previousReps = previousWeekly.fold<int>(
      0,
      (sum, details) => sum + details.session.totalReps,
    );
    final scores = weekly
        .map((details) => details.averageFormScore)
        .whereType<double>()
        .toList();
    final averageScore = scores.isEmpty
        ? null
        : scores.reduce((a, b) => a + b) / scores.length;
    final activeSeconds = weekly.fold<int>(
      0,
      (sum, details) => sum + details.session.activeDurationSeconds,
    );
    final difference = reps - previousReps;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MotionEyebrow(
          l10n.recordsWeeklySummary,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$reps ${l10n.navSquat}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text:
                      '  ·  ${l10n.recordsWorkoutCount(weekly.length)}'
                      '${averageScore == null ? '' : '  ·  ${l10n.recordsAverageForm(averageScore.round())}'}'
                      '  ·  ${l10n.recordsWorkoutTime(_clockDuration(activeSeconds))}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            maxLines: 1,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(
              previousWeekly.isEmpty
                  ? Icons.fiber_new_rounded
                  : difference > 0
                  ? Icons.trending_up_rounded
                  : difference < 0
                  ? Icons.trending_down_rounded
                  : Icons.trending_flat_rounded,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                previousWeekly.isEmpty
                    ? l10n.recordsFirstWeek
                    : difference > 0
                    ? l10n.recordsMoreThanLastWeek(difference)
                    : difference < 0
                    ? l10n.recordsLessThanLastWeek(difference.abs())
                    : l10n.recordsSameAsLastWeek,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        CoachSectionHeader(title: l10n.recordsFormTrend),
        const SizedBox(height: 12),
        _FormTrend(sessions: sessions),
        _GrowthInsights(sessions: sessions),
      ],
    );
  }
}

class _FormTrend extends StatelessWidget {
  const _FormTrend({required this.sessions});

  final List<WorkoutSessionDetails> sessions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scored =
        sessions.where((details) => details.averageFormScore != null).toList()
          ..sort((a, b) => a.session.startedAt.compareTo(b.session.startedAt));
    final visible = scored.length > 7
        ? scored.sublist(scored.length - 7)
        : scored;
    if (visible.isEmpty) {
      return Text(
        l10n.recordsTrendEmpty,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }
    if (visible.length == 1) {
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '${l10n.recordsFirstFormScore}\n'),
            TextSpan(
              text: '${visible.single.averageFormScore!.round()}',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      );
    }
    final values = visible
        .map((details) => details.averageFormScore!.clamp(0, 100).toDouble())
        .toList();
    final average = values.reduce((a, b) => a + b) / values.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 112,
          child: CustomPaint(
            painter: _TrendPainter(
              values: values,
              color: Theme.of(context).colorScheme.primary,
              gridColor: Theme.of(context).colorScheme.outlineVariant,
              labelColor: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (final details in visible)
              Expanded(
                child: Text(
                  '${details.session.startedAt.toLocal().month}/'
                  '${details.session.startedAt.toLocal().day}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          l10n.recordsRecentAverage(visible.length, average.round()),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _TrendPainter extends CustomPainter {
  const _TrendPainter({
    required this.values,
    required this.color,
    required this.gridColor,
    required this.labelColor,
  });

  final List<double> values;
  final Color color;
  final Color gridColor;
  final Color labelColor;

  @override
  void paint(Canvas canvas, Size size) {
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final low = (minValue - 5).clamp(0, 100).toDouble();
    final high = (maxValue + 5).clamp(0, 100).toDouble();
    final range = (high - low).clamp(10, 100).toDouble();
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var index = 0; index < 3; index++) {
      final y = size.height * index / 2;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    final points = <Offset>[];
    for (var index = 0; index < values.length; index++) {
      final x = values.length == 1
          ? size.width / 2
          : size.width * index / (values.length - 1);
      final plotHeight = size.height - 28;
      final y = 24 + plotHeight - ((values[index] - low) / range * plotHeight);
      points.add(Offset(x, y.clamp(24, size.height)));
    }
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(path, linePaint);
    final pointPaint = Paint()..color = color;
    for (final point in points) {
      canvas.drawCircle(point, 5, pointPaint);
      canvas.drawCircle(point, 2, Paint()..color = Colors.white);
    }
    for (var index = 0; index < points.length; index++) {
      final label = TextPainter(
        text: TextSpan(
          text: '${values[index].round()}',
          style: TextStyle(
            color: labelColor,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      label.paint(
        canvas,
        Offset(
          (points[index].dx - label.width / 2).clamp(
            0,
            size.width - label.width,
          ),
          points[index].dy - label.height - 7,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.color != color ||
      oldDelegate.gridColor != gridColor ||
      oldDelegate.labelColor != labelColor;
}

class _GrowthInsights extends StatelessWidget {
  const _GrowthInsights({required this.sessions});

  final List<WorkoutSessionDetails> sessions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final issues = sessions
        .expand(frequentSessionIssues)
        .fold<Map<FormIssue, int>>(<FormIssue, int>{}, (counts, entry) {
          counts[entry.key] = (counts[entry.key] ?? 0) + entry.value;
          return counts;
        });
    final rankedIssues = issues.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final reps = sessions.expand((details) => details.reps).toList();
    final strength = _aggregateStrength(l10n, reps);
    if (strength == null && rankedIssues.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (strength != null)
            Text(
              '✓  ${l10n.recordsStrength}  ·  $strength',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          if (strength != null && rankedIssues.isNotEmpty)
            const SizedBox(height: 8),
          if (rankedIssues.isNotEmpty)
            Text(
              '⚠  ${l10n.recordsFocus}  ·  '
              '${formIssueLabel(l10n, rankedIssues.first.key)}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
        ],
      ),
    );
  }
}

String? _aggregateStrength(AppLocalizations l10n, List<RepRecord> reps) {
  if (reps.isEmpty) return null;
  bool allGood(RepQuality Function(RepRecord rep) select) {
    final assessed = reps
        .map(select)
        .where((quality) => quality != RepQuality.unavailable)
        .toList();
    return assessed.isNotEmpty &&
        assessed.every((quality) => quality == RepQuality.good);
  }

  if (allGood((rep) => rep.depthQuality)) {
    return l10n.formStrengthDepth;
  }
  if (allGood((rep) => rep.upperBodyQuality)) {
    return l10n.formStrengthControl;
  }
  if (allGood((rep) => rep.kneeAlignmentQuality)) {
    return l10n.formStrengthBalance;
  }
  return null;
}

class _DailySummary extends StatelessWidget {
  const _DailySummary({required this.date, required this.sessions});

  final DateTime date;

  final List<WorkoutSessionDetails> sessions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reps = sessions.fold<int>(
      0,
      (sum, details) => sum + details.session.totalReps,
    );
    final sets = sessions.fold<int>(
      0,
      (sum, details) => sum + details.session.completedSetCount,
    );
    final activeSeconds = sessions.fold<int>(
      0,
      (sum, details) => sum + details.session.activeDurationSeconds,
    );
    final scores = sessions
        .expand((details) => details.reps)
        .map((rep) => rep.overallFormScore)
        .whereType<double>()
        .toList();
    final score = scores.isEmpty
        ? null
        : (scores.reduce((a, b) => a + b) / scores.length).round();
    final issues = sessions
        .expand((details) => frequentSessionIssues(details))
        .fold<Map<FormIssue, int>>(<FormIssue, int>{}, (counts, entry) {
          counts[entry.key] = (counts[entry.key] ?? 0) + entry.value;
          return counts;
        });
    final frequent = issues.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          formatRecordDate(context, date),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            '${l10n.unitReps(reps)}  ·  ${l10n.unitSets(sets)}  ·  '
            '${_compactDuration(l10n, activeSeconds)}'
            '${score == null ? '' : '  ·  ${l10n.formShort} $score'}',
            maxLines: 1,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        if (frequent.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            '${l10n.recordsTodayPoint}  ·  '
            '${formIssueLabel(l10n, frequent.first.key)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
        const SizedBox(height: 10),
        Text(
          l10n.recordsWorkoutCount(sessions.length),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({required this.details});

  final WorkoutSessionDetails details;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = details.session;
    final startedAt = session.startedAt.toLocal();
    final today = _dateOnly(DateTime.now());
    final dateLabel = _dateOnly(startedAt) == today
        ? l10n.recordsToday
        : formatRecordDate(context, startedAt);
    final score = details.averageFormScore?.round();
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/records/session/${session.id}'),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '$dateLabel  ·  ${formatRecordTime(context, startedAt)}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          '${session.totalReps} ${l10n.navSquat}  ·  '
                          '${l10n.unitSets(session.completedSetCount)}  ·  '
                          '${_compactDuration(l10n, session.activeDurationSeconds)}',
                          maxLines: 1,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    if (score != null) ...[
                      const SizedBox(width: 12),
                      Text(
                        '${l10n.formShort} $score',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right_rounded, size: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _compactDuration(AppLocalizations l10n, int seconds) =>
    seconds < Duration.secondsPerMinute
    ? l10n.unitSeconds(seconds)
    : '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

String _clockDuration(int seconds) =>
    '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
