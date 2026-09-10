import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:motionfit_squat/app/localization/generated/app_localizations.dart';
import 'package:motionfit_squat/app/theme/motionfit_tokens.dart';
import 'package:motionfit_squat/core/providers.dart';
import 'package:motionfit_squat/core/widgets/coach_ui.dart';
import 'package:motionfit_squat/core/widgets/responsive_page.dart';
import 'package:motionfit_squat/features/exercise/domain/exercise_type.dart';
import 'package:motionfit_squat/features/form_progress/application/form_progress_providers.dart';
import 'package:motionfit_squat/features/form_progress/domain/form_progress_series.dart';
import 'package:motionfit_squat/features/form_progress/presentation/widgets/form_progress_widgets.dart';
import 'package:motionfit_squat/features/records/presentation/widgets/record_components.dart';
import 'package:motionfit_squat/features/squat/presentation/rep_review_formatters.dart';

/// Form history for a single exercise.
class FormProgressDetailScreen extends ConsumerStatefulWidget {
  const FormProgressDetailScreen({required this.exerciseType, super.key});

  final ExerciseType exerciseType;

  @override
  ConsumerState<FormProgressDetailScreen> createState() =>
      _FormProgressDetailScreenState();
}

class _FormProgressDetailScreenState
    extends ConsumerState<FormProgressDetailScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(analyticsServiceProvider).screenView('form_progress_detail');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final series = ref.watch(formProgressSeriesProvider(widget.exerciseType));
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${formExerciseLabel(l10n, widget.exerciseType)} · '
          '${l10n.formProgressTitle}',
        ),
      ),
      body: SafeArea(
        top: false,
        child: ResponsivePage(
          child: switch (series) {
            AsyncData(:final value) when value.isEmpty => Center(
              child: Text(
                l10n.formProgressAutoEmptyBody,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            AsyncData(:final value) => _Content(series: value),
            AsyncError() => RecordErrorState(
              title: l10n.errorGenericTitle,
              body: l10n.formProgressLoadError,
              retryLabel: l10n.commonRetry,
              onRetry: () => ref.invalidate(
                formProgressSeriesProvider(widget.exerciseType),
              ),
            ),
            _ => RecordLoadingState(label: l10n.formProgressLoading),
          },
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.series});

  final FormProgressSeries series;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    );
    final posed = series.posedPoints;
    return ListView(
      padding: EdgeInsetsDirectional.only(bottom: context.tokens.spaceXl),
      children: [
        _Headline(series: series),
        SizedBox(height: context.tokens.spaceLg),
        CoachSectionHeader(title: l10n.formProgressTrend),
        SizedBox(height: context.tokens.space12),
        FormScoreTrend(series: series),
        SizedBox(height: context.tokens.spaceLg),
        _AccuracyRow(series: series),
        SizedBox(height: context.tokens.spaceXl),
        if (posed.length >= 2) ...[
          CoachSectionHeader(title: l10n.formProgressCompare),
          SizedBox(height: context.tokens.space12),
          _BeforeAfter(series: series, dateFormat: dateFormat),
          SizedBox(height: context.tokens.spaceMd),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.push(
                '/records/form-progress/${series.exerciseType.name}/timelapse',
              ),
              icon: const Icon(Icons.movie_rounded, size: 18),
              label: Text(l10n.formProgressTimelapse),
            ),
          ),
        ] else ...[
          CoachSectionHeader(title: l10n.formProgressCompare),
          SizedBox(height: context.tokens.spaceSm),
          CoachInsightPanel(
            icon: Icons.accessibility_new_rounded,
            title: l10n.formProgressNoPose,
            body: l10n.formProgressAutoHint,
            tone: CoachStatusTone.unavailable,
          ),
        ],
        SizedBox(height: context.tokens.spaceXl),
        CoachSectionHeader(title: l10n.formProgressCommonIssues),
        SizedBox(height: context.tokens.space12),
        _IssueList(series: series),
        SizedBox(height: context.tokens.spaceXl),
        CoachSectionHeader(
          title: l10n.formProgressSessions,
          subtitle: l10n.formProgressSessionCount(series.sessionCount),
        ),
        SizedBox(height: context.tokens.spaceSm),
        for (final point in series.points.reversed)
          FormProgressSessionRow(
            point: point,
            dayNumber: series.dayNumberOf(point),
            dateLabel: dateFormat.format(point.workoutDate),
            onTap: () => context.push(point.detailRoute),
          ),
      ],
    );
  }
}

