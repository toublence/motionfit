import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:motionfit_squat/app/localization/generated/app_localizations.dart';
import 'package:motionfit_squat/core/analytics/analytics_service.dart';
import 'package:motionfit_squat/core/providers.dart';
import 'package:motionfit_squat/features/settings/application/preferences_controller.dart';

import 'onboarding_copy.dart';
import 'onboarding_demo.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _totalSteps = 3;
  final _controller = PageController();
  late final DateTime _startedAt;
  int _index = 0;
  bool _finishing = false;
  bool _transitioning = false;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_startOnboardingSession());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final copy = OnboardingCopy.forLocale(Localizations.localeOf(context));
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    return PopScope(
      canPop: _index == 0 && !_finishing,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _index > 0 && !_finishing && !_transitioning) {
          ref
              .read(analyticsServiceProvider)
              .onboardingBackTapped(
                stepIndex: _index,
                stepName: AnalyticsService.onboardingStepName(_index),
                totalSteps: _totalSteps,
                elapsed: DateTime.now().difference(_startedAt),
              );
          unawaited(_moveTo(_index - 1));
        }
      },
      child: Scaffold(
        backgroundColor: onboardingBackground,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(28, 12, 28, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'MotionFit',
                            style: TextStyle(
                              color: onboardingMuted,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        TextButton(
                          key: const ValueKey('onboarding_skip'),
                          onPressed: _finishing ? null : _skip,
                          style: TextButton.styleFrom(
                            foregroundColor: onboardingMuted,
                          ),
                          child: Text(copy['onboarding_skip']),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: PageView.builder(
                        controller: _controller,
                        itemCount: _totalSteps,
                        physics: _finishing || _transitioning
                            ? const NeverScrollableScrollPhysics()
                            : null,
                        onPageChanged: _onPageChanged,
                        itemBuilder: (context, index) => _OnboardingPage(
                          step: index,
                          copy: copy,
                          active: index == _index,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Semantics(
                      label: MaterialLocalizations.of(
                        context,
                      ).tabLabel(tabIndex: _index + 1, tabCount: _totalSteps),
                      child: ExcludeSemantics(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _totalSteps,
                            (index) => AnimatedContainer(
                              duration: Duration(
                                milliseconds: reducedMotion ? 0 : 180,
                              ),
                              width: index == _index ? 7 : 5,
                              height: index == _index ? 7 : 5,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: index == _index
                                    ? onboardingGood
                                    : onboardingMuted.withValues(alpha: .3),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      key: ValueKey(
                        _index == 2 ? 'welcome_try' : 'onboarding_next',
                      ),
                      onPressed: _finishing || _transitioning
                          ? null
                          : _continue,
                      style: FilledButton.styleFrom(
                        backgroundColor: onboardingGood,
                        foregroundColor: onboardingBackground,
                        disabledBackgroundColor: onboardingGood.withValues(
                          alpha: .45,
                        ),
                        minimumSize: const Size.fromHeight(60),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: _finishing
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: onboardingBackground,
                              ),
                            )
                          : Text(
                              copy[_index == 2
                                  ? 'onboarding_start'
                                  : 'onboarding_next'],
                              textAlign: TextAlign.center,
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

  Future<void> _moveTo(int page) async {
    if (_transitioning || _finishing) return;
    setState(() => _transitioning = true);
    try {
      if (MediaQuery.disableAnimationsOf(context)) {
        _controller.jumpToPage(page);
      } else {
        await _controller.animateToPage(
          page,
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeInOutCubic,
        );
      }
    } finally {
      if (mounted) setState(() => _transitioning = false);
    }
  }

  Future<void> _skip() async {
    if (_finishing) return;
    ref
        .read(analyticsServiceProvider)
        .onboardingSkipped(
          stepIndex: _index,
          stepName: AnalyticsService.onboardingStepName(_index),
          totalSteps: _totalSteps,
          elapsed: DateTime.now().difference(_startedAt),
        );
    await _finish();
  }

  Future<void> _startOnboardingSession() async {
    final preferences = ref.read(preferencesControllerProvider);
    final analytics = ref.read(analyticsServiceProvider);
    analytics.screenView('onboarding');
    final previousStartedAt = preferences.onboardingStartedAt;
    if (!preferences.onboardingCompleted && previousStartedAt != null) {
      analytics.onboardingAbandoned(
        stepIndex: preferences.onboardingLastStep,
        totalSteps: _totalSteps,
        elapsed: _startedAt.difference(previousStartedAt),
        exitReason: 'app_closed',
      );
    }
    analytics
      ..onboardingStarted(totalSteps: _totalSteps)
      ..onboardingStepViewed(
        stepIndex: 0,
        stepName: AnalyticsService.onboardingStepName(0),
        totalSteps: _totalSteps,
        elapsed: Duration.zero,
      );
    try {
      await ref
          .read(preferencesControllerProvider.notifier)
          .markOnboardingStarted(_startedAt);
    } on Object {
      // Analytics persistence must never block onboarding.
    }
  }

  void _onPageChanged(int value) {
    setState(() => _index = value);
    final analytics = ref.read(analyticsServiceProvider);
    analytics.onboardingStepViewed(
      stepIndex: value,
      stepName: AnalyticsService.onboardingStepName(value),
      totalSteps: _totalSteps,
      elapsed: DateTime.now().difference(_startedAt),
    );
    unawaited(
      ref
          .read(preferencesControllerProvider.notifier)
          .markOnboardingStep(value)
          .catchError((Object _) {}),
    );
  }

  Future<void> _continue() async {
    ref
        .read(analyticsServiceProvider)
        .onboardingNextTapped(
          stepIndex: _index,
          stepName: AnalyticsService.onboardingStepName(_index),
          totalSteps: _totalSteps,
          elapsed: DateTime.now().difference(_startedAt),
        );
    if (_index < 2) {
      await _moveTo(_index + 1);
      return;
    }

    await _finish();
  }

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() => _finishing = true);
    try {
      await ref
          .read(preferencesControllerProvider.notifier)
          .completeOnboarding();
      if (!mounted) return;
      ref
          .read(analyticsServiceProvider)
          .onboardingComplete(
            totalSteps: _totalSteps,
            elapsed: DateTime.now().difference(_startedAt),
          );
      await ref
          .read(privacyConsentServiceProvider)
          .requestTrackingAuthorization();
      if (mounted) {
        context.go('/squat');
      }
    } on Object {
      if (!mounted) return;
      setState(() => _finishing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).errorGenericBody)),
      );
    }
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.step,
    required this.copy,
    required this.active,
  });
  final int step;
  final OnboardingCopy copy;
  final bool active;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxHeight < 500 || constraints.maxWidth < 304;
      return SingleChildScrollView(
        key: PageStorageKey('onboarding_scroll_$step'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                copy[[
                  'onboarding_measure_heading',
                  'onboarding_improve_heading',
                  'onboarding_try_heading',
                ][step]],
                style: TextStyle(
                  fontSize: compact ? 27 : 32,
                  height: 1.3,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -.6,
                  color: onboardingText,
                ),
              ),
            ),
            if (step == 2) ...[
              const SizedBox(height: 12),
              Text(
                copy['onboarding_try_body'],
                style: const TextStyle(fontSize: 16, color: onboardingMuted),
              ),
            ],
            SizedBox(height: compact ? 12 : 24),
            SizedBox(
              height: math.max(
                360,
                constraints.maxHeight - (step == 2 ? 150 : 200),
              ),
              child: TickerMode(
                enabled: active,
                child: OnboardingDemo(
                  key: ValueKey(step),
                  step: step,
                  copy: copy,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
