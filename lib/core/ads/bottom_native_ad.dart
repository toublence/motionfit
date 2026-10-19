import 'ad_slot.dart';
import 'ad_sdk.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:motionfit_squat/core/ads/ad_eligibility.dart';
import 'package:motionfit_squat/features/exercise/application/combined_workout_metrics.dart';

/// Places the existing native ad policy inside scrollable page content.
/// It occupies no space until an ad has loaded successfully.
enum NativeAdPlacement {
  home,
  challenge,
  records,
  workoutSummary,
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
          NativeAdPlacement.workoutSummary => path == '/plank/workout/summary',
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
        return BottomNativeAd(
          inline: true,
          placement: placement.name,
          active:
              active &&
              AdEligibility.canShowNative(
                completedWorkoutCount: completedWorkoutCount,
              ),
        );
      },
    );
  }
}

class BottomNativeAd extends StatelessWidget {
  const BottomNativeAd({
    this.inline = false,
    this.active = true,
    this.placement = 'bottom_navigation',
    super.key,
  });
  final bool inline;
  final bool active;
  final String placement;
  @override
  Widget build(BuildContext context) => AdSlot(
    format: AdFormat.native,
    placement: placement,
    active: active,
    inline: inline,
  );
}
