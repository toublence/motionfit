import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:motionfit_squat/core/ads/ad_service.dart';
import 'package:motionfit_squat/core/ads/ad_unit_ids.dart';
import 'package:motionfit_squat/core/providers.dart';
import 'package:motionfit_squat/features/exercise/application/combined_workout_metrics.dart';
import 'package:motionfit_squat/features/settings/application/preferences_controller.dart';

/// Anchored adaptive banner ad displayed at the bottom of the main screens.
/// It occupies no space until the ad is successfully loaded.
class BottomBannerAd extends ConsumerStatefulWidget {
  const BottomBannerAd({super.key});

  @override
  ConsumerState<BottomBannerAd> createState() => _BottomBannerAdState();
}

class _BottomBannerAdState extends ConsumerState<BottomBannerAd> {
  static const _maxWidth = 720.0;
  static const _retryDelays = <Duration>[
    Duration(seconds: 5),
    Duration(seconds: 15),
    Duration(seconds: 30),
    Duration(minutes: 1),
  ];

  AdService? _service;
  BannerAd? _ad;
  AnchoredAdaptiveBannerAdSize? _adSize;
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

  Future<void> _loadIfReady() async {
    final adUnitId = MotionFitAdUnits.banner;
    if (adUnitId == null ||
        _service?.ready != true ||
        _loading ||
        _loaded ||
        _ad != null) {
      return;
    }

    final mediaQuery = MediaQuery.maybeOf(context);
    if (mediaQuery == null) return;
    final screenWidth = mediaQuery.size.width;
    if (screenWidth <= 0) return;

    _loading = true;
    try {
      final adWidth = math.min(screenWidth, _maxWidth).truncate();
      final size =
          await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(adWidth);
      if (!mounted) {
        _loading = false;
        return;
      }
      if (size == null) {
        debugPrint(
          '[MotionFitAds] adaptive banner size was null, scheduling retry',
        );
        _loading = false;
        _scheduleRetry();
        return;
      }

      final completedWorkoutCount =
          ref.read(combinedWorkoutMetricsProvider).value?.completedWorkoutCount ??
          0;
      final onboardingCompleted = ref
          .read(preferencesControllerProvider)
          .onboardingCompleted;

      ref
          .read(analyticsServiceProvider)
          .adRequested(
            format: 'banner',
            placement: 'bottom_navigation',
            workoutCompletionCount: completedWorkoutCount,
            onboardingCompleted: onboardingCompleted,
          );

      late final BannerAd ad;
      ad = BannerAd(
        adUnitId: adUnitId,
        size: size,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (loadedAd) {
            if (!mounted || !identical(_ad, loadedAd)) {
              unawaited(loadedAd.dispose());
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
                  format: 'banner',
                  placement: 'bottom_navigation',
                  workoutCompletionCount: completedWorkoutCount,
                  onboardingCompleted: onboardingCompleted,
                );
          },
          onAdFailedToLoad: (failedAd, error) {
            if (identical(_ad, failedAd)) {
              _ad = null;
              _adSize = null;
            }
            _loading = false;
            _loaded = false;
            unawaited(failedAd.dispose());
            if (mounted) {
              debugPrint('[MotionFitAds] adaptive banner failed to load: $error');
              ref
                  .read(analyticsServiceProvider)
                  .adFailed(
                    format: 'banner',
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
                  format: 'banner',
                  placement: 'bottom_navigation',
                  workoutCompletionCount: completedWorkoutCount,
                  onboardingCompleted: onboardingCompleted,
                );
          },
          onAdClicked: (_) {
            if (!mounted) return;
            ref
                .read(analyticsServiceProvider)
                .adClick(format: 'banner', placement: 'bottom_navigation');
          },
        ),
      );

      _ad = ad;
      _adSize = size;
      unawaited(ad.load());
    } on Object catch (error) {
      debugPrint(
        '[MotionFitAds] exception during adaptive banner load: $error',
      );
      _loading = false;
      _ad = null;
      _adSize = null;
      if (mounted) {
        _scheduleRetry();
      }
    }
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
    final size = _adSize;
    if (!_loaded || ad == null || size == null) return const SizedBox.shrink();

    return DecoratedBox(
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
            width: size.width.toDouble(),
            height: size.height.toDouble(),
            child: AdWidget(ad: ad),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _service?.removeListener(_onServiceChanged);
    _retryTimer?.cancel();
    final ad = _ad;
    _ad = null;
    _adSize = null;
    if (ad != null) unawaited(ad.dispose());
    super.dispose();
  }
}
