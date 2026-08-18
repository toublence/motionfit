import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:motionfit_squat/features/plank/localization/generated/plank_localizations.dart';
import 'package:motionfit_squat/app/theme/motionfit_tokens.dart';
import 'package:motionfit_squat/features/plank/records/presentation/widgets/record_formatters.dart';

class MonthlyWorkoutCalendar extends StatelessWidget {
  const MonthlyWorkoutCalendar({
    required this.visibleMonth,
    required this.selectedDate,
    required this.workoutDates,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onSelectDate,
    super.key,
  });

  final DateTime visibleMonth;
  final DateTime selectedDate;
  final Set<DateTime> workoutDates;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onSelectDate;

  @override
  Widget build(BuildContext context) {
    final l10n = PlankLocalizations.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final firstDayOfWeek = MaterialLocalizations.of(
      context,
    ).firstDayOfWeekIndex;
    final firstOfMonth = DateTime(visibleMonth.year, visibleMonth.month);
    final leadingDays =
        ((firstOfMonth.weekday % DateTime.daysPerWeek) -
            firstDayOfWeek +
            DateTime.daysPerWeek) %
        DateTime.daysPerWeek;
    final daysInMonth = DateTime(
      visibleMonth.year,
      visibleMonth.month + 1,
      0,
    ).day;
    final cellCount =
        ((leadingDays + daysInMonth) / DateTime.daysPerWeek).ceil() *
        DateTime.daysPerWeek;
    final requestedScale = MediaQuery.textScalerOf(context).scale(1);
    final calendarScale = requestedScale < 1 ? 1.0 : requestedScale;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onPreviousMonth,
                tooltip: l10n.recordsCalendarPreviousMonth,
                icon: Icon(
                  isRtl
                      ? Icons.chevron_right_rounded
                      : Icons.chevron_left_rounded,
                ),
              ),
              Expanded(
                child: Text(
                  formatRecordMonth(context, visibleMonth),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                onPressed: onNextMonth,
                tooltip: l10n.recordsCalendarNextMonth,
                icon: Icon(
                  isRtl
                      ? Icons.chevron_left_rounded
                      : Icons.chevron_right_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: List.generate(DateTime.daysPerWeek, (index) {
              final weekday = DateTime(
                2023,
                1,
                1,
              ).add(Duration(days: (firstDayOfWeek + index) % 7));
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Text(
                    DateFormat.E(recordLocaleName(context)).format(weekday),
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: context.tokens.spaceXs),
          LayoutBuilder(
            builder: (context, constraints) {
              final cellWidth = constraints.maxWidth / DateTime.daysPerWeek;
              final cellHeight = 44 * calendarScale;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cellCount,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: DateTime.daysPerWeek,
                  childAspectRatio: cellWidth / cellHeight,
                ),
                itemBuilder: (context, index) {
                  final day = index - leadingDays + 1;
                  if (day < 1 || day > daysInMonth) {
                    return const SizedBox.shrink();
                  }
                  final date = DateTime(
                    visibleMonth.year,
                    visibleMonth.month,
                    day,
                  );
                  return _CalendarDay(
                    date: date,
                    selected: _sameDay(date, selectedDate),
                    hasWorkout: workoutDates.contains(date),
                    onTap: () => onSelectDate(date),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({
    required this.date,
    required this.selected,
    required this.hasWorkout,
    required this.onTap,
  });

  final DateTime date;
  final bool selected;
  final bool hasWorkout;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = PlankLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final localizedDate = DateFormat.yMMMMd(
      recordLocaleName(context),
    ).format(date);
    final semanticLabel = hasWorkout
        ? l10n.semanticsCalendarWorkoutDate(localizedDate)
        : l10n.semanticsCalendarEmptyDate(localizedDate);

    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Material(
          color: selected ? colors.primaryContainer : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.tokens.radiusSm),
            side: selected
                ? BorderSide(color: colors.primary, width: 1.5)
                : BorderSide.none,
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: Text(
                    NumberFormat.decimalPattern(
                      recordLocaleName(context),
                    ).format(date.day),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? colors.onPrimaryContainer : null,
                    ),
                  ),
                ),
                if (hasWorkout)
                  PositionedDirectional(
                    bottom: 3,
                    child: Icon(
                      Icons.circle,
                      size: 6,
                      color: selected
                          ? colors.onPrimaryContainer
                          : colors.primary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