class _Headline extends StatelessWidget {
  const _Headline({required this.series});

  final FormProgressSeries series;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CoachMetricStrip(
          emphasizeFirst: true,
          metrics: [
            CoachMetric(
              value: formatFormScore(series.latestScore),
              label: l10n.formProgressCurrentScore,
              icon: Icons.check_circle_outline_rounded,
            ),
            CoachMetric(
              value: formatFormScore(series.firstScore),
              label: l10n.formProgressFirstScore,
              icon: Icons.flag_outlined,
            ),
            CoachMetric(
              value: formatFormScore(series.bestScore),
              label: l10n.formProgressScoreLabel,
              icon: Icons.emoji_events_outlined,
            ),
          ],
        ),
        SizedBox(height: context.tokens.space12),
        FormScoreDeltaPill(delta: series.scoreDelta),
      ],
    );
  }
}

class _AccuracyRow extends StatelessWidget {
  const _AccuracyRow({required this.series});

  final FormProgressSeries series;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final resolved = series.resolvedIssues;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CoachInsightPanel(
          icon: Icons.center_focus_strong_rounded,
          title: l10n.formProgressAccuracy,
          body:
              '${formatAccuracy(series.firstAccuracy)} → '
              '${formatAccuracy(series.latestAccuracy)}',
          tone: CoachStatusTone.brand,
        ),
        SizedBox(height: context.tokens.space12),
        CoachInsightPanel(
          icon: Icons.auto_awesome_rounded,
          title: l10n.formProgressRecentImprovement,
          body: resolved.isEmpty
              ? l10n.formProgressNoImprovementYet
              : resolved
                    .map((issue) => repIssueCategory(l10n, issue))
                    .join(' · '),
          tone: resolved.isEmpty
              ? CoachStatusTone.unavailable
              : CoachStatusTone.positive,
        ),
      ],
    );
  }
}

class _BeforeAfter extends StatelessWidget {
  const _BeforeAfter({required this.series, required this.dateFormat});

  final FormProgressSeries series;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final posed = series.posedPoints;
    final firstPoint = posed.first;
    final latestPoint = posed.last;
    final firstPose = series.poseFor(firstPoint)!;
    final latestPose = series.poseFor(latestPoint)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: FormPoseCard(
            snapshot: firstPose,
            exerciseType: series.exerciseType,
            dayNumber: series.dayNumberOf(firstPoint),
            caption: dateFormat.format(firstPoint.workoutDate),
            issueLabel: firstPose.primaryIssue == null
                ? null
                : repIssueCategory(l10n, firstPose.primaryIssue),
          ),
        ),
        SizedBox(width: context.tokens.space12),
        Expanded(
          child: FormPoseCard(
            snapshot: latestPose,
            exerciseType: series.exerciseType,
            dayNumber: series.dayNumberOf(latestPoint),
            caption: dateFormat.format(latestPoint.workoutDate),
            issueLabel: latestPose.primaryIssue == null
                ? null
                : repIssueCategory(l10n, latestPose.primaryIssue),
          ),
        ),
      ],
    );
  }
}

class _IssueList extends StatelessWidget {
  const _IssueList({required this.series});

  final FormProgressSeries series;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final issues = series.topIssues.take(4).toList(growable: false);
    if (issues.isEmpty) {
      return Text(
        l10n.formProgressNoImprovementYet,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
      );
    }
    final maximum = issues.first.count;
    return Column(
      children: [
        for (final tally in issues) ...[
          Padding(
            padding: EdgeInsets.only(bottom: context.tokens.space12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        repIssueCategory(l10n, tally.issue),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      l10n.formProgressIssueOccurrences(tally.count),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.tokens.spaceXs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: maximum == 0 ? 0 : tally.count / maximum,
                    minHeight: 6,
                    backgroundColor: colors.surfaceContainerHighest,
                    color: context.tokens.warning,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
