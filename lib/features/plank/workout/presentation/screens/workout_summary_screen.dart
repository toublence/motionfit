import 'package:motionfit_squat/features/exercise/application/combined_workout_metrics.dart';
import 'package:motionfit_squat/features/exercise/application/exercise_selection.dart';
import 'package:motionfit_squat/features/exercise/domain/exercise_type.dart';
import 'package:motionfit_squat/features/settings/domain/user_preferences.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:motionfit_squat/core/ads/bottom_native_ad.dart';
import 'package:motionfit_squat/features/plank/localization/generated/plank_localizations.dart';
import 'package:motionfit_squat/core/ads/post_workout_interstitial.dart';
import 'package:motionfit_squat/core/diagnostics/crash_reporting_service.dart';
import 'package:motionfit_squat/core/notifications/notification_service.dart';
import 'package:motionfit_squat/features/plank/providers.dart';
import 'package:motionfit_squat/core/reviews/review_prompt_provider.dart';
import 'package:motionfit_squat/core/utils/localized_formatters.dart';
import 'package:motionfit_squat/core/widgets/coach_ui.dart';
import 'package:motionfit_squat/core/widgets/responsive_page.dart';
import 'package:motionfit_squat/features/plank/records/application/records_providers.dart';
import 'package:motionfit_squat/features/plank/challenges/application/challenge_controller.dart';
import 'package:motionfit_squat/features/plank/records/domain/workout_session_details.dart';
import 'package:motionfit_squat/features/settings/application/preferences_controller.dart';
import 'package:motionfit_squat/features/settings/application/reminder_controller.dart';
import 'package:motionfit_squat/features/plank/workout/application/workout_session_controller.dart';
import 'package:motionfit_squat/features/plank/workout/application/workout_session_state.dart';
import 'package:motionfit_squat/features/plank/workout/application/workout_preparation.dart';
import 'package:motionfit_squat/features/plank/workout/domain/services/form_analyzer.dart';
import 'package:motionfit_squat/features/plank/workout/presentation/widgets/rep_timeline_section.dart';
import 'package:motionfit_squat/features/plank/workout/presentation/widgets/workout_review_widgets.dart';
import 'package:motionfit_squat/features/plank/workout/presentation/workout_orientation.dart';

class WorkoutSummaryScreen extends ConsumerStatefulWidget {
  const WorkoutSummaryScreen({super.key});

  @override
  ConsumerState<WorkoutSummaryScreen> createState() =>
      _WorkoutSummaryScreenState();
}

class _WorkoutSummaryScreenState extends ConsumerState<WorkoutSummaryScreen> {
  late final CrashReportingService _crashReporting;
  bool _finishing = false;
  bool _reminderOfferEligible = false;
  bool _reminderSettingsCtaVisible = false;
  bool _enablingReminder = false;
  bool _reminderEnabled = false;
  bool _timelineAnalyticsLogged = false;
  int? _reminderOfferWorkoutCount;

