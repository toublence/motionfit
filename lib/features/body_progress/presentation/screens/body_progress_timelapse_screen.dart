import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:motionfit_squat/app/localization/generated/app_localizations.dart';
import 'package:motionfit_squat/app/theme/motionfit_tokens.dart';
import 'package:motionfit_squat/core/providers.dart';
import 'package:motionfit_squat/core/widgets/responsive_page.dart';
import 'package:motionfit_squat/core/widgets/timelapse_player.dart';
import 'package:motionfit_squat/features/body_progress/application/body_progress_providers.dart';
import 'package:motionfit_squat/features/body_progress/domain/body_progress_summary.dart';
import 'package:motionfit_squat/features/body_progress/presentation/widgets/body_progress_image.dart';
import 'package:motionfit_squat/features/records/presentation/widgets/record_components.dart';

/// Plays every stored photo of one view back in date order.
///
/// Each frame keeps the same aspect ratio and cover crop, so a series shot with
/// the ghost overlay reads as one continuous change.
class BodyProgressTimelapseScreen extends ConsumerStatefulWidget {
  const BodyProgressTimelapseScreen({super.key});

  @override
  ConsumerState<BodyProgressTimelapseScreen> createState() =>
      _BodyProgressTimelapseScreenState();
}

class _BodyProgressTimelapseScreenState
    extends ConsumerState<BodyProgressTimelapseScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(analyticsServiceProvider).screenView('body_progress_timelapse');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final summary = ref.watch(bodyProgressSummaryProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.bodyProgressTimelapse)),
      body: SafeArea(
        top: false,
        child: ResponsivePage(
          child: switch (summary) {
            AsyncData(:final value) when value.photoCount >= 2 => _Player(
              summary: value,
            ),
            AsyncData() => Center(
              child: Text(
                l10n.bodyProgressTimelapseNeedsTwo,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            AsyncError() => RecordErrorState(
              title: l10n.errorGenericTitle,
              body: l10n.bodyProgressLoadError,
              retryLabel: l10n.commonRetry,
              onRetry: () => ref.invalidate(bodyProgressPhotosProvider),
            ),
            _ => RecordLoadingState(label: l10n.bodyProgressLoading),
          },
        ),
      ),
    );
  }
}

class _Player extends StatelessWidget {
  const _Player({required this.summary});

  final BodyProgressSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    );
    return ListView(
      padding: EdgeInsetsDirectional.only(bottom: context.tokens.spaceXl),
      children: [
        TimelapsePlayer(
          autoPlay: true,
          frameCount: summary.photoCount,
          frameBuilder: (context, index) =>
              BodyProgressImage(photo: summary.photos[index]),
          captionBuilder: (context, index) {
            final photo = summary.photos[index];
            return Row(
              children: [
                Text(
                  l10n.bodyProgressDayNumber(summary.dayNumberOf(photo)),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  dateFormat.format(photo.capturedAt),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
