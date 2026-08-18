import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:motionfit_squat/features/pushup/localization/generated/pushup_localizations.dart';
import 'package:motionfit_squat/app/theme/motionfit_tokens.dart';
import 'package:motionfit_squat/core/ads/bottom_native_ad.dart';
import 'package:motionfit_squat/core/utils/localized_formatters.dart';
import 'package:motionfit_squat/features/pushup/providers.dart';
import 'package:motionfit_squat/core/widgets/coach_ui.dart';
import 'package:motionfit_squat/core/widgets/responsive_page.dart';
import 'package:motionfit_squat/features/pushup/records/application/records_providers.dart';
import 'package:motionfit_squat/features/pushup/records/domain/workout_session_details.dart';
import 'package:motionfit_squat/features/pushup/records/presentation/widgets/record_components.dart';
import 'package:motionfit_squat/features/pushup/records/presentation/widgets/record_formatters.dart';
import 'package:motionfit_squat/features/pushup/domain/models/rep_analysis.dart';
import 'package:motionfit_squat/features/pushup/presentation/rep_review_formatters.dart';
import 'package:motionfit_squat/features/pushup/presentation/widgets/rep_timeline_section.dart';
import 'package:motionfit_squat/features/pushup/domain/models/workout_enums.dart';

class WorkoutSessionDetailScreen extends ConsumerStatefulWidget {
  const WorkoutSessionDetailScreen({required this.sessionId, super.key});

  final String sessionId;

  @override
  ConsumerState<WorkoutSessionDetailScreen> createState() =>
      _WorkoutSessionDetailScreenState();
}

class _WorkoutSessionDetailScreenState
    extends ConsumerState<WorkoutSessionDetailScreen> {
  bool _timelineAnalyticsLogged = false;

  @override
  Widget build(BuildContext context) {
    final l10n = PushupLocalizations.of(context);
    final details = ref.watch(sessionDetailsProvider(widget.sessionId));
    final loaded = switch (details) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (!_timelineAnalyticsLogged &&
        loaded != null &&
        loaded.repAnalyses.isNotEmpty) {
      _timelineAnalyticsLogged = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(analyticsServiceProvider)
            .repTimelineViewed(
              workoutSessionId: loaded.session.analyticsSessionId,
            );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.detailTitle),
        actions: [
          if (loaded?.session.videoPath != null)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete_video') {
                  unawaited(_deleteVideo());
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'delete_video',
                  child: Text(l10n.deleteWorkoutVideo),
                ),
              ],
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ResponsivePage(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 20, 20),
          child: switch (details) {
            AsyncData(value: final value?) => _DetailContent(details: value),
            AsyncData() || AsyncError() => RecordErrorState(
              title: l10n.errorGenericTitle,
              body: l10n.recordsLoadError,
              retryLabel: l10n.commonRetry,
              onRetry: () =>
                  ref.invalidate(sessionDetailsProvider(widget.sessionId)),
            ),
            _ => RecordLoadingState(label: l10n.recordsLoading),
          },
        ),
      ),
    );
  }

  Future<void> _deleteVideo() async {
    final l10n = PushupLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteWorkoutVideoTitle),
        content: Text(l10n.deleteWorkoutVideoBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref
          .read(workoutRepositoryProvider)
          .deleteWorkoutVideo(widget.sessionId);
      ref
        ..invalidate(sessionDetailsProvider(widget.sessionId))
        ..invalidate(allSessionsProvider)
        ..invalidate(todaySessionsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.workoutVideoDeleted)));
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.errorGenericBody)));
    }
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.details});

  final WorkoutSessionDetails details;

  @override
  Widget build(BuildContext context) {
    final l10n = PushupLocalizations.of(context);
    final session = details.session;
    return ListView(
      children: [
        _WorkoutDetailSummary(
          dateLabel:
              '${formatRecordDate(context, session.startedAt)} · '
              '${formatRecordTime(context, session.startedAt)}',
          totalReps: session.totalReps,
          completedSets: session.completedSetCount,
          activeSeconds: session.activeDurationSeconds,
          formScore: details.averageFormScore,
        ),
        const SizedBox(height: 24),
        const MotionRule(),
        const SizedBox(height: 28),
        _WorkoutDetailCoaching(
          analyses: details.repAnalyses,
          strengths: _historyStrengths(l10n, details.repAnalyses),
        ),
        const NativeAdSection(placement: NativeAdPlacement.workoutDetail),
        if (details.repAnalyses.isNotEmpty) ...[
          SizedBox(height: context.tokens.spaceMd),
          RepTimelineSection(
            key: const ValueKey('history-rep-timeline'),
            sessionId: session.id,
            analyses: details.repAnalyses,
            videoPath: session.videoPath,
          ),
        ],
      ],
    );
  }
}

