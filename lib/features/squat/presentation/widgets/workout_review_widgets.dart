import 'package:flutter/material.dart';
import 'package:motionfit_squat/app/localization/generated/app_localizations.dart';
import 'package:motionfit_squat/app/theme/motionfit_tokens.dart';
import 'package:motionfit_squat/core/widgets/coach_ui.dart';
import 'package:motionfit_squat/features/squat/domain/models/rep_analysis.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_enums.dart';
import 'package:motionfit_squat/features/squat/presentation/rep_review_formatters.dart';

class WorkoutOverviewHero extends StatelessWidget {
  const WorkoutOverviewHero({
    required this.eyebrow,
    required this.totalReps,
    required this.exerciseLabel,
    required this.weeklyWorkoutDays,
    required this.firstWorkout,
    required this.weeklyRemainingLabel,
    super.key,
  });

  final String eyebrow;
  final int totalReps;
  final String exerciseLabel;
  final int weeklyWorkoutDays;
  final bool firstWorkout;
  final String weeklyRemainingLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MotionEyebrow(
          firstWorkout ? '$eyebrow!' : eyebrow,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 8),
        Text(
          '$exerciseLabel ${l10n.unitReps(totalReps)}',
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                child: Text(
                  l10n.challengeThisWeekProgress(weeklyWorkoutDays, 3),
                  key: ValueKey(weeklyWorkoutDays),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(3, (index) {
                  final completed = index < weeklyWorkoutDays;
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      width: 28,
                      height: 7,
                      decoration: BoxDecoration(
                        color: completed
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 7),
              Text(
                weeklyWorkoutDays >= 3
                    ? l10n.challengeTodayCompleted
                    : firstWorkout
                    ? l10n.recordsFirstWeek
                    : weeklyRemainingLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class WorkoutFormReview extends StatelessWidget {
  const WorkoutFormReview({
    required this.analyses,
    required this.strengths,
    super.key,
  });

  final List<RepAnalysis> analyses;
  final List<String> strengths;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final goodCount = analyses.where(_isPositive).length;
    final attentionCount = analyses
        .where((item) => item.needsImprovement)
        .length;
    final unavailableCount = analyses.length - goodCount - attentionCount;
    final issueCounts = <FormIssue, int>{};
    for (final analysis in analyses) {
      final issue = analysis.primaryIssue;
      if (issue != null) issueCounts[issue] = (issueCounts[issue] ?? 0) + 1;
    }
    final mainIssue = issueCounts.entries.fold<MapEntry<FormIssue, int>?>(
      null,
      (best, entry) => best == null || entry.value > best.value ? entry : best,
    );
    final representative = mainIssue == null
        ? null
        : analyses.firstWhere(
            (analysis) => analysis.primaryIssue == mainIssue.key,
          );
    final hasPositive = goodCount > 0;
    final tone = mainIssue != null
        ? CoachStatusTone.attention
        : hasPositive
        ? CoachStatusTone.positive
        : CoachStatusTone.unavailable;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CoachSectionHeader(title: l10n.completeFormSummary),
        const SizedBox(height: 14),
        MotionEyebrow(l10n.formReviewMainIssue),
        const SizedBox(height: 10),
        CoachInsightPanel(
          icon: mainIssue != null
              ? Icons.bolt_rounded
              : hasPositive
              ? Icons.check_rounded
              : Icons.remove_rounded,
          title: mainIssue != null
              ? '${repIssueCategory(l10n, mainIssue.key)} · '
                    '${l10n.unitReps(mainIssue.value)}'
              : hasPositive
              ? l10n.completeStrengths
              : l10n.repResultNotAssessed,
          body: representative != null
              ? repFeedback(l10n, representative)
              : hasPositive
              ? l10n.repFeedbackGood
              : l10n.commonNotAvailable,
          tone: tone,
          bodyMaxLines: 2,
        ),
        if (strengths.isNotEmpty) ...[
          const SizedBox(height: 18),
          MotionEyebrow(l10n.completeStrengths),
          const SizedBox(height: 8),
          for (final strength in strengths)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_rounded,
                    size: 17,
                    color: context.tokens.success,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(strength)),
                ],
              ),
            ),
        ],
        if (analyses.isNotEmpty) ...[
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _ReviewCount(
                  count: goodCount,
                  label: l10n.repResultGood,
                  tone: CoachStatusTone.positive,
                ),
              ),
              Expanded(
                child: _ReviewCount(
                  count: attentionCount,
                  label: l10n.repResultNeedsAttention,
                  tone: CoachStatusTone.attention,
                ),
              ),
              Expanded(
                child: _ReviewCount(
                  count: unavailableCount,
                  label: l10n.repResultNotAssessed,
                  tone: CoachStatusTone.unavailable,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  static bool _isPositive(RepAnalysis analysis) =>
      analysis.result == RepAnalysisResult.good ||
      analysis.result == RepAnalysisResult.improved;
}

class _ReviewCount extends StatelessWidget {
  const _ReviewCount({
    required this.count,
    required this.label,
    required this.tone,
  });

  final int count;
  final String label;
  final CoachStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final color = coachToneColor(context, tone);
    return Semantics(
      label: '$label $count',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$count',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
