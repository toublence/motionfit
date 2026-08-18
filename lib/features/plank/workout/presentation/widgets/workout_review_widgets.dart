import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motionfit_squat/features/plank/localization/generated/plank_localizations.dart';
import 'package:motionfit_squat/app/theme/motionfit_tokens.dart';
import 'package:motionfit_squat/core/widgets/coach_ui.dart';
import 'package:motionfit_squat/features/plank/workout/domain/models/rep_analysis.dart';
import 'package:motionfit_squat/features/plank/workout/domain/models/workout_enums.dart';
import 'package:motionfit_squat/features/plank/workout/presentation/rep_review_formatters.dart';

class WorkoutOverviewHero extends StatelessWidget {
  const WorkoutOverviewHero({
    required this.eyebrow,
    required this.totalReps,
    required this.setsLabel,
    required this.activeTimeLabel,
    this.formScore,
    super.key,
  });

  final String eyebrow;
  final int totalReps;
  final String? setsLabel;
  final String activeTimeLabel;
  final double? formScore;

  @override
  Widget build(BuildContext context) {
    final l10n = PlankLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MotionEyebrow(eyebrow, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                NumberFormat.decimalPattern(l10n.localeName).format(totalReps),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  height: .92,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  [
                    l10n.completeTotalReps,
                    ?setsLabel,
                    activeTimeLabel,
                    if (formScore != null)
                      '${l10n.formScore} '
                          '${l10n.formScoreValue(formScore!.round())}',
                  ].join('  ·  '),
                  maxLines: 1,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
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
    final l10n = PlankLocalizations.of(context);
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
        if (analyses.isNotEmpty) ...[
          const SizedBox(height: 14),
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
        const SizedBox(height: 20),
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
