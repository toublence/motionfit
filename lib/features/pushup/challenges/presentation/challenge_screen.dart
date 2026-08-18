import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:motionfit_squat/features/pushup/localization/generated/pushup_localizations.dart';
import 'package:motionfit_squat/features/pushup/providers.dart';
import 'package:motionfit_squat/core/notifications/notification_service.dart';
import 'package:motionfit_squat/core/utils/localized_formatters.dart';
import 'package:motionfit_squat/core/widgets/responsive_page.dart';
import 'package:motionfit_squat/core/widgets/coach_ui.dart';
import 'package:motionfit_squat/features/pushup/challenges/application/challenge_controller.dart';
import 'package:motionfit_squat/features/pushup/challenges/domain/challenge.dart';
import 'package:motionfit_squat/features/settings/application/preferences_controller.dart';
import 'package:motionfit_squat/features/pushup/application/workout_preparation.dart';
import 'package:motionfit_squat/features/pushup/presentation/workout_preparation_launcher.dart';

class ChallengeScreen extends ConsumerStatefulWidget {
  const ChallengeScreen({super.key});

  @override
  ConsumerState<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends ConsumerState<ChallengeScreen> {
  bool _viewLogged = false;
  bool _recommendationLogged = false;

  @override
  void initState() {
    super.initState();
    ref.read(analyticsServiceProvider).screenView('challenge');
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final wasVisible = await ref
          .read(challengeDashboardProvider.notifier)
          .markBadgeSeen();
      if (wasVisible && mounted) {
        ref.read(analyticsServiceProvider).challengeTabBadgeViewed();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = ref.watch(challengeDashboardProvider);
    if (dashboard case AsyncData(:final value)) {
      if (!_viewLogged) {
        _viewLogged = true;
        ref
            .read(analyticsServiceProvider)
            .challengeTabViewed(
              hasActiveChallenge: value.active != null,
              activeChallengeType: value.active?.challenge.type.name ?? 'none',
              daysSinceInstall: value.daysSinceInstall,
              hasWorkoutHistory: value.hasWorkoutHistory,
            );
      }
      if (value.active == null &&
          value.hasWorkoutHistory &&
          !value.recommendationDismissed &&
          !_recommendationLogged) {
        _recommendationLogged = true;
        ref
            .read(analyticsServiceProvider)
            .challengeRecommendationViewed(
              recommendedType: value.recommendedType.name,
              recommendedLevel: value.recommendedLevel,
              referenceWorkoutReps: value.referenceWorkoutReps,
            );
      }
    }
    return Scaffold(
      body: SafeArea(
        child: ResponsivePage(
          child: switch (dashboard) {
            AsyncData(:final value) => RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(challengeDashboardProvider);
                await ref.read(challengeDashboardProvider.future);
              },
              child: _DashboardList(dashboard: value),
            ),
            AsyncError() => _ErrorView(
              onRetry: () => ref.invalidate(challengeDashboardProvider),
            ),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
      ),
    );
  }
}

class _DashboardList extends ConsumerWidget {
  const _DashboardList({required this.dashboard});

  final ChallengeDashboard dashboard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = PushupLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final useColumns = constraints.maxWidth >= 600;
        String? recommendationReason(ChallengeType type) {
          if (!dashboard.hasWorkoutHistory ||
              dashboard.recommendationDismissed ||
              type != dashboard.recommendedType) {
            return null;
          }
          return dashboard.hasWorkoutHistory
              ? l10n.challengeRecommendationFromWorkout(
                  dashboard.referenceWorkoutReps,
                )
              : l10n.challengeRecommendationDefault;
        }

        final choices = [
          _ChallengeChoiceCard(
            type: ChallengeType.sevenDay,
            title: l10n.challengeSevenDayTitle,
            description: l10n.challengeSevenDayDescription,
            compactSummary: l10n.challengeSevenDaySummary,
            facts: [
              l10n.challengeDurationDays(7),
              l10n.challengeLevelGoals,
              l10n.challengeSevenDayEveryDay,
              l10n.challengeDailyGoal,
            ],
            buttonLabel: l10n.challengeSevenDayStart,
            recommended:
                dashboard.hasWorkoutHistory &&
                !dashboard.recommendationDismissed &&
                dashboard.recommendedType == ChallengeType.sevenDay,
            recommendationReason: recommendationReason(ChallengeType.sevenDay),
            compact: !useColumns,
            onPressed: () => _selectChallenge(
              context,
              ref,
              ChallengeType.sevenDay,
              dashboard.hasWorkoutHistory &&
                  !dashboard.recommendationDismissed &&
                  dashboard.recommendedType == ChallengeType.sevenDay,
            ),
            onDismissRecommendation: () =>
                _dismissRecommendation(ref, dashboard.recommendedType),
          ),
          _ChallengeChoiceCard(
            type: ChallengeType.cumulative,
            title: l10n.challengeCumulativeTitle,
            description: l10n.challengeCumulativeDescription,
            compactSummary: l10n.challengeCumulativeSummary,
            facts: [
              l10n.challengePreset200,
              l10n.challengePreset500,
              l10n.challengeCustomGoal,
              l10n.challengeRestWithoutReset,
            ],
            buttonLabel: l10n.challengeCumulativeStart,
            recommended:
                dashboard.hasWorkoutHistory &&
                !dashboard.recommendationDismissed &&
                dashboard.recommendedType == ChallengeType.cumulative,
            recommendationReason: recommendationReason(
              ChallengeType.cumulative,
            ),
            compact: !useColumns,
            onPressed: () => _selectChallenge(
              context,
              ref,
              ChallengeType.cumulative,
              dashboard.hasWorkoutHistory &&
                  !dashboard.recommendationDismissed &&
                  dashboard.recommendedType == ChallengeType.cumulative,
            ),
            onDismissRecommendation: () =>
                _dismissRecommendation(ref, dashboard.recommendedType),
          ),
        ];
        choices.sort((a, b) {
          if (a.recommended == b.recommended) return 0;
          return a.recommended ? -1 : 1;
        });
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            Text(
              l10n.challengeTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 2),
            Text(
              l10n.challengeSubtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            if (dashboard.active != null)
              _ActiveChallengeCard(progress: dashboard.active!)
            else ...[
              if (useColumns)
                SizedBox(
                  height: 290,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var index = 0; index < choices.length; index++) ...[
                        Expanded(child: choices[index]),
                        if (index < choices.length - 1)
                          const SizedBox(width: 8),
                      ],
                    ],
                  ),
                )
              else
                ...choices,
            ],
            const SizedBox(height: 6),
            _HistorySummary(
              history: dashboard.history,
              emptyText: l10n.challengeHistoryEmpty,
            ),
          ],
        );
      },
    );
  }
}

