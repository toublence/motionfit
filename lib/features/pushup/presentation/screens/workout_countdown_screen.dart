import 'package:motionfit_squat/core/widgets/upright_camera_preview.dart';
import 'package:motionfit_squat/core/widgets/preparation_feedback.dart';
import 'package:motionfit_squat/features/pushup/presentation/widgets/pose_overlay.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:motionfit_squat/features/pushup/localization/generated/pushup_localizations.dart';
import 'package:motionfit_squat/features/pushup/providers.dart';
import 'package:motionfit_squat/features/pushup/application/workout_preparation.dart';
import 'package:motionfit_squat/features/pushup/application/workout_coach_messages.dart';
import 'package:motionfit_squat/features/pushup/application/workout_session_controller.dart';
import 'package:motionfit_squat/features/pushup/domain/models/workout_enums.dart';
import 'package:motionfit_squat/features/pushup/domain/models/workout_plan.dart';
import 'package:motionfit_squat/features/pushup/presentation/localized_coach_messages.dart';

class WorkoutCountdownScreen extends ConsumerStatefulWidget {
  const WorkoutCountdownScreen({required this.preparation, super.key});

  final WorkoutPreparation preparation;

  @override
  ConsumerState<WorkoutCountdownScreen> createState() =>
      _WorkoutCountdownScreenState();
}

