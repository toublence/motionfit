import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:motionfit_squat/features/pushup/localization/generated/pushup_localizations.dart';
import 'package:motionfit_squat/core/ads/post_workout_interstitial.dart';
import 'package:motionfit_squat/features/settings/application/preferences_controller.dart';
import 'package:motionfit_squat/features/pushup/providers.dart';
import 'package:motionfit_squat/features/pushup/challenges/application/challenge_controller.dart';
import 'package:motionfit_squat/features/pushup/records/application/records_providers.dart';
import 'package:motionfit_squat/features/pushup/application/workout_preparation.dart';
import 'package:motionfit_squat/features/pushup/application/workout_session_controller.dart';
import 'package:motionfit_squat/features/pushup/application/workout_session_state.dart';
import 'package:motionfit_squat/features/pushup/domain/models/workout_enums.dart';
import 'package:motionfit_squat/features/pushup/presentation/widgets/pose_overlay.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() =>
      _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen>
    with WidgetsBindingObserver {
  bool _navigating = false;
  AppLifecycleState _targetLifecycleState = AppLifecycleState.resumed;
  bool _syncingLifecycle = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref.read(analyticsServiceProvider).workoutScreenViewed();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _targetLifecycleState = state;
    unawaited(_syncCameraLifecycle());
  }

  Future<void> _syncCameraLifecycle() async {
    if (_syncingLifecycle || !mounted) return;
    final backgroundPauseReason = PushupLocalizations.of(
      context,
    ).workoutPauseReasonBackground;
    _syncingLifecycle = true;
    try {
      while (mounted) {
        final target = _targetLifecycleState;
        final workout = ref.read(workoutSessionControllerProvider);
        final controller = ref.read(workoutSessionControllerProvider.notifier);
        if (target == AppLifecycleState.resumed &&
            workout.status == WorkoutSessionStatus.paused) {
          await controller.resume();
        } else if ((target == AppLifecycleState.inactive ||
                target == AppLifecycleState.paused ||
                target == AppLifecycleState.hidden) &&
            (workout.status == WorkoutSessionStatus.active ||
                workout.status == WorkoutSessionStatus.calibrating)) {
          await controller.pause(reason: backgroundPauseReason);
        }
        if (target == _targetLifecycleState) break;
      }
    } finally {
      _syncingLifecycle = false;
      if (mounted &&
          _targetLifecycleState != WidgetsBinding.instance.lifecycleState) {
        _targetLifecycleState =
            WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed;
        unawaited(_syncCameraLifecycle());
      }
    }
  }

  void _navigateForStatus(WorkoutSessionState next) {
    if (_navigating || !mounted) return;
    final launch = ref.read(workoutLaunchContextProvider);
    final challengeWorkout =
        launch?.launchSource == WorkoutLaunchSource.challengeTab &&
        launch?.challenge != null;
    final terminal =
        next.status == WorkoutSessionStatus.completed ||
        next.status == WorkoutSessionStatus.interrupted;
    if (next.status == WorkoutSessionStatus.completed) {
      if (challengeWorkout && next.saveState == WorkoutSaveState.saving) {
        return;
      }
      if (challengeWorkout && next.saveState == WorkoutSaveState.failed) {
        unawaited(
          ref.read(workoutSessionControllerProvider.notifier).retrySave(),
        );
        return;
      }
      _navigating = true;
      unawaited(_completeAndNavigate(challengeWorkout: challengeWorkout));
      return;
    }
    if (terminal && challengeWorkout) {
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
    final location = switch (next.status) {
      WorkoutSessionStatus.resting => '/pushup/workout/rest',
      WorkoutSessionStatus.completed ||
      WorkoutSessionStatus.interrupted => '/pushup/workout/summary',
      _ => null,
    };
    if (location == null) return;
    _navigating = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go(location);
      _navigating = false;
    });
  }

  Future<void> _completeAndNavigate({required bool challengeWorkout}) async {
    final preferences = ref.read(preferencesControllerProvider);
    if (preferences.hapticsEnabled) {
      await HapticFeedback.mediumImpact();
    }
    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (!mounted) return;
    if (challengeWorkout) {
      await _returnToChallenge();
      return;
    }
    context.go('/pushup/workout/summary');
    _navigating = false;
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
    context.go('/challenge');
    _navigating = false;
  }

  @override
  Widget build(BuildContext context) {
    ref
        .read(workoutSessionControllerProvider.notifier)
        .enableCoachDiagnostics();
    ref.listen(workoutSessionControllerProvider, (_, next) {
      _navigateForStatus(next);
    });
    final state = ref.watch(workoutSessionControllerProvider);
    final selectedCamera = ref.watch(
      preferencesControllerProvider.select((value) => value.selectedCamera),
    );
    final voiceCoachingEnabled = ref.watch(
      preferencesControllerProvider.select(
        (value) => value.voiceCoachingEnabled,
      ),
    );
    final challengeWorkout =
        ref.watch(workoutLaunchContextProvider)?.challenge != null;
    final l10n = PushupLocalizations.of(context);
    final mirrorInFlutter =
        selectedCamera == CameraSelection.front && !state.previewMirrored;
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (state.previewTextureId case final textureId?
                when state.previewInputWidth > 0 &&
                    state.previewInputHeight > 0)
              Transform.flip(
                flipX: mirrorInFlutter,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _UprightCameraPreview(
                      textureId: textureId,
                      rotationDegrees: state.previewRotationDegrees,
                      handlesCropAndRotation:
                          state.previewHandlesCropAndRotation,
                      mirrorInFlutter: false,
                      sourceWidth: state.previewInputWidth,
                      sourceHeight: state.previewInputHeight,
                    ),
                    if (state.skeletonVisible)
                      PoseOverlay(
                        landmarks: state.overlayLandmarks,
                        previewTransform: state.previewTransform,
                        sourceWidth: state.previewInputWidth,
                        sourceHeight: state.previewInputHeight,
                        flipHorizontally: false,
                        feedbackLevel: state.poseFeedbackLevel,
                      ),
                  ],
                ),
              )
            else
              _CameraLoading(label: l10n.loadingCamera),
            const SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: _WorkoutCountOverlay(),
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  child: const _WorkoutControls(),
                ),
              ),
            ),
            if (!state.voiceAvailable &&
                (voiceCoachingEnabled || challengeWorkout))
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 132, 16, 0),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 380),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: .78),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.volume_off_rounded,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              l10n.voiceUnavailable,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (state.status == WorkoutSessionStatus.error)
              _CameraErrorOverlay(state: state),
          ],
        ),
      ),
    );
  }
}