class _WorkoutDetailCoaching extends StatelessWidget {
  const _WorkoutDetailCoaching({
    required this.analyses,
    required this.strengths,
  });

  final List<RepAnalysis> analyses;
  final List<String> strengths;

  @override
  Widget build(BuildContext context) {
    final l10n = PushupLocalizations.of(context);
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
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CoachSectionHeader(title: l10n.todayCoaching),
        const SizedBox(height: 16),
        if (mainIssue != null && representative != null) ...[
          Text(
            '⚠  ${repIssueCategory(l10n, mainIssue.key)}',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.coachingIssueFrequency(
              analyses.length,
              mainIssue.value,
              repIssueLabel(l10n, mainIssue.key),
            ),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          Text(
            repFeedback(l10n, representative),
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
          ),
        ] else
          Text(
            '✓  ${l10n.repFeedbackGood}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        if (strengths.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            '✓  ${strengths.first}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _WorkoutDetailSummary extends StatelessWidget {
  const _WorkoutDetailSummary({
    required this.dateLabel,
    required this.totalReps,
    required this.completedSets,
    required this.activeSeconds,
    required this.formScore,
  });

  final String dateLabel;
  final int totalReps;
  final int completedSets;
  final int activeSeconds;
  final double? formScore;

  @override
  Widget build(BuildContext context) {
    final l10n = PushupLocalizations.of(context);
    final numberFormat = NumberFormat.decimalPattern(l10n.localeName);
    final primaryStyle = Theme.of(
      context,
    ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800);
    final secondaryStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
    );
    final duration = activeSeconds < Duration.secondsPerMinute
        ? l10n.unitSeconds(activeSeconds)
        : LocalizedFormatters.timer(
            Duration(seconds: activeSeconds),
            l10n.localeName,
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MotionEyebrow(
          dateLabel,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 9),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${numberFormat.format(totalReps)} ${l10n.navPushup}',
                  style: primaryStyle,
                ),
                TextSpan(
                  text: '  ·  ${l10n.unitSets(completedSets)}  ·  $duration',
                  style: secondaryStyle,
                ),
                if (formScore != null)
                  TextSpan(
                    text:
                        '  ·  ${l10n.formShort} '
                        '${numberFormat.format(formScore!.round())}',
                    style: secondaryStyle,
                  ),
              ],
            ),
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

List<String> _historyStrengths(
  PushupLocalizations l10n,
  List<RepAnalysis> analyses,
) {
  bool consistentlyGood(RepQuality Function(RepAnalysis) select) {
    final assessed = analyses
        .map(select)
        .where((quality) => quality != RepQuality.unavailable)
        .toList();
    return assessed.isNotEmpty &&
        assessed.every((quality) => quality == RepQuality.good);
  }

  return [
    if (consistentlyGood((analysis) => analysis.depthQuality))
      l10n.formStrengthDepth,
    if (consistentlyGood((analysis) => analysis.upperBodyQuality))
      l10n.formStrengthControl,
    if (consistentlyGood((analysis) => analysis.kneeAlignmentQuality))
      l10n.formStrengthBalance,
  ];
}