class _WorkoutCountdownScreenState
    extends ConsumerState<WorkoutCountdownScreen> {
  Timer? _timer;
  Future<void>? _prewarmFuture;
  Object? _prewarmError;
  WorkoutSessionController? _controller;
  WorkoutCoachMessages? _messages;
  int _seconds = 5;
  bool _starting = false;
  bool _committingWorkout = false;
  bool _openingGuide = false;
  bool _leaving = false;
  bool _handedOff = false;
  bool _preparationReleased = false;
  bool _showingInitializationError = false;
  bool _allowPop = false;
  int _operationId = 0;
  late final DateTime _startedAt;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    _startCountdownTimer();
  }

  void _startCountdownTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _starting || _leaving) return;
      if (_seconds > 1) {
        setState(() => _seconds--);
      } else {
        _begin();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prewarmFuture != null) return;
    final messages = localizedCoachMessages(PushupLocalizations.of(context));
    _messages = messages;
    _controller = ref.read(workoutSessionControllerProvider.notifier);
    ref.read(analyticsServiceProvider).workoutInitializationStarted();
    _prewarmFuture = _prewarm(messages);
  }

  Future<void> _prewarm(WorkoutCoachMessages messages) async {
    try {
      await _controller!.prewarm(messages);
    } on Object catch (error) {
      _prewarmError = error;
    }
  }

  Future<void> _begin() async {
    if (!mounted || _starting || _leaving) return;
    final operationId = ++_operationId;
    setState(() => _starting = true);
    _timer?.cancel();
    await _prewarmFuture;
    if (_prewarmError != null) {
      if (!mounted ||
          _leaving ||
          _openingGuide ||
          operationId != _operationId) {
        return;
      }
      setState(() => _starting = false);
      await _showInitializationFailure();
      return;
    }
    if (!mounted || _leaving || operationId != _operationId) return;
    setState(() => _committingWorkout = true);
    final messages =
        _messages ?? localizedCoachMessages(PushupLocalizations.of(context));
    final controller = _controller!;
    final recovery = widget.preparation.recovery;
    if (recovery == null) {
      final challenge = widget.preparation.challenge;
      final cumulative = challenge?.challengeType == 'cumulative';
      final sevenDay = challenge?.challengeType == 'sevenDay';
      await controller.start(
        widget.preparation.plan,
        messages,
        maxRepsPerSet: cumulative ? 1000 : WorkoutPlan.maxReps,
        spokenRepOffset: challenge?.completedRepsAtStart ?? 0,
        cumulativeChallenge: cumulative,
        sevenDayChallengeDay: sevenDay ? challenge?.currentDay : null,
      );
    } else {
      await controller.recover(recovery, messages);
    }
    if (mounted && !_leaving && operationId == _operationId) {
      final status = ref.read(workoutSessionControllerProvider).status;
      _handedOff = true;
      context.go(
        status == WorkoutSessionStatus.resting
            ? '/pushup/workout/rest'
            : '/pushup/workout',
      );
    }
  }

  Future<void> _showInitializationFailure() async {
    if (_showingInitializationError || !mounted) return;
    _showingInitializationError = true;
    final l10n = PushupLocalizations.of(context);
    final retry = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Text(l10n.errorCameraInit),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.workoutBackToSetup),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
    _showingInitializationError = false;
    if (!mounted || retry == null) return;
    if (retry) {
      await _retryInitialization();
    } else {
      await _cancelCountdown();
    }
  }

  Future<void> _retryInitialization() async {
    if (!mounted || _leaving || _openingGuide || _committingWorkout) return;
    ++_operationId;
    await _controller?.cancelPreparation();
    if (!mounted || _leaving) return;
    final messages =
        _messages ?? localizedCoachMessages(PushupLocalizations.of(context));
    setState(() {
      _seconds = 5;
      _starting = false;
      _prewarmError = null;
      _prewarmFuture = _prewarm(messages);
      _preparationReleased = false;
    });
    _startCountdownTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    ++_operationId;
    if (!_handedOff && !_preparationReleased) {
      unawaited(_controller?.cancelPreparation());
    }
    super.dispose();
  }

  Future<void> _cancelCountdown() async {
    if (_committingWorkout || _openingGuide || _leaving || !mounted) return;
    _leaving = true;
    ++_operationId;
    _timer?.cancel();
    ref
        .read(analyticsServiceProvider)
        .workoutCancelled(
          cancelStage:
              ref.read(workoutSessionControllerProvider).previewTextureId ==
                  null
              ? 'camera_initialization'
              : 'calibration',
          cancelReason: 'user_exit',
          elapsed: DateTime.now().difference(_startedAt),
          detectedReps: 0,
          trackingLoss: Duration.zero,
        );
    ref.read(workoutLaunchContextProvider.notifier).clear();
    await _controller?.cancelPreparation();
    _preparationReleased = true;
    if (!mounted) return;
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.pop();
    });
  }

  Future<void> _openGuide() async {
    if (!mounted || _committingWorkout || _openingGuide || _leaving) return;
    _openingGuide = true;
    ++_operationId;
    _timer?.cancel();
    await _controller?.cancelPreparation();
    _preparationReleased = true;
    if (!mounted) return;
    context.pushReplacement('/pushup/prepare/guide', extra: widget.preparation);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = PushupLocalizations.of(context);
    final state = ref.watch(workoutSessionControllerProvider);
    final guidance = preparationFeedbackText(
      state.calibrationFeedback,
      camera: l10n.loadingCamera,
      noPerson: l10n.errorNoPerson,
      partialBody: l10n.guideWholeBody,
      angle: l10n.calibrationBody,
      hold: l10n.calibrationStayStill,
      ready: l10n.coachReady1,
    );
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    final orientationGuide = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.screen_rotation_rounded,
          size: isLandscape ? 40 : 48,
          color: Colors.white,
        ),
        const SizedBox(height: 12),
        Text(
          l10n.guideLandscape,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          guidance,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
        ),
      ],
    );
    final countdown = AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: _starting
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(
              NumberFormat.decimalPattern(l10n.localeName).format(_seconds),
              key: ValueKey(_seconds),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 88,
                color: Colors.white,
              ),
            ),
    );
    final statusBadges = LinearProgressIndicator(
      value: state.calibrationProgress > 0 ? state.calibrationProgress : null,
      color: Colors.white,
      backgroundColor: Colors.white24,
    );
    final screen = Scaffold(
      backgroundColor: const Color(0xFF111419),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (state.previewTextureId case final textureId?) ...[
            UprightCameraPreview(
              textureId: textureId,
              rotationDegrees: state.previewRotationDegrees,
              handlesCropAndRotation: state.previewHandlesCropAndRotation,
              mirrorInFlutter: false,
              sourceWidth: state.previewInputWidth,
              sourceHeight: state.previewInputHeight,
            ),
            if (state.previewInputWidth > 0 && state.previewInputHeight > 0)
              PoseOverlay(
                landmarks: state.overlayLandmarks,
                previewTransform: state.previewTransform,
                sourceWidth: state.previewInputWidth,
                sourceHeight: state.previewInputHeight,
                feedbackLevel: state.poseFeedbackLevel,
              ),
          ],
          const ColoredBox(color: Color(0x44000000)),
          SafeArea(
            child: Semantics(
              liveRegion: true,
              label: _starting ? guidance : l10n.countdownBeginsIn(_seconds),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: _committingWorkout || _leaving
                              ? null
                              : _cancelCountdown,
                          color: Colors.white,
                          icon: const Icon(Icons.close_rounded),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed:
                              _committingWorkout || _openingGuide || _leaving
                              ? null
                              : _openGuide,
                          icon: const Icon(Icons.help_outline_rounded),
                          label: Text(l10n.guideTitle),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    if (isLandscape)
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(child: orientationGuide),
                            const SizedBox(width: 24),
                            Expanded(child: Center(child: countdown)),
                          ],
                        ),
                      )
                    else ...[
                      const Spacer(),
                      orientationGuide,
                      const SizedBox(height: 20),
                      countdown,
                      const SizedBox(height: 16),
                    ],
                    statusBadges,
                    if (isLandscape)
                      const SizedBox(height: 8)
                    else
                      const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: .35),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            size: 17,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 7),
                          Flexible(
                            child: Text(
                              l10n.guidePrivacy,
                              maxLines: 2,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _cancelCountdown();
      },
      child: screen,
    );
  }
}