class _HistorySummary extends StatelessWidget {
  const _HistorySummary({required this.history, required this.emptyText});

  final List<ChallengeProgress> history;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    final l10n = PushupLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        dense: true,
        visualDensity: const VisualDensity(vertical: -3),
        leading: const Icon(Icons.history_rounded),
        title: Text(l10n.challengeHistoryTitle),
        subtitle: history.isEmpty ? Text(emptyText) : null,
        trailing: history.isEmpty
            ? null
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Badge(label: Text('${history.length}')),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
        onTap: history.isEmpty
            ? null
            : () => showModalBottomSheet<void>(
                context: context,
                showDragHandle: true,
                isScrollControlled: true,
                builder: (context) => SafeArea(
                  child: FractionallySizedBox(
                    heightFactor: .72,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      children: [
                        Text(
                          l10n.challengeHistoryTitle,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        ...history.map(
                          (progress) => _HistoryTile(progress: progress),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _ChallengeChoiceCard extends StatelessWidget {
  const _ChallengeChoiceCard({
    required this.type,
    required this.title,
    required this.description,
    required this.compactSummary,
    required this.facts,
    required this.buttonLabel,
    required this.recommended,
    required this.recommendationReason,
    required this.compact,
    required this.onPressed,
    required this.onDismissRecommendation,
  });

  final ChallengeType type;
  final String title;
  final String description;
  final String compactSummary;
  final List<String> facts;
  final String buttonLabel;
  final bool recommended;
  final String? recommendationReason;
  final bool compact;
  final VoidCallback onPressed;
  final VoidCallback onDismissRecommendation;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      border: BorderDirectional(
        start: recommended
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 3)
            : BorderSide.none,
        bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
    ),
    child: Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        recommended ? 14 : 0,
        compact ? 12 : 16,
        0,
        10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (recommended) ...[
            Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 5),
                Text(
                  PushupLocalizations.of(context).challengeRecommended,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: PushupLocalizations.of(context).commonClose,
                  visualDensity: VisualDensity.compact,
                  onPressed: onDismissRecommendation,
                  icon: const Icon(Icons.close_rounded, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (recommendationReason != null) ...[
              Text(
                recommendationReason!,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 4),
            ],
          ],
          Row(
            children: [
              Icon(challengeIcon(type), size: compact ? 20 : 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            compact ? compactSummary : description,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (!compact) ...[
            const SizedBox(height: 8),
            ...facts.map(
              (fact) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(
                      child: Text(
                        fact,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
          ] else
            const SizedBox(height: 2),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              style: TextButton.styleFrom(
                visualDensity: const VisualDensity(
                  horizontal: -2,
                  vertical: -4,
                ),
                minimumSize: const Size(44, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: onPressed,
              child: Text(
                compact
                    ? PushupLocalizations.of(context).commonStart
                    : buttonLabel,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ActiveChallengeCard extends ConsumerWidget {
  const _ActiveChallengeCard({required this.progress});

  final ChallengeProgress progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = PushupLocalizations.of(context);
    final challenge = progress.challenge;
    final statusLines = switch (challenge.type) {
      ChallengeType.sevenDay => [
        l10n.challengeDayNumber(progress.currentDay),
        progress.isRecoveryDay
            ? l10n.challengeRecoveryDay
            : l10n.challengeTodayProgress(
                progress.todayReps,
                progress.todayGoal,
              ),
        progress.isRecoveryDay
            ? l10n.challengeRestToday
            : progress.isTodayGoalCompleted
            ? l10n.challengeTodayCompleted
            : l10n.challengeRepsRemaining(progress.remainingReps),
      ],
      ChallengeType.weekly => [
        l10n.challengeWeekNumber(progress.currentWeek),
        l10n.challengeThisWeekProgress(progress.thisWeekWorkoutDays, 3),
        l10n.challengeOverallDays(progress.countedWorkoutDays, 12),
      ],
      ChallengeType.cumulative => [
        l10n.challengeRepsProgress(progress.totalReps, challenge.targetReps),
        l10n.challengeRepsRemaining(progress.remainingReps),
        l10n.challengeDaysRemaining(progress.remainingDays),
      ],
    };
    final goalHeadline = switch (challenge.type) {
      ChallengeType.sevenDay =>
        progress.isRecoveryDay
            ? l10n.challengeRecoveryDay
            : l10n.unitReps(progress.todayGoal),
      ChallengeType.weekly => l10n.challengeThisWeekProgress(
        progress.thisWeekWorkoutDays,
        3,
      ),
      ChallengeType.cumulative => l10n.challengeRepsRemaining(
        progress.remainingReps,
      ),
    };
    final heroProgress =
        challenge.type == ChallengeType.sevenDay && progress.todayGoal > 0
        ? (progress.todayReps / progress.todayGoal).clamp(0, 1).toDouble()
        : progress.progress;
    final nextGoal =
        challenge.type == ChallengeType.sevenDay &&
            progress.currentDay < challenge.dailyGoals.length
        ? challenge.dailyGoals[progress.currentDay]
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MotionEyebrow(
          l10n.challengeActive,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 8),
        Text(
          challengeName(l10n, challenge.type),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 24),
        Text(
          goalHeadline,
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(fontSize: 38),
        ),
        const SizedBox(height: 14),
        LinearProgressIndicator(value: heroProgress),
        const SizedBox(height: 6),
        Text(
          l10n.challengePercent((heroProgress * 100).round()),
          textAlign: TextAlign.end,
        ),
        const SizedBox(height: 10),
        ...statusLines
            .take(2)
            .map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(line),
              ),
            ),
        const SizedBox(height: 10),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: FilledButton.icon(
            onPressed: progress.isRecoveryDay || progress.isTodayGoalCompleted
                ? null
                : () => startChallengeWorkout(context, ref, progress),
            icon: Icon(
              progress.isTodayGoalCompleted
                  ? Icons.check_rounded
                  : Icons.play_arrow_rounded,
            ),
            label: Text(
              progress.isTodayGoalCompleted
                  ? l10n.challengeTodayCompleted
                  : challenge.type == ChallengeType.cumulative
                  ? l10n.challengePushupStart
                  : l10n.challengeTodayWorkoutStart,
            ),
          ),
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton(
            onPressed: () => context.push('/challenge/pushup/${challenge.id}'),
            child: Text(l10n.challengeViewDetails),
          ),
        ),
        const SizedBox(height: 20),
        const MotionRule(),
        const SizedBox(height: 18),
        _ChallengeWeekStrip(progress: progress),
        if (nextGoal != null) ...[
          const SizedBox(height: 20),
          const MotionRule(),
          const SizedBox(height: 18),
          MotionEyebrow(l10n.challengeNext),
          const SizedBox(height: 6),
          Text(
            '${l10n.challengeDayNumber(progress.currentDay + 1)}  ·  '
            '${nextGoal == 0 ? l10n.challengeRecoveryDay : l10n.unitReps(nextGoal)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ],
    );
  }
}

class _ChallengeWeekStrip extends StatelessWidget {
  const _ChallengeWeekStrip({required this.progress});

  final ChallengeProgress progress;

  @override
  Widget build(BuildContext context) {
    final l10n = PushupLocalizations.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(Duration(days: today.weekday - 1));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MotionEyebrow(l10n.recordsWeeklySummary),
        const SizedBox(height: 12),
        Row(
          children: List.generate(7, (index) {
            final day = start.add(Duration(days: index));
            final reps = progress.dailyReps[day] ?? 0;
            final isToday = day == today;
            return Expanded(
              child: Column(
                children: [
                  Text(
                    DateFormat.E(l10n.localeName).format(day),
                    maxLines: 1,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 7),
                  Icon(
                    reps > 0
                        ? Icons.check_rounded
                        : isToday
                        ? Icons.circle
                        : Icons.remove_rounded,
                    size: isToday && reps == 0 ? 8 : 16,
                    color: reps > 0 || isToday
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outlineVariant,
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _HistoryTile extends ConsumerWidget {
  const _HistoryTile({required this.progress});

  final ChallengeProgress progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = PushupLocalizations.of(context);
    final challenge = progress.challenge;
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          onTap: () => context.push('/challenge/pushup/${challenge.id}'),
          leading: Icon(challengeIcon(challenge.type)),
          title: Text(challengeName(l10n, challenge.type)),
          subtitle: Text(
            '${challengeStatusName(l10n, challenge.status)} · '
            '${l10n.challengePercent((progress.progress * 100).round())} · '
            '${l10n.unitReps(progress.totalReps)}',
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'restart') {
                await _runMutation(
                  context,
                  () => ref
                      .read(challengeDashboardProvider.notifier)
                      .restart(challenge),
                );
              } else if (value == 'delete') {
                await ref
                    .read(challengeDashboardProvider.notifier)
                    .delete(challenge.id);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'restart',
                child: Text(l10n.challengeRestart),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text(l10n.challengeDeleteHistory),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}

void _dismissRecommendation(WidgetRef ref, ChallengeType type) {
  ref
      .read(analyticsServiceProvider)
      .challengeRecommendationDismissed(recommendedType: type.name);
  unawaited(
    ref.read(challengeDashboardProvider.notifier).dismissRecommendation(),
  );
}

Future<void> _selectChallenge(
  BuildContext context,
  WidgetRef ref,
  ChallengeType type,
  bool recommended,
) async {
  ref
      .read(analyticsServiceProvider)
      .challengeCardSelected(
        challengeType: type.name,
        isRecommended: recommended,
      );
  final controller = ref.read(challengeDashboardProvider.notifier);
  if (type == ChallengeType.sevenDay) {
    final firstDayGoal = await showDialog<int>(
      context: context,
      builder: (_) => const _SevenDayGoalDialog(),
    );
    if (firstDayGoal != null && context.mounted) {
      final started = await _runMutation(
        context,
        () => controller.startSevenDay(firstDayGoal: firstDayGoal),
      );
      if (started && context.mounted) {
        final progress = ref.read(challengeDashboardProvider).value?.active;
        if (progress != null) {
          await startChallengeWorkout(context, ref, progress);
        }
      }
    }
    return;
  }
  final selection = await showDialog<(int, int)>(
    context: context,
    builder: (_) => const _CumulativeDialog(),
  );
  if (selection != null && context.mounted) {
    final started = await _runMutation(
      context,
      () => controller.startCumulative(
        durationDays: selection.$1,
        targetReps: selection.$2,
      ),
    );
    if (started && context.mounted) {
      final progress = ref.read(challengeDashboardProvider).value?.active;
      if (progress != null) {
        await startChallengeWorkout(context, ref, progress);
      }
    }
  }
}

class _SevenDayGoalDialog extends StatefulWidget {
  const _SevenDayGoalDialog();

  @override
  State<_SevenDayGoalDialog> createState() => _SevenDayGoalDialogState();
}

class _SevenDayGoalDialogState extends State<_SevenDayGoalDialog> {
  late final TextEditingController _controller;
  int? _firstGoal = 10;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '10');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = PushupLocalizations.of(context);
    final firstGoal = _firstGoal;
    final valid = firstGoal != null && firstGoal >= 1 && firstGoal <= 70;
    return AlertDialog(
      title: Text(l10n.challengeSevenDaySettings),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.challengeSevenDaySettingsDescription),
          const SizedBox(height: 14),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: l10n.challengeFirstDayGoal,
              errorText: valid ? null : l10n.validationRange(1, 70),
            ),
            onChanged: (value) {
              setState(() => _firstGoal = int.tryParse(value));
            },
          ),
          const SizedBox(height: 14),
          if (firstGoal != null && valid)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                l10n.challengeSevenDayPreview(firstGoal, firstGoal + 30),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: valid ? () => context.pop(firstGoal) : null,
          child: Text(l10n.commonStart),
        ),
      ],
    );
  }
}

class _CumulativeDialog extends StatefulWidget {
  const _CumulativeDialog();

  @override
  State<_CumulativeDialog> createState() => _CumulativeDialogState();
}

class _CumulativeDialogState extends State<_CumulativeDialog> {
  int days = 7;
  int reps = 200;

  @override
  Widget build(BuildContext context) {
    final l10n = PushupLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.challengeCumulativeSettings),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int>(
            initialValue: days,
            decoration: InputDecoration(labelText: l10n.challengeDurationLabel),
            items: [7, 14, 21, 28]
                .map(
                  (value) => DropdownMenuItem(
                    value: value,
                    child: Text(l10n.challengeDurationDays(value)),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => days = value ?? days),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: reps,
            decoration: InputDecoration(labelText: l10n.challengeGoalLabel),
            items: [200, 300, 500, 750, 1000]
                .map(
                  (value) => DropdownMenuItem(
                    value: value,
                    child: Text(l10n.unitReps(value)),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => reps = value ?? reps),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () => context.pop((days, reps)),
          child: Text(l10n.commonStart),
        ),
      ],
    );
  }
}

class ChallengeDetailScreen extends ConsumerWidget {
  const ChallengeDetailScreen({required this.challengeId, super.key});

  final String challengeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = PushupLocalizations.of(context);
    final dashboard = ref.watch(challengeDashboardProvider);
    final progress = ref.watch(challengeProgressProvider(challengeId));
    if (dashboard.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (progress == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.challengeNotFound)),
      );
    }
    final challenge = progress.challenge;
    final dateFormat = DateFormat.yMMMd(l10n.localeName);
    return Scaffold(
      appBar: AppBar(title: Text(challengeName(l10n, challenge.type))),
      body: SafeArea(
        top: false,
        child: ResponsivePage(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              LinearProgressIndicator(value: progress.progress),
              const SizedBox(height: 8),
              Text(
                l10n.challengePercent((progress.progress * 100).round()),
                textAlign: TextAlign.end,
              ),
              const SizedBox(height: 12),
              _DetailRow(
                label: l10n.challengePeriod,
                value:
                    '${dateFormat.format(challenge.startedAt)} – '
                    '${dateFormat.format(challenge.endsAt)}',
              ),
              _DetailRow(
                label: l10n.challengeStatus,
                value: challengeStatusName(l10n, challenge.status),
              ),
              _DetailRow(
                label: l10n.challengeTotalReps,
                value: l10n.unitReps(progress.totalReps),
              ),
              _DetailRow(
                label: l10n.challengeWorkoutDays,
                value: l10n.challengeDaysCount(progress.workoutDays),
              ),
              _DetailRow(
                label: l10n.challengeTotalTime,
                value: LocalizedFormatters.timer(
                  Duration(seconds: progress.totalActiveSeconds),
                  l10n.localeName,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.challengeSchedule,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ..._scheduleRows(context, progress),
              const SizedBox(height: 10),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.challengeNotifications),
                subtitle: Text(l10n.challengeNotificationsDescription),
                value: challenge.notificationEnabled,
                onChanged: challenge.status == ChallengeStatus.active
                    ? (value) => _setChallengeNotification(
                        context,
                        ref,
                        challenge.id,
                        value,
                      )
                    : null,
              ),
              if (challenge.status == ChallengeStatus.active) ...[
                FilledButton.icon(
                  onPressed:
                      progress.isRecoveryDay || progress.isTodayGoalCompleted
                      ? null
                      : () => startChallengeWorkout(context, ref, progress),
                  icon: Icon(
                    progress.isTodayGoalCompleted
                        ? Icons.check_rounded
                        : Icons.play_arrow_rounded,
                  ),
                  label: Text(
                    progress.isTodayGoalCompleted
                        ? l10n.challengeTodayCompleted
                        : l10n.challengeTodayWorkoutStart,
                  ),
                ),
                TextButton(
                  onPressed: () => _confirmCancel(context, ref, challenge.id),
                  child: Text(l10n.challengeCancel),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

List<Widget> _scheduleRows(BuildContext context, ChallengeProgress progress) {
  final l10n = PushupLocalizations.of(context);
  final challenge = progress.challenge;
  if (challenge.type == ChallengeType.sevenDay) {
    return List.generate(challenge.dailyGoals.length, (index) {
      final startedAt = challenge.startedAt.toLocal();
      final date = DateTime(
        startedAt.year,
        startedAt.month,
        startedAt.day + index,
      );
      final goal = challenge.dailyGoals[index];
      return _DetailRow(
        label: l10n.challengeDayNumber(index + 1),
        value: goal == 0
            ? l10n.challengeRecoveryDay
            : l10n.challengeRepsProgress(progress.dailyReps[date] ?? 0, goal),
      );
    });
  }
  if (challenge.type == ChallengeType.weekly) {
    return [
      _DetailRow(
        label: l10n.challengeSelectedWeekdays,
        value: challenge.weekdays
            .map(
              (weekday) => DateFormat.E(
                l10n.localeName,
              ).format(DateTime(2024, 1, weekday)),
            )
            .join(', '),
      ),
      for (var week = 1; week <= 4; week++)
        _DetailRow(
          label: l10n.challengeWeekNumber(week),
          value: l10n.challengeOverallDays(_weeklyCount(progress, week), 3),
        ),
    ];
  }
  final dates = progress.dailyReps.keys.toList()..sort();
  if (dates.isEmpty) return [Text(l10n.challengeNoProgressYet)];
  return dates
      .map(
        (date) => _DetailRow(
          label: DateFormat.yMMMd(l10n.localeName).format(date),
          value: l10n.unitReps(progress.dailyReps[date]!),
        ),
      )
      .toList();
}

int _weeklyCount(ChallengeProgress progress, int week) {
  final from = progress.challenge.startedAt.add(Duration(days: (week - 1) * 7));
  final to = from.add(const Duration(days: 7));
  return progress.dailyReps.keys
      .where((date) => !date.isBefore(from) && date.isBefore(to))
      .length
      .clamp(0, 3);
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = PushupLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.errorGenericBody),
          TextButton(onPressed: onRetry, child: Text(l10n.commonRetry)),
        ],
      ),
    );
  }
}

Future<void> startChallengeWorkout(
  BuildContext context,
  WidgetRef ref,
  ChallengeProgress progress,
) async {
  final type = progress.challenge.type;
  if (progress.isTodayGoalCompleted) return;
  final savedPlan = ref.read(preferencesControllerProvider).pushupLastWorkoutPlan;
  final challengeTarget = switch (type) {
    ChallengeType.sevenDay => progress.remainingReps,
    ChallengeType.cumulative => progress.remainingReps,
    ChallengeType.weekly => 0,
  };
  final plan = switch (type) {
    ChallengeType.sevenDay when challengeTarget > 0 => savedPlan.copyWith(
      id: 'challenge:${progress.challenge.id}',
      setCount: 1,
      targetRepsPerSet: challengeTarget,
      updatedAt: DateTime.now(),
    ),
    ChallengeType.cumulative when challengeTarget > 0 => savedPlan.copyWith(
      id: 'challenge:${progress.challenge.id}',
      setCount: 1,
      targetRepsPerSet: challengeTarget,
      updatedAt: DateTime.now(),
    ),
    _ => savedPlan,
  };
  await openWorkoutPreparation(
    context,
    ref,
    WorkoutPreparation(
      plan: plan,
      launchSource: WorkoutLaunchSource.challengeTab,
      challenge: ChallengeWorkoutContext(
        challengeId: progress.challenge.id,
        challengeType: type.name,
        currentProgress: progress.progress,
        currentDay: type == ChallengeType.sevenDay ? progress.currentDay : null,
        targetReps: challengeTarget > 0 ? challengeTarget : null,
        completedRepsAtStart: type == ChallengeType.sevenDay
            ? progress.todayReps
            : progress.totalReps,
        totalGoalReps: type == ChallengeType.sevenDay
            ? progress.todayGoal
            : progress.challenge.targetReps,
      ),
    ),
  );
}

Future<void> _confirmCancel(
  BuildContext context,
  WidgetRef ref,
  String id,
) async {
  final l10n = PushupLocalizations.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.challengeCancelTitle),
      content: Text(l10n.challengeCancelDescription),
      actions: [
        TextButton(
          onPressed: () => context.pop(false),
          child: Text(l10n.commonClose),
        ),
        FilledButton(
          onPressed: () => context.pop(true),
          child: Text(l10n.challengeCancel),
        ),
      ],
    ),
  );
  if (confirmed == true && context.mounted) {
    await ref.read(challengeDashboardProvider.notifier).cancel(id);
    if (context.mounted) context.pop();
  }
}

Future<void> _setChallengeNotification(
  BuildContext context,
  WidgetRef ref,
  String challengeId,
  bool enabled,
) async {
  final l10n = PushupLocalizations.of(context);
  try {
    final result = await ref
        .read(challengeDashboardProvider.notifier)
        .setNotification(
          challengeId,
          enabled,
          title: l10n.challengeReminderNotificationTitle,
          body: l10n.challengeReminderNotificationBody,
        );
    if (!context.mounted || result == NotificationPermissionResult.granted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.permissionNotificationDenied)));
  } on Object {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.errorGenericBody)));
    }
  }
}

Future<bool> _runMutation(
  BuildContext context,
  Future<void> Function() mutation,
) async {
  try {
    await mutation();
    return true;
  } on Object {
    if (!context.mounted) return false;
    final l10n = PushupLocalizations.of(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.errorGenericBody)));
    return false;
  }
}

String challengeName(PushupLocalizations l10n, ChallengeType type) =>
    switch (type) {
      ChallengeType.sevenDay => l10n.challengeSevenDayTitle,
      ChallengeType.weekly => l10n.challengeWeeklyTitle,
      ChallengeType.cumulative => l10n.challengeCumulativeTitle,
    };

String challengeStatusName(PushupLocalizations l10n, ChallengeStatus status) =>
    switch (status) {
      ChallengeStatus.active => l10n.challengeStatusActive,
      ChallengeStatus.completed => l10n.challengeStatusCompleted,
      ChallengeStatus.ended => l10n.challengeStatusEnded,
      ChallengeStatus.cancelled => l10n.challengeStatusCancelled,
    };

IconData challengeIcon(ChallengeType type) => switch (type) {
  ChallengeType.sevenDay => Icons.calendar_view_week_rounded,
  ChallengeType.weekly => Icons.event_repeat_rounded,
  ChallengeType.cumulative => Icons.stacked_line_chart_rounded,
};
