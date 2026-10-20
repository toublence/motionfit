import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:motionfit_squat/core/providers.dart';
import 'package:motionfit_squat/features/settings/application/preferences_controller.dart';

import 'ad_service.dart';

/// Only actual app entries create an opportunity: route changes, ATT dialogs,
/// notification shade and returning from an ad must not open another ad.
class AppOpenGate extends ConsumerStatefulWidget {
  const AppOpenGate({super.key, required this.router, required this.child});
  final GoRouter router;
  final Widget child;
  @override
  ConsumerState<AppOpenGate> createState() => _AppOpenGateState();
}

class _AppOpenGateState extends ConsumerState<AppOpenGate>
    with WidgetsBindingObserver {
  late final AdService _ads;
  bool _backgrounded = false;

  @override
  void initState() {
    super.initState();
    _ads = ref.read(adServiceProvider);
    WidgetsBinding.instance.addObserver(this);
    widget.router.routeInformationProvider.addListener(_routeChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _begin('cold_start');
    });
  }

  bool get _allowedRoute => const {
    '/squat',
    '/records',
    '/challenge',
    '/settings',
  }.contains(widget.router.routeInformationProvider.value.uri.path);

  void _routeChanged() {
    if (!_allowedRoute) _ads.cancelAppOpenOpportunity('route_changed');
  }

  void _begin(String trigger) {
    final preferences = ref.read(preferencesControllerProvider);
    final controller = ref.read(preferencesControllerProvider.notifier);
    _ads.updateOnboardingContext(preferences.onboardingCompleted);
    final countEntry =
        preferences.onboardingCompleted &&
        _allowedRoute &&
        !_ads.fullScreenShowing;
    final visitCount = preferences.appOpenVisitCount + (countEntry ? 1 : 0);
    if (countEntry) {
      unawaited(
        controller.recordAppOpenVisit().catchError(
          (Object _) => _ads.record('mf2_ad_visit_persist_failed', {
            'ad_format': 'appOpen',
          }),
        ),
      );
    }
    _ads.beginAppOpenOpportunity(
      trigger: trigger,
      appEntryCount: visitCount,
      lastFullScreenShownAt: preferences.lastInterstitialShownAt,
      isOpportunityValid: () =>
          mounted &&
          _allowedRoute &&
          _ads.foreground &&
          ref.read(preferencesControllerProvider).onboardingCompleted,
      onShown: (at) => unawaited(
        controller
            .markInterstitialShown(shownAt: at)
            .catchError(
              (Object _) => _ads.record('mf2_ad_cooldown_persist_failed', {
                'ad_format': 'appOpen',
                'ad_placement': 'app_open',
              }),
            ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _backgrounded = !_ads.fullScreenShowing;
    } else if (state == AppLifecycleState.resumed && _backgrounded) {
      _backgrounded = false;
      _begin('foreground');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.router.routeInformationProvider.removeListener(_routeChanged);
    _ads.cancelAppOpenOpportunity('gate_disposed', notify: false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _ads,
    builder: (context, _) => Stack(
      children: [
        widget.child,
        if (_ads.appOpenPending)
          Positioned.fill(
            child: BlockSemantics(
              child: Material(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
      ],
    ),
  );
}
