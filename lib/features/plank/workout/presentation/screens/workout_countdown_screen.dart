import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:motionfit_squat/features/plank/localization/generated/plank_localizations.dart';
import 'package:motionfit_squat/features/plank/providers.dart';
import 'package:motionfit_squat/features/plank/workout/application/workout_preparation.dart';
import 'package:motionfit_squat/features/plank/workout/application/workout_coach_messages.dart';
import 'package:motionfit_squat/features/plank/workout/application/workout_session_controller.dart';
import 'package:motionfit_squat/features/plank/workout/domain/models/workout_enums.dart';
import 'package:motionfit_squat/features/plank/workout/domain/models/workout_plan.dart';
import 'package:motionfit_squat/features/plank/workout/presentation/localized_coach_messages.dart';
import 'package:motionfit_squat/features/plank/workout/presentation/workout_orientation.dart';

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
  WorkoutCoachMessages? _messages;
  int _seconds = 5;
  bool _starting = false;
  bool _openingGuide = false;
  bool _leaving = false;
  bool _allowPop = false;
  late final DateTime _startedAt;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    unawaited(WorkoutOrientation.useLandscape());
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
    final messages = localizedCoachMessages(PlankLocalizations.of(context));
    _messages = messages;
    ref.read(analyticsServiceProvider).workoutInitializationStarted();
    _prewarmFuture = _prewarm(messages);
  }

  Future<void> _prewarm(WorkoutCoachMessages messages) async {
    try {
      await ref
          .read(workoutSessionControllerProvider.notifier)
          .prewarm(messages);
    } on Object {
      // The normal start path retries camera and model initialization.
    }
  }

  Future<void> _begin() async {
    if (!mounted || _starting || _leaving) return;
    setState(() => _starting = true);
    _timer?.cancel();
    await _prewarmFuture;
    if (!mounted) return;
    final messages =
        _messages ?? localizedCoachMessages(PlankLocalizations.of(context));
    final controller = ref.read(workoutSessionControllerProvider.notifier);
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
    if (mounted) {
      final status = ref.read(workoutSessionControllerProvider).status;
      context.go(
        status == WorkoutSessionStatus.resting
            ? '/plank/workout/rest'
            : '/plank/workout',
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _cancelCountdown() async {
    if (_starting || _openingGuide || _leaving || !mounted) return;
    _leaving = true;
    _timer?.cancel();
    ref
        .read(analyticsServiceProvider)
        .workoutCancelled(
          cancelStage: 'camera_initialization',
          cancelReason: 'user_exit',
          elapsed: DateTime.now().difference(_startedAt),
          detectedReps: 0,
          trackingLoss: Duration.zero,
        );
    ref.read(workoutLaunchContextProvider.notifier).clear();
    unawaited(
      ref.read(workoutSessionControllerProvider.notifier).cancelPreparation(),
    );
    await WorkoutOrientation.usePortrait();
    if (!mounted) return;
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.pop();
    });
  }

  void _openGuide() {
    if (!mounted || _starting || _openingGuide || _leaving) return;
    _openingGuide = true;
    context.pushReplacement('/plank/prepare/guide', extra: widget.preparation);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = PlankLocalizations.of(context);
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
          l10n.countdownLandscapePrompt,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.guideWholeBody,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
        ),
      ],
    );
    final countdown = AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: Text(
        NumberFormat.decimalPattern(l10n.localeName).format(_seconds),
        key: ValueKey(_seconds),
        style: Theme.of(
          context,
        ).textTheme.displayLarge?.copyWith(fontSize: 88, color: Colors.white),
      ),
    );
    final statusBadges = Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        _StatusBadge(
          icon: Icons.person_outline_rounded,
          label: l10n.guideOnePerson,
        ),
        _StatusBadge(
          icon: Icons.check_circle_outline_rounded,
          label: l10n.guideStableCamera,
        ),
      ],
    );
    final screen = Scaffold(
      backgroundColor: const Color(0xFF111419),
      body: SafeArea(
        child: Semantics(
          liveRegion: true,
          label: l10n.countdownBeginsIn(_seconds),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: _starting || _leaving
                          ? null
                          : _cancelCountdown,
                      color: Colors.white,
                      icon: const Icon(Icons.close_rounded),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _starting || _openingGuide || _leaving
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
                if (isLandscape) const SizedBox(height: 8) else const Spacer(),
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
    );
    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_cancelCountdown());
      },
      child: screen,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 44),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.white),
        const SizedBox(width: 7),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 130),
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    ),
  );
}