  @override
  void initState() {
    super.initState();
    _crashReporting = ref.read(crashReportingServiceProvider);
    unawaited(WorkoutOrientation.usePortrait());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _finishing) return;
      final session = ref.read(workoutSessionControllerProvider).session;
      ref.read(analyticsServiceProvider).screenView('workout_summary');
      if (session != null) {
        ref
            .read(analyticsServiceProvider)
            .workoutSummaryViewed(
              completed: session.completed && !session.interrupted,
            );
      }
      _loadPostCompletionActions();
      _requestReviewAfterResult();
    });
  }

  void _requestReviewAfterResult() {
    final state = ref.read(workoutSessionControllerProvider);
    final session = state.session;
    final validCompletedWorkout =
        session != null &&
        session.completed &&
        !session.interrupted &&
        session.totalReps > 0 &&
        state.saveState == WorkoutSaveState.saved;
    unawaited(
      ref
          .read(reviewPromptServiceProvider)
          .requestAfterResultDisplayed(
            validCompletedWorkout: validCompletedWorkout,
            isResultVisible: () =>
                mounted && (ModalRoute.of(context)?.isCurrent ?? false),
            isAppActive: () =>
                WidgetsBinding.instance.lifecycleState ==
                AppLifecycleState.resumed,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workoutSessionControllerProvider);
    final l10n = PlankLocalizations.of(context);
    final session = state.session;
    final reminderPermissionDenied = ref.watch(
      preferencesControllerProvider.select(
        (value) => value.postWorkoutReminderPermissionDenied,
      ),
    );
    final requiresReminderSettings =
        _reminderSettingsCtaVisible && reminderPermissionDenied;
    final launchContext = ref.watch(workoutLaunchContextProvider);
    final isChallengeWorkout =
        launchContext?.launchSource == WorkoutLaunchSource.challengeTab &&
        launchContext?.challenge != null;
    if (session == null) {
      if (!_finishing) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          context.go(isChallengeWorkout ? '/challenge' : '/squat');
        });
      }
      return const SizedBox.shrink();
    }
    final interrupted = session.interrupted;
    final persistedDetails = ref.watch(sessionDetailsProvider(session.id));
    final loadedDetails = switch (persistedDetails) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (!_timelineAnalyticsLogged &&
        loadedDetails != null &&
        loadedDetails.repAnalyses.isNotEmpty) {
      _timelineAnalyticsLogged = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(analyticsServiceProvider)
            .repTimelineViewed(workoutSessionId: session.analyticsSessionId);
      });
    }
    final strengths = _strengths(state, l10n);
    final scoreValues = state.formAnalyses
        .map((analysis) => analysis.overallScore)
        .whereType<double>()
        .toList();
    final averageScore = scoreValues.isEmpty
        ? null
        : scoreValues.reduce((a, b) => a + b) / scoreValues.length;
    final resolvedAverageScore =
        averageScore ?? loadedDetails?.averageFormScore;
    final retention = ref.watch(combinedWorkoutMetricsProvider);
    final retentionMetrics = switch (retention) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final activeChallenge = ref.watch(challengeDashboardProvider).value?.active;
    final nextGoal =
        activeChallenge != null &&
            activeChallenge.currentDay <
                activeChallenge.challenge.dailyGoals.length
        ? activeChallenge.challenge.dailyGoals[activeChallenge.currentDay]
        : null;
    final nextBody = activeChallenge == null
        ? l10n.challengeSevenDayDescription
        : nextGoal != null
        ? '${l10n.challengeDayNumber(activeChallenge.currentDay + 1)} · ${nextGoal == 0 ? l10n.challengeRecoveryDay : l10n.unitReps(nextGoal)}'
        : l10n.challengeRepsRemaining(activeChallenge.remainingReps);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_finishing) unawaited(_finish(showInterstitial: false));
      },
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, viewport) {
              final compact = viewport.maxHeight < 720;
              final gap = compact ? 6.0 : 8.0;
              return ResponsivePage(
                padding: EdgeInsetsDirectional.fromSTEB(
                  20,
                  compact ? 6 : 12,
                  20,
                  compact ? 8 : 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            WorkoutOverviewHero(
                              eyebrow: interrupted
                                  ? l10n.detailInterrupted
                                  : l10n.completeTitle,
                              totalReps: session.totalReps,
                              exerciseLabel: l10n.navSquat,
                              currentStreak:
                                  retentionMetrics?.currentStreak ?? 0,
                              firstWorkout:
                                  retentionMetrics?.completedWorkoutCount == 1,
                            ),
                            if (resolvedAverageScore != null ||
                                (loadedDetails?.repAnalyses.isNotEmpty ??
                                    false)) ...[
                              const SizedBox(height: 28),
                              WorkoutFormReview(
                                strengths: strengths,
                                analyses:
                                    loadedDetails?.repAnalyses ?? const [],
                              ),
                            ],
                            const SizedBox(height: 24),
                            const MotionRule(),
                            const SizedBox(height: 14),
                            _MetricsDashboard(
                              compact: compact,
                              metrics: [
                                (
                                  l10n.completeCompletedSets,
                                  l10n.unitSets(session.completedSetCount),
                                ),
                                (
                                  l10n.completeActiveTime,
                                  LocalizedFormatters.timer(
                                    Duration(
                                      seconds: session.activeDurationSeconds,
                                    ),
                                    l10n.localeName,
                                  ),
                                ),
                                if (resolvedAverageScore != null)
                                  (
                                    l10n.formScore,
                                    l10n.formScoreValue(
                                      resolvedAverageScore.round(),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            const NativeAdSection(
                              placement: NativeAdPlacement.workoutSummary,
                            ),
                            WorkoutResultRepTimeline(
                              sessionId: session.id,
                              details: persistedDetails,
                              onRetry: () => ref.invalidate(
                                sessionDetailsProvider(session.id),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: gap),
                    if (_reminderOfferEligible ||
                        _reminderSettingsCtaVisible ||
                        _reminderEnabled) ...[
                      _PostWorkoutReminderCard(
                        time: DateFormat.jm(
                          l10n.localeName,
                        ).format((session.endedAt ?? DateTime.now()).toLocal()),
                        enabled: _reminderEnabled,
                        requiresSettings: requiresReminderSettings,
                        loading: _enablingReminder,
                        onEnable: requiresReminderSettings
                            ? () => unawaited(
                                ref
                                    .read(permissionServiceProvider)
                                    .openSettings(),
                              )
                            : _enableDailyReminder,
                        onLater: _declineReminderOffer,
                      ),
                      SizedBox(height: gap),
                    ],
                    if (!_reminderOfferEligible &&
                        !_reminderSettingsCtaVisible &&
                        !_reminderEnabled &&
                        session.completed &&
                        !session.interrupted) ...[
                      CoachInsightPanel(
                        icon: Icons.event_available_rounded,
                        title: activeChallenge == null
                            ? l10n.challengeSevenDayTitle
                            : l10n.challengeNext,
                        body: nextBody,
                        trailing: TextButton(
                          onPressed: _finishing
                              ? null
                              : () {
                                  ref
                                      .read(selectedExerciseProvider.notifier)
                                      .select(ExerciseType.plank);
                                  ref
                                      .read(analyticsServiceProvider)
                                      .retentionEvent(
                                        'mf2_next_workout_action_tapped',
                                        {
                                          'exercise_type': 'plank',
                                          'entry_point': 'workout_summary',
                                          'action': activeChallenge == null
                                              ? 'challenge_recommendation'
                                              : 'active_challenge',
                                        },
                                      );
                                  unawaited(
                                    _finish(
                                      showInterstitial: false,
                                      destination: '/challenge',
                                    ),
                                  );
                                },
                          child: Text(l10n.challengeViewDetails),
                        ),
                      ),
                      SizedBox(height: gap),
                    ],
                    Row(
                      children: [
                        Icon(
                          state.saveState == WorkoutSaveState.failed
                              ? Icons.error_outline
                              : Icons.save_outlined,
                          size: 17,
                          color: state.saveState == WorkoutSaveState.failed
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.saveState == WorkoutSaveState.failed
                                ? l10n.completeSaveFailed
                                : l10n.completeSaved,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: state.saveState == WorkoutSaveState.failed
                                ? Theme.of(context).textTheme.bodySmall
                                : Theme.of(
                                    context,
                                  ).textTheme.labelSmall?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                          ),
                        ),
                        if (state.saveState == WorkoutSaveState.failed)
                          TextButton(
                            onPressed: ref
                                .read(workoutSessionControllerProvider.notifier)
                                .retrySave,
                            child: Text(l10n.commonRetry),
                          ),
                      ],
                    ),
                    SizedBox(height: gap),
                    if (isChallengeWorkout &&
                        session.completed &&
                        !session.interrupted &&
                        session.totalReps > 0 &&
                        state.saveState == WorkoutSaveState.saved) ...[
                      CoachInsightPanel(
                        icon: Icons.emoji_events_rounded,
                        title: l10n.challengeTitle,
                        body: l10n.challengeProgressUpdated,
                        tone: CoachStatusTone.positive,
                      ),
                      SizedBox(height: gap),
                    ],
                    FilledButton(
                      onPressed:
                          state.saveState == WorkoutSaveState.saving ||
                              _finishing
                          ? null
                          : () => _finish(
                              showInterstitial:
                                  session.completed && !session.interrupted,
                              destination: isChallengeWorkout
                                  ? '/challenge'
                                  : '/squat',
                            ),
                      child: Text(l10n.completeFinish),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _loadPostCompletionActions() async {
    final session = ref.read(workoutSessionControllerProvider).session;
    if (session == null || !session.completed || session.interrupted) return;
    try {
      final metrics = await ref.read(combinedWorkoutMetricsProvider.future);
      if (!mounted || _finishing) return;

      final l10n = PlankLocalizations.of(context);
      var hasEnabledReminder = true;
      try {
        final reminders = await ref.read(reminderControllerProvider.future);
        if (!mounted || _finishing) return;
        hasEnabledReminder = reminders.any((reminder) => reminder.enabled);
        unawaited(
          ref
              .read(reminderControllerProvider.notifier)
              .refreshForEnvironment(
                title: l10n.notificationReminderTitle,
                body: l10n.notificationReminderBody,
                force: true,
                currentStreak: metrics.currentStreak,
                streakAtRisk: metrics.streakAtRisk,
                streakRiskBody: l10n.notificationStreakReminderBody(
                  metrics.currentStreak,
                ),
              )
              .catchError((Object _) {}),
        );
      } on Object catch (error, stackTrace) {
        _recordNonFatal(error, stackTrace, 'post_workout_reminder_refresh');
      }
      if (!mounted || _finishing) return;

      final preferences = ref.read(preferencesControllerProvider);
      final completedWorkoutCount = metrics.completedWorkoutCount;
      // Explicit denial is respected. Settings remain accessible separately.
      final shouldOfferReminder =
          !hasEnabledReminder &&
          preferences.shouldOfferWorkoutReminder(completedWorkoutCount);
      if (shouldOfferReminder) {
        try {
          await ref
              .read(preferencesControllerProvider.notifier)
              .markReminderPromptShown(completedWorkoutCount);
        } on Object catch (error, stackTrace) {
          _recordNonFatal(error, stackTrace, 'reminder_prompt_persistence');
        }
        if (!mounted || _finishing) return;
        ref
            .read(analyticsServiceProvider)
            .reminderPromptShown(completedWorkoutCount: completedWorkoutCount);
        if (!mounted || _finishing) return;
        setState(() {
          _reminderOfferEligible = true;
          _reminderOfferWorkoutCount = completedWorkoutCount;
        });
      }
    } on Object catch (error, stackTrace) {
      _recordNonFatal(error, stackTrace, 'post_workout_actions');
    }
  }

  Future<void> _enableDailyReminder() async {
    if (_enablingReminder) return;
    setState(() {
      _enablingReminder = true;
    });
    final l10n = PlankLocalizations.of(context);
    final reminderTime =
        (ref.read(workoutSessionControllerProvider).session?.endedAt ??
                DateTime.now())
            .toLocal();
    final completedWorkoutCount = _reminderOfferWorkoutCount ?? 1;
    unawaited(
      ref
          .read(preferencesControllerProvider.notifier)
          .setReminderPromptResponse(ReminderPromptResponse.accepted)
          .catchError((Object _) {}),
    );
    ref
        .read(analyticsServiceProvider)
        .reminderPromptAccepted(completedWorkoutCount: completedWorkoutCount);
    try {
      final controller = ref.read(reminderControllerProvider.notifier);
      final result = await controller.enableEveryDayAtTime(
        hour: reminderTime.hour,
        minute: reminderTime.minute,
        title: l10n.notificationReminderTitle,
        body: l10n.notificationReminderBody,
      );
      if (!mounted || _finishing) return;
      final permissionDenied =
          result == NotificationPermissionResult.denied ||
          result == NotificationPermissionResult.permanentlyDenied;
      try {
        if (result == NotificationPermissionResult.granted) {
          await ref
              .read(preferencesControllerProvider.notifier)
              .setReminderPromptDeferred(false);
        } else if (!permissionDenied) {
          await ref
              .read(preferencesControllerProvider.notifier)
              .setReminderPromptDeferred(true);
        }
      } on Object catch (error, stackTrace) {
        _recordNonFatal(error, stackTrace, 'reminder_eligibility_persistence');
      }
      if (!mounted || _finishing) return;
      if (result == NotificationPermissionResult.granted) {
        setState(() {
          _reminderEnabled = true;
          _reminderOfferEligible = false;
          _reminderSettingsCtaVisible = false;
        });
        try {
          final metrics = await ref.read(combinedWorkoutMetricsProvider.future);
          await controller.refreshForEnvironment(
            title: l10n.notificationReminderTitle,
            body: l10n.notificationReminderBody,
            force: true,
            currentStreak: metrics.currentStreak,
            streakAtRisk: metrics.streakAtRisk,
            streakRiskBody: l10n.notificationStreakReminderBody(
              metrics.currentStreak,
            ),
          );
        } on Object catch (error, stackTrace) {
          _recordNonFatal(error, stackTrace, 'streak_reminder_refresh');
        }
      } else {
        if (permissionDenied) {
          setState(() {
            _reminderOfferEligible = false;
            _reminderSettingsCtaVisible = true;
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              permissionDenied
                  ? l10n.permissionNotificationDenied
                  : l10n.reminderPermissionNeeded,
            ),
            action: permissionDenied
                ? SnackBarAction(
                    label: l10n.permissionOpenSettings,
                    onPressed: () => unawaited(
                      ref.read(permissionServiceProvider).openSettings(),
                    ),
                  )
                : null,
          ),
        );
      }
    } on Object catch (error, stackTrace) {
      _recordNonFatal(error, stackTrace, 'post_workout_reminder_enable');
      if (!mounted || _finishing) return;
      try {
        await ref
            .read(preferencesControllerProvider.notifier)
            .setReminderPromptDeferred(true);
      } on Object catch (persistenceError, persistenceStackTrace) {
        _recordNonFatal(
          persistenceError,
          persistenceStackTrace,
          'reminder_defer_persistence',
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorGenericBody)));
      }
    } finally {
      if (mounted) setState(() => _enablingReminder = false);
    }
  }

  Future<void> _declineReminderOffer() async {
    unawaited(
      ref
          .read(preferencesControllerProvider.notifier)
          .setReminderPromptResponse(ReminderPromptResponse.declined)
          .catchError((Object _) {}),
    );
    final completedWorkoutCount = _reminderOfferWorkoutCount;
    if (completedWorkoutCount != null) {
      ref
          .read(analyticsServiceProvider)
          .reminderPromptDeclined(completedWorkoutCount: completedWorkoutCount);
      try {
        await ref
            .read(preferencesControllerProvider.notifier)
            .setReminderPromptDeferred(completedWorkoutCount < 3);
      } on Object catch (error, stackTrace) {
        _recordNonFatal(error, stackTrace, 'reminder_decline_persistence');
      }
    }
    if (!mounted || _finishing) return;
    setState(() {
      _reminderOfferEligible = false;
      _reminderSettingsCtaVisible = false;
    });
  }

  void _dismissUnansweredReminder() {
    if (!_reminderOfferEligible || _enablingReminder || _reminderEnabled)
      return;
    _reminderOfferEligible = false;
    final preferences = ref.read(preferencesControllerProvider.notifier);
    ref
        .read(analyticsServiceProvider)
        .retentionEvent('mf2_reminder_prompt_dismissed', {
          'exercise_type': 'plank',
          'entry_point': 'workout_summary',
          'completed_workout_count': _reminderOfferWorkoutCount ?? 0,
        });
    unawaited(
      preferences
          .setReminderPromptResponse(ReminderPromptResponse.dismissed)
          .catchError((Object _) {}),
    );
  }

  Future<void> _finish({
    required bool showInterstitial,
    String destination = '/squat',
  }) async {
    if (_finishing) return;
    _dismissUnansweredReminder();
    setState(() => _finishing = true);
    try {
      final sessionController = ref.read(
        workoutSessionControllerProvider.notifier,
      );
      if (!mounted) return;
      await sessionController.clearCompletedSession();
      if (!mounted) return;
      ref.invalidate(allSessionsProvider);
      ref.invalidate(todaySessionsProvider);
      ref.invalidate(workoutStatisticsProvider);
      ref.invalidate(challengeDashboardProvider);
      if (showInterstitial) {
        try {
          await showPostWorkoutInterstitial(ref);
        } on Object catch (error, stackTrace) {
          _recordNonFatal(error, stackTrace, 'post_workout_ad');
        }
      }
      if (!mounted) return;
      ref.read(workoutLaunchContextProvider.notifier).clear();
      context.go(destination);
    } finally {
      if (mounted) setState(() => _finishing = false);
    }
  }

  void _recordNonFatal(Object error, StackTrace stackTrace, String reason) {
    unawaited(
      _crashReporting.recordNonFatal(error, stackTrace, reason: reason),
    );
  }

  List<String> _strengths(WorkoutSessionState state, PlankLocalizations l10n) {
    if (state.formAnalyses.isEmpty) return const [];
    double average(double? Function(FormAnalysisResult analysis) select) {
      final values = state.formAnalyses
          .map(select)
          .whereType<double>()
          .toList();
      return values.isEmpty
          ? 0
          : values.reduce((a, b) => a + b) / values.length;
    }

    final strengths = <String>[];
    if (average((analysis) => analysis.depthScore) >= 80) {
      strengths.add(l10n.formStrengthDepth);
    }
    if (average((analysis) => analysis.controlScore) >= 80) {
      strengths.add(l10n.formStrengthControl);
    }
    if (average((analysis) => analysis.balanceScore) >= 80) {
      strengths.add(l10n.formStrengthBalance);
    }
    return strengths;
  }
}

class _PostWorkoutReminderCard extends StatelessWidget {
  const _PostWorkoutReminderCard({
    required this.time,
    required this.enabled,
    required this.requiresSettings,
    required this.loading,
    required this.onEnable,
    required this.onLater,
  });

  final String time;
  final bool enabled;
  final bool requiresSettings;
  final bool loading;
  final VoidCallback onEnable;
  final VoidCallback onLater;

  @override
  Widget build(BuildContext context) {
    final l10n = PlankLocalizations.of(context);
    return Card(
      child: Column(
        children: [
          ListTile(
            dense: true,
            leading: Icon(
              enabled
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_none_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              enabled
                  ? l10n.postWorkoutReminderEnabled
                  : l10n.postWorkoutReminderTitle,
            ),
            subtitle: enabled
                ? null
                : Text(
                    requiresSettings
                        ? l10n.permissionNotificationDenied
                        : l10n.postWorkoutReminderBody(time),
                  ),
            trailing: enabled ? const Icon(Icons.check_circle_rounded) : null,
          ),
          if (!enabled)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 10),
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                children: [
                  if (!requiresSettings)
                    TextButton(
                      onPressed: loading ? null : onLater,
                      child: Text(l10n.postWorkoutReminderLater),
                    ),
                  FilledButton.tonal(
                    onPressed: loading ? null : onEnable,
                    child: loading
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            requiresSettings
                                ? l10n.permissionOpenSettings
                                : l10n.postWorkoutReminderEnable,
                          ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MetricsDashboard extends StatelessWidget {
  const _MetricsDashboard({required this.metrics, required this.compact});

  final List<(String, String)> metrics;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 2 : 4),
      child: Wrap(
        spacing: 18,
        runSpacing: 8,
        children: [
          for (final metric in metrics)
            Semantics(
              label: '${metric.$1}: ${metric.$2}',
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: metric.$2,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    TextSpan(
                      text: '  ${metric.$1}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class WorkoutResultRepTimeline extends StatelessWidget {
  const WorkoutResultRepTimeline({
    required this.sessionId,
    required this.details,
    required this.onRetry,
    super.key,
  });

  final String sessionId;
  final AsyncValue<WorkoutSessionDetails?> details;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = PlankLocalizations.of(context);
    return switch (details) {
      AsyncData(value: final value?) when value.repAnalyses.isNotEmpty =>
        RepTimelineSection(
          key: const ValueKey('workout-result-rep-timeline'),
          sessionId: sessionId,
          analyses: value.repAnalyses,
          videoPath: value.session.videoPath,
        ),
      AsyncData() => const SizedBox.shrink(),
      AsyncError() => CoachInsightPanel(
        icon: Icons.error_outline_rounded,
        title: l10n.repTimelineTitle,
        body: l10n.recordsLoadError,
        tone: CoachStatusTone.unavailable,
        trailing: TextButton(onPressed: onRetry, child: Text(l10n.commonRetry)),
      ),
      _ => Row(
        children: [
          Expanded(child: MotionEyebrow(l10n.repTimelineTitle)),
          const SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ),
    };
  }
}
