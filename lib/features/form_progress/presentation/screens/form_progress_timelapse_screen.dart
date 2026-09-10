import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:motionfit_squat/app/localization/generated/app_localizations.dart';
import 'package:motionfit_squat/app/theme/exercise_colors.dart';
import 'package:motionfit_squat/app/theme/motionfit_tokens.dart';
import 'package:motionfit_squat/core/providers.dart';
import 'package:motionfit_squat/core/widgets/responsive_page.dart';
import 'package:motionfit_squat/core/widgets/timelapse_player.dart';
import 'package:motionfit_squat/features/exercise/domain/exercise_type.dart';
import 'package:motionfit_squat/features/form_progress/application/form_progress_providers.dart';
import 'package:motionfit_squat/features/form_progress/domain/form_progress_series.dart';
import 'package:motionfit_squat/features/form_progress/presentation/widgets/form_pose_figure.dart';
import 'package:motionfit_squat/features/form_progress/presentation/widgets/form_progress_widgets.dart';
import 'package:motionfit_squat/features/records/presentation/widgets/record_components.dart';

/// Plays one exercise's representative poses back in date order.
///
/// Unlike the Body Progress timelapse this shows the same movement repeated
/// over weeks, with the form score rising alongside it.
class FormProgressTimelapseScreen extends ConsumerStatefulWidget {
  const FormProgressTimelapseScreen({required this.exerciseType, super.key});

  final ExerciseType exerciseType;

  @override
  ConsumerState<FormProgressTimelapseScreen> createState() =>
      _FormProgressTimelapseScreenState();
}

class _FormProgressTimelapseScreenState
    extends ConsumerState<FormProgressTimelapseScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(analyticsServiceProvider).screenView('form_progress_timelapse');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final series = ref.watch(formProgressSeriesProvider(widget.exerciseType));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.formProgressTimelapse)),
      body: SafeArea(
        top: false,
        child: ResponsivePage(
          child: switch (series) {
            AsyncData(:final value) when value.posedPoints.length >= 2 =>
              _Player(series: value),
            AsyncData() => Center(
              child: Text(
                l10n.formProgressNeedsTwoSessions,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            AsyncError() => RecordErrorState(
              title: l10n.errorGenericTitle,
              body: l10n.formProgressLoadError,
              retryLabel: l10n.commonRetry,
              onRetry: () => ref.invalidate(
                formProgressSeriesProvider(widget.exerciseType),
              ),
            ),
            _ => RecordLoadingState(label: l10n.formProgressLoading),
          },
        ),
      ),
    );
  }
}

class _Player extends StatelessWidget {
  const _Player({required this.series});

  final FormProgressSeries series;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    );
    final posed = series.posedPoints;
    final accent = ExerciseColors.of(series.exerciseType);
    return ListView(
      padding: EdgeInsetsDirectional.only(bottom: context.tokens.spaceXl),
      children: [
        Text(
          formExerciseLabel(l10n, series.exerciseType),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: context.tokens.space12),
        TimelapsePlayer(
          frameCount: posed.length,
          frameBuilder: (context, index) => FormPoseFigure(
            snapshot: series.poseFor(posed[index])!,
            color: accent,
          ),
          captionBuilder: (context, index) {
            final point = posed[index];
            final pose = series.poseFor(point)!;
            return Row(
              children: [
                Text(
                  l10n.bodyProgressDayNumber(series.dayNumberOf(point)),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(width: context.tokens.spaceSm),
                Text(
                  '${l10n.formProgressScoreLabel} '
                  '${formatFormScore(pose.formScore)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  dateFormat.format(point.workoutDate),
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
