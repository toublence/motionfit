import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:motionfit_squat/features/plank/localization/generated/plank_localizations.dart';
import 'package:motionfit_squat/core/ads/post_workout_interstitial.dart';
import 'package:motionfit_squat/features/plank/providers.dart';
import 'package:motionfit_squat/features/plank/challenges/application/challenge_controller.dart';
import 'package:motionfit_squat/features/plank/records/application/records_providers.dart';
import 'package:motionfit_squat/features/plank/workout/application/workout_session_controller.dart';
import 'package:motionfit_squat/features/plank/workout/application/workout_session_state.dart';
import 'package:motionfit_squat/features/plank/workout/application/workout_preparation.dart';
import 'package:motionfit_squat/features/plank/workout/domain/models/workout_enums.dart';
import 'package:motionfit_squat/features/plank/workout/presentation/workout_orientation.dart';

class RestScreen extends ConsumerStatefulWidget {
  const RestScreen({super.key});

  @override
  ConsumerState<RestScreen> createState() => _RestScreenState();
}

class _RestScreenState extends ConsumerState<RestScreen> {
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    unawaited(WorkoutOrientation.usePortrait());
    ref.read(analyticsServiceProvider).screenView('rest');
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(workoutSessionControllerProvider, (_, next) {
      if (_navigating) return;
      if (next.status == WorkoutSessionStatus.active ||
          next.status == WorkoutSessionStatus.calibrating ||
          next.status == WorkoutSessionStatus.error) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await WorkoutOrientation.useLandscape();
          if (context.mounted) context.go('/plank/workout');
        });
      } else if (next.status == WorkoutSessionStatus.completed ||
          next.status == WorkoutSessionStatus.interrupted) {
        final launch = ref.read(workoutLaunchContextProvider);
        final challengeWorkout =
            launch?.launchSource == WorkoutLaunchSource.challengeTab &&
            launch?.challenge != null;
        if (challengeWorkout) {
          if (next.saveState == WorkoutSaveState.saving) return;
          if (next.saveState == WorkoutSaveState.failed) {
            unawaited(
              ref.read(workoutSessionControllerProvider.notifier).retrySave(),
            );
            return;
          }
          _navigating = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            unawaited(_returnToChallenge());
          });
          return;
        }
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await WorkoutOrientation.usePortrait();
          if (context.mounted) context.go('/plank/workout/summary');
        });
      }
    });
    final state = ref.watch(workoutSessionControllerProvider);
    final l10n = PlankLocalizations.of(context);
    final remaining = state.restRemaining;
    final number = NumberFormat.decimalPattern(
      l10n.localeName,
    ).format(remaining.inSeconds);
    final totalRest = state.plan?.restDurationSeconds ?? 0;
    final progress = totalRest <= 0
        ? 1.0
        : 1 - (remaining.inMilliseconds / (totalRest * 1000));
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_confirmRestEnd(context, ref));
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.restTitle)),
        body: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Semantics(
                      liveRegion: true,
                      label: l10n.unitSeconds(remaining.inSeconds),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox.square(
                            dimension: 210,
                            child: CircularProgressIndicator(
                              value: progress.clamp(0, 1).toDouble(),
                              strokeWidth: 12,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                number,
                                style: Theme.of(context).textTheme.displayLarge
                                    ?.copyWith(fontSize: 76),
                              ),
                              Text(l10n.unitSeconds(remaining.inSeconds)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      l10n.restNextSet(
                        state.currentSetIndex + 1,
                        state.totalSets,
                      ),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _RestMetric(
                            label: l10n.restCompletedSets,
                            value: '${state.currentSetIndex}',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _RestMetric(
                            label: l10n.restTotalReps,
                            value: '${state.totalReps}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    if (state.saveState == WorkoutSaveState.failed) ...[
                      Material(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            12,
                            4,
                            4,
                            4,
                          ),
                          child: Row(
                            children: [
                              Expanded(child: Text(l10n.completeSaveFailed)),
                              TextButton(
                                onPressed: () => ref
                                    .read(
                                      workoutSessionControllerProvider.notifier,
                                    )
                                    .startNextSet(skipped: true),
                                child: Text(l10n.commonRetry),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => ref
                            .read(workoutSessionControllerProvider.notifier)
                            .startNextSet(skipped: true),
                        child: Text(l10n.restSkip),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: ref
                            .read(workoutSessionControllerProvider.notifier)
                            .addRestTime,
                        icon: const Icon(Icons.add_alarm_outlined),
                        label: Text(l10n.restAddFifteenSeconds),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _returnToChallenge() async {
    final state = ref.read(workoutSessionControllerProvider);
    final session = state.session;
    if (session != null &&
        session.completed &&
        !session.interrupted &&
        session.totalReps > 0 &&
        state.saveState == WorkoutSaveState.saved) {
      try {
        await showPostWorkoutInterstitial(ref);
      } on Object catch (error, stackTrace) {
        unawaited(
          ref
              .read(crashReportingServiceProvider)
              .recordNonFatal(
                error,
                stackTrace,
                reason: 'challenge_post_workout_ad',
              ),
        );
      }
    }
    await ref
        .read(workoutSessionControllerProvider.notifier)
        .clearCompletedSession();
    if (!mounted) return;
    ref
      ..invalidate(allSessionsProvider)
      ..invalidate(todaySessionsProvider)
      ..invalidate(workoutStatisticsProvider)
      ..invalidate(challengeDashboardProvider);
    ref.read(workoutLaunchContextProvider.notifier).clear();
    await WorkoutOrientation.usePortrait();
    if (!mounted) return;
    context.go('/challenge');
    _navigating = false;
  }
}

Future<void> _confirmRestEnd(BuildContext context, WidgetRef ref) async {
  final l10n = PlankLocalizations.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.workoutEndDialogTitle),
      content: Text(l10n.workoutEndDialogBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n.workoutEndDialogConfirm),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  final launch = ref.read(workoutLaunchContextProvider);
  final challengeWorkout =
      launch?.launchSource == WorkoutLaunchSource.challengeTab &&
      launch?.challenge != null;
  if (challengeWorkout) {
    final finished = await ref
        .read(workoutSessionControllerProvider.notifier)
        .finishContinuousWorkout();
    if (!finished || !context.mounted) return;
    if (ref.read(workoutSessionControllerProvider).status ==
        WorkoutSessionStatus.idle) {
      ref.read(workoutLaunchContextProvider.notifier).clear();
      await WorkoutOrientation.usePortrait();
      if (!context.mounted) return;
      context.go('/challenge');
    }
    return;
  }
  final destination = launch?.launchSource == WorkoutLaunchSource.challengeTab
      ? '/challenge'
      : '/squat';
  final saved = await ref
      .read(workoutSessionControllerProvider.notifier)
      .saveForLater();
  if (!saved || !context.mounted) return;

  ref.read(workoutLaunchContextProvider.notifier).clear();
  await WorkoutOrientation.usePortrait();
  if (!context.mounted) return;
  context.go(destination);
}

class _RestMetric extends StatelessWidget {
  const _RestMetric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}