class _WorkoutCountOverlay extends ConsumerWidget {
  const _WorkoutCountOverlay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workoutSessionControllerProvider);
    final launch = ref.watch(workoutLaunchContextProvider);
    final l10n = PushupLocalizations.of(context);
    final challenge = launch?.challenge;
    final challengeWorkout = challenge != null;
    final completedRepsAtStart = challenge?.completedRepsAtStart ?? 0;
    final challengeReps = completedRepsAtStart + state.totalReps;
    final challengeTarget = challenge?.totalGoalReps ?? challenge?.targetReps;
    final challengeRemaining = challengeTarget == null
        ? null
        : (challengeTarget - challengeReps).clamp(0, challengeTarget);
    final calibrating =
        state.status == WorkoutSessionStatus.preparing ||
        state.status == WorkoutSessionStatus.calibrating;
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: .68),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: state.status == WorkoutSessionStatus.completed
              ? TweenAnimationBuilder<double>(
                  key: const ValueKey('workout-completed'),
                  tween: Tween(begin: .88, end: 1),
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutBack,
                  builder: (context, scale, child) =>
                      Transform.scale(scale: scale, child: child),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.workoutRepProgress(
                          state.targetReps,
                          state.targetReps,
                        ),
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF8FD6B0),
                            size: 24,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            l10n.completeTitle,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : calibrating
              ? Column(
                  key: const ValueKey('calibrating'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.calibrationTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: state.calibrationProgress.clamp(0, 1),
                      backgroundColor: Colors.white24,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.calibrationBody,
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                    ),
                  ],
                )
              : Column(
                  key: const ValueKey('counting'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (challengeWorkout) ...[
                      Text(
                        l10n.challengeRepsProgress(
                          challengeReps,
                          challengeTarget ?? challengeReps,
                        ),
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                            ),
                      ),
                    ] else ...[
                      Text(
                        l10n.workoutSetProgress(
                          state.currentSetIndex,
                          state.totalSets,
                        ),
                        style: Theme.of(
                          context,
                        ).textTheme.labelLarge?.copyWith(color: Colors.white70),
                      ),
                      Text(
                        l10n.workoutRepProgress(
                          state.currentSetReps,
                          state.targetReps,
                        ),
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                            ),
                      ),
                      Text(
                        l10n.workoutTotalReps(state.totalReps),
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                      ),
                    ],
                    if (challengeRemaining != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        l10n.challengeRepsRemaining(challengeRemaining),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primaryContainer,
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

class _UprightCameraPreview extends StatelessWidget {
  const _UprightCameraPreview({
    required this.textureId,
    required this.rotationDegrees,
    required this.handlesCropAndRotation,
    required this.mirrorInFlutter,
    required this.sourceWidth,
    required this.sourceHeight,
  });

  final int textureId;
  final int rotationDegrees;
  final bool handlesCropAndRotation;
  final bool mirrorInFlutter;
  final int sourceWidth;
  final int sourceHeight;

  @override
  Widget build(BuildContext context) {
    final normalizedRotation = ((rotationDegrees % 360) + 360) % 360;
    final manualQuarterTurns = normalizedRotation ~/ 90;
    final hasSourceSize = sourceWidth > 0 && sourceHeight > 0;
    final rawWidth = !handlesCropAndRotation && manualQuarterTurns.isOdd
        ? sourceHeight
        : sourceWidth;
    final rawHeight = !handlesCropAndRotation && manualQuarterTurns.isOdd
        ? sourceWidth
        : sourceHeight;
    Widget preview = hasSourceSize
        ? SizedBox(
            width: rawWidth.toDouble(),
            height: rawHeight.toDouble(),
            child: Texture(textureId: textureId),
          )
        : Texture(textureId: textureId);
    if (!handlesCropAndRotation) {
      // ImageReader-backed Flutter textures do not apply CameraX rotation or
      // front-camera mirror metadata, so correct both in the widget layer.
      preview = RotatedBox(quarterTurns: manualQuarterTurns, child: preview);
      if (mirrorInFlutter) {
        preview = Transform.flip(flipX: true, child: preview);
      }
    } else if (mirrorInFlutter) {
      preview = Transform.flip(flipX: true, child: preview);
    }
    if (!hasSourceSize) return ClipRect(child: preview);
    return ClipRect(
      child: FittedBox(fit: BoxFit.cover, child: preview),
    );
  }
}

class _WorkoutControls extends ConsumerWidget {
  const _WorkoutControls();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = PushupLocalizations.of(context);
    return IconButton(
      tooltip: l10n.workoutEnd,
      onPressed: () => _saveWorkoutForLater(context, ref),
      style: IconButton.styleFrom(
        minimumSize: const Size(64, 64),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      icon: const Icon(Icons.stop_rounded, size: 30),
    );
  }
}

class _CameraErrorOverlay extends ConsumerWidget {
  const _CameraErrorOverlay({required this.state});
  final WorkoutSessionState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = PushupLocalizations.of(context);
    final body = switch (state.errorCode) {
      'camera_in_use' => l10n.errorCameraInUse,
      'model_load_failed' ||
      'model_initialization_failed' ||
      'model_unavailable' => l10n.errorPoseModelLoad,
      _ => l10n.errorCameraInit,
    };
    return ColoredBox(
      color: Colors.black.withValues(alpha: .76),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.videocam_off_outlined,
                size: 52,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                body,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _leaveCameraError(context, ref, state),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                    ),
                    icon: Icon(
                      state.isValidWorkout
                          ? Icons.stop_rounded
                          : Icons.arrow_back_rounded,
                    ),
                    label: Text(
                      state.isValidWorkout
                          ? l10n.workoutEnd
                          : l10n.workoutBackToSetup,
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: () => ref
                        .read(workoutSessionControllerProvider.notifier)
                        .retryCamera(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(l10n.commonRetry),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CameraLoading extends StatelessWidget {
  const _CameraLoading({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(color: Colors.white),
        const SizedBox(height: 16),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    ),
  );
}

Future<void> _saveWorkoutForLater(BuildContext context, WidgetRef ref) async {
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
  context.go(destination);
}

Future<void> _leaveCameraError(
  BuildContext context,
  WidgetRef ref,
  WorkoutSessionState state,
) async {
  if (state.isValidWorkout) {
    await _saveWorkoutForLater(context, ref);
    return;
  }
  final discarded = await ref
      .read(workoutSessionControllerProvider.notifier)
      .discardInvalidSession();
  if (!discarded || !context.mounted) return;
  ref.read(workoutLaunchContextProvider.notifier).clear();
  context.go('/squat');
}
