import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:motionfit_squat/features/pushup/localization/generated/pushup_localizations.dart';
import 'package:motionfit_squat/app/theme/motionfit_tokens.dart';
import 'package:motionfit_squat/features/pushup/providers.dart';
import 'package:motionfit_squat/core/widgets/responsive_page.dart';
import 'package:motionfit_squat/features/pushup/application/workout_preparation.dart';
import 'package:motionfit_squat/features/settings/application/preferences_controller.dart';

class CameraGuideScreen extends ConsumerStatefulWidget {
  const CameraGuideScreen({required this.preparation, super.key});

  final WorkoutPreparation preparation;

  @override
  ConsumerState<CameraGuideScreen> createState() => _CameraGuideScreenState();
}

class _CameraGuideScreenState extends ConsumerState<CameraGuideScreen> {
  bool _navigating = false;
  bool _allowPop = false;
  late final DateTime _startedAt;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    ref.read(analyticsServiceProvider).screenView('camera_permission_guide');
  }

  void _leaveGuide() {
    if (_navigating || !mounted) return;
    _navigating = true;
    ref
        .read(analyticsServiceProvider)
        .workoutCancelled(
          cancelStage: 'before_first_rep',
          cancelReason: 'user_exit',
          elapsed: DateTime.now().difference(_startedAt),
          detectedReps: 0,
          trackingLoss: Duration.zero,
        );
    ref.read(workoutLaunchContextProvider.notifier).clear();
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.pop();
    });
  }

  Future<void> _continueToCountdown() async {
    if (_navigating || !mounted) return;
    setState(() => _navigating = true);
    try {
      await ref
          .read(preferencesControllerProvider.notifier)
          .markPushupCameraGuideSeen();
    } on Object {
      if (mounted) setState(() => _navigating = false);
      rethrow;
    }
    if (!mounted) return;
    context.pushReplacement('/pushup/prepare/countdown', extra: widget.preparation);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = PushupLocalizations.of(context);
    final items = [
      (Icons.screen_rotation_rounded, l10n.guideLandscape),
      (Icons.accessibility_new, l10n.guideWholeBody),
      (Icons.phone_android, l10n.guideStableCamera),
      (Icons.person_outline, l10n.guideOnePerson),
      (Icons.threesixty, l10n.guideCameraAngle),
      (Icons.light_mode_outlined, l10n.guideLighting),
    ];
    final screen = Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        top: false,
        child: ResponsivePage(
          child: ListView(
            children: [
              Text(
                l10n.guideTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: context.tokens.spaceSm),
              Text(l10n.guideSubtitle),
              SizedBox(height: context.tokens.spaceLg),
              ...items.map(
                (item) => Padding(
                  padding: EdgeInsets.only(bottom: context.tokens.spaceMd),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(
                            context.tokens.radiusMd,
                          ),
                        ),
                        child: Icon(item.$1),
                      ),
                      SizedBox(width: context.tokens.spaceMd),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            item.$2,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(context.tokens.spaceMd),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: context.tokens.success,
                      ),
                      SizedBox(width: context.tokens.spaceMd),
                      Expanded(child: Text(l10n.guidePrivacy)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: context.tokens.spaceLg),
              FilledButton(
                onPressed: _navigating ? null : _continueToCountdown,
                child: Text(l10n.guideContinue),
              ),
            ],
          ),
        ),
      ),
    );
    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leaveGuide();
      },
      child: screen,
    );
  }
}
