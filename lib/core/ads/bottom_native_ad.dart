import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:motionfit_squat/core/ads/ad_service.dart';
import 'package:motionfit_squat/core/ads/ad_eligibility.dart';
import 'package:motionfit_squat/core/ads/ad_unit_ids.dart';
import 'package:motionfit_squat/core/providers.dart';
import 'package:motionfit_squat/features/exercise/application/combined_workout_metrics.dart';
import 'package:motionfit_squat/features/settings/application/preferences_controller.dart';

/// Places the existing native ad policy inside scrollable page content.
/// It occupies no space until an ad has loaded successfully.
enum NativeAdPlacement {
  home,
  challenge,
  records,
  workoutDetail,
  repReview,
  settings,
}

class NativeAdSection extends ConsumerWidget {
  const NativeAdSection({required this.placement, super.key});

  final NativeAdPlacement placement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter.maybeOf(context);
    if (router == null) return const SizedBox.shrink();
    return ListenableBuilder(
      listenable: router.routerDelegate,
      builder: (context, _) {
        final path = router.routerDelegate.currentConfiguration.uri.path;
        final active = switch (placement) {
          NativeAdPlacement.home => path == '/squat',
          NativeAdPlacement.challenge => path == '/challenge',
          NativeAdPlacement.records => path == '/records',
          NativeAdPlacement.workoutDetail =>
            ModalRoute.of(context)?.isCurrent ?? false,
          NativeAdPlacement.repReview =>
            ModalRoute.of(context)?.isCurrent ?? false,
          NativeAdPlacement.settings => path == '/settings',
        };
        final completedWorkoutCount =
            ref
                .watch(combinedWorkoutMetricsProvider)
                .value
                ?.completedWorkoutCount ??
            0;
        if (!active ||
            !AdEligibility.canShowNative(
              completedWorkoutCount: completedWorkoutCount,
            )) {
          return const SizedBox.shrink();
        }
        return const BottomNativeAd(inline: true);
      },
    );
  }
}

class BottomNativeAd extends ConsumerStatefulWidget {
  const BottomNativeAd({this.inline = false, super.key});

  final bool inline;

  @override
  ConsumerState<BottomNativeAd> createState() => _BottomNativeAdState();
}

class _BottomNativeAdState extends ConsumerState<BottomNativeAd> {
  static const _iosHeight = 101.0;
  static const _maxWidth = 720.0;
  static const _androidSmallTemplateAspectRatio = 4.0;
  static const _retryDelays = <Duration>[
    Duration(seconds: 5),
    Duration(seconds: 15),
    Duration(seconds: 30),
    Duration(minutes: 1),
  ];

  AdService? _service;
  NativeAd? _ad;
  Timer? _retryTimer;
  bool _loaded = false;
  bool _loading = false;
  int _failures = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final service = ref.read(adServiceProvider);
    if (!identical(service, _service)) {
      _service?.removeListener(_onServiceChanged);
      _service = service..addListener(_onServiceChanged);
    }
    _loadIfReady();
  }

  void _onServiceChanged() {
    if (mounted) _loadIfReady();
  }

  void _loadIfReady() {
    final adUnitId = MotionFitAdUnits.native;
    if (adUnitId == null ||
        _service?.ready != true ||
        _loading ||
        _loaded ||
        _ad != null) {
      return;
    }

    final colors = Theme.of(context).colorScheme;
    final completedWorkoutCount =
        ref.read(combinedWorkoutMetricsProvider).value?.completedWorkoutCount ??
        0;
    final onboardingCompleted = ref
        .read(preferencesControllerProvider)
        .onboardingCompleted;
    _loading = true;
    ref
        .read(analyticsServiceProvider)
        .adRequested(
          format: 'native',
          placement: 'bottom_navigation',
          workoutCompletionCount: completedWorkoutCount,
          onboardingCompleted: onboardingCompleted,
        );
    late final NativeAd ad;
    ad = NativeAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          if (!mounted || !identical(_ad, ad)) {
            unawaited(ad.dispose());
            return;
          }
          _retryTimer?.cancel();
          _failures = 0;
          setState(() {
            _loading = false;
            _loaded = true;
          });
          ref
              .read(analyticsServiceProvider)
              .adLoaded(
                format: 'native',
                placement: 'bottom_navigation',
                workoutCompletionCount: completedWorkoutCount,
                onboardingCompleted: onboardingCompleted,
              );
        },
        onAdFailedToLoad: (_, error) {
          if (identical(_ad, ad)) _ad = null;
          _loading = false;
          _loaded = false;
          unawaited(ad.dispose());
          if (mounted) {
            debugPrint('[MotionFitAds] native failed to load: $error');
            ref
                .read(analyticsServiceProvider)
                .adFailed(
                  format: 'native',
                  placement: 'bottom_navigation',
                  failureStage: 'load',
                  workoutCompletionCount: completedWorkoutCount,
                  onboardingCompleted: onboardingCompleted,
                );
            _scheduleRetry();
          }
        },
        onAdImpression: (_) {
          if (!mounted) return;
          ref
              .read(analyticsServiceProvider)
              .adShown(
                format: 'native',
                placement: 'bottom_navigation',
                workoutCompletionCount: completedWorkoutCount,
                onboardingCompleted: onboardingCompleted,
              );
        },
        onAdClicked: (_) {
          if (!mounted) return;
          ref
              .read(analyticsServiceProvider)
              .adClick(format: 'native', placement: 'bottom_navigation');
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
        mainBackgroundColor: colors.surface,
        cornerRadius: 10,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: colors.onPrimary,
          backgroundColor: colors.primary,
          style: NativeTemplateFontStyle.bold,
          size: 14,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: colors.onSurface,
          backgroundColor: colors.surface,
          style: NativeTemplateFontStyle.bold,
          size: 15,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: colors.onSurfaceVariant,
          backgroundColor: colors.surface,
          size: 12,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: colors.onSurfaceVariant,
          backgroundColor: colors.surface,
          size: 12,
        ),
      ),
    );
    _ad = ad;
    unawaited(ad.load());
  }

  void _scheduleRetry() {
    if (_retryTimer?.isActive == true) return;
    final index = _failures.clamp(0, _retryDelays.length - 1).toInt();
    _failures++;
    _retryTimer = Timer(_retryDelays[index], _loadIfReady);
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!_loaded || ad == null) return const SizedBox.shrink();
    return Padding(
      padding: widget.inline
          ? const EdgeInsets.symmetric(vertical: 24)
          : EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final adWidth = math.min(constraints.maxWidth, _maxWidth);
          final adHeight = Platform.isAndroid
              ? adWidth / _androidSmallTemplateAspectRatio
              : _iosHeight;
          return ClipRect(
            child: SizedBox(
              width: double.infinity,
              height: adHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.outlineVariant.withValues(alpha: .45),
                    ),
                  ),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _maxWidth),
                    child: SizedBox(
                      width: double.infinity,
                      height: adHeight,
                      child: AdWidget(ad: ad),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _service?.removeListener(_onServiceChanged);
    _retryTimer?.cancel();
    final ad = _ad;
    _ad = null;
    if (ad != null) unawaited(ad.dispose());
    super.dispose();
  }
}
