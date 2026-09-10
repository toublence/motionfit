import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:motionfit_squat/app/localization/generated/app_localizations.dart';
import 'package:motionfit_squat/app/theme/exercise_colors.dart';
import 'package:motionfit_squat/app/theme/motionfit_tokens.dart';
import 'package:motionfit_squat/core/providers.dart';
import 'package:motionfit_squat/core/widgets/coach_ui.dart';
import 'package:motionfit_squat/core/widgets/responsive_page.dart';
import 'package:motionfit_squat/features/exercise/domain/exercise_type.dart';
import 'package:motionfit_squat/features/form_progress/application/form_progress_providers.dart';
import 'package:motionfit_squat/features/form_progress/domain/form_progress_series.dart';
import 'package:motionfit_squat/features/form_progress/presentation/widgets/form_pose_figure.dart';
import 'package:motionfit_squat/features/form_progress/presentation/widgets/form_progress_widgets.dart';
import 'package:motionfit_squat/features/records/presentation/widgets/record_components.dart';

/// Exercise picker for Form Progress.
///
/// Each card shows where that exercise stands so the user can tell at a glance
/// which one has enough history to be worth opening.
class FormProgressScreen extends ConsumerStatefulWidget {
  const FormProgressScreen({super.key});

  @override
  ConsumerState<FormProgressScreen> createState() => _FormProgressScreenState();
}

class _FormProgressScreenState extends ConsumerState<FormProgressScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(analyticsServiceProvider).screenView('form_progress');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final squat = ref.watch(formProgressSeriesProvider(ExerciseType.squat));
    final pushup = ref.watch(formProgressSeriesProvider(ExerciseType.pushup));
    final plank = ref.watch(formProgressSeriesProvider(ExerciseType.plank));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.formProgressTitle)),
      body: SafeArea(
        top: false,
        child: ResponsivePage(
          child: switch ((squat, pushup, plank)) {
            (
              AsyncData(value: final squatSeries),
              AsyncData(value: final pushupSeries),
              AsyncData(value: final plankSeries),
            ) =>
              _Content(
                series: [squatSeries, pushupSeries, plankSeries],
                onRefresh: _refresh,
              ),
            (AsyncError(), _, _) ||
            (_, AsyncError(), _) ||
            (_, _, AsyncError()) => RecordErrorState(
              title: l10n.errorGenericTitle,
              body: l10n.formProgressLoadError,
              retryLabel: l10n.commonRetry,
              onRetry: _invalidate,
            ),
            _ => RecordLoadingState(label: l10n.formProgressLoading),
          },
        ),
      ),
    );
  }

  void _invalidate() {
    for (final exercise in ExerciseType.values) {
      ref.invalidate(formProgressSeriesProvider(exercise));
    }
  }

  Future<void> _refresh() async {
    _invalidate();
    await ref.read(formProgressSeriesProvider(ExerciseType.squat).future);
  }
}

class _Content extends ConsumerWidget {
  const _Content({required this.series, required this.onRefresh});

  final List<FormProgressSeries> series;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final hasAny = series.any((entry) => !entry.isEmpty);
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsetsDirectional.only(bottom: context.tokens.spaceXl),
        children: [
          CoachInsightPanel(
            icon: Icons.auto_awesome_motion_rounded,
            title: l10n.formProgressSubtitle,
            body: l10n.formProgressAutoHint,
            tone: CoachStatusTone.brand,
          ),
          SizedBox(height: context.tokens.spaceLg),
          if (!hasAny) ...[
            _EmptyState(),
            SizedBox(height: context.tokens.spaceLg),
          ],
          for (final entry in series) ...[
            _ExerciseCard(
              series: entry,
              onTap: () {
                ref
                    .read(selectedFormExerciseProvider.notifier)
                    .select(entry.exerciseType);
                context.push(
                  '/records/form-progress/${entry.exerciseType.name}',
                );
              },
            ),
            SizedBox(height: context.tokens.space12),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(context.tokens.spaceLg),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(context.tokens.radiusLg),
      ),
      child: Column(
        children: [
          Icon(Icons.insights_rounded, size: 36, color: colors.primary),
          SizedBox(height: context.tokens.space12),
          Text(
            l10n.formProgressEmptyTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: context.tokens.spaceSm),
          Text(
            l10n.formProgressAutoEmptyBody,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.series, required this.onTap});

  final FormProgressSeries series;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final accent = ExerciseColors.of(series.exerciseType);
    final label = formExerciseLabel(l10n, series.exerciseType);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: series.isEmpty ? null : onTap,
        child: Padding(
          padding: EdgeInsets.all(context.tokens.spaceMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: context.tokens.spaceSm),
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (!series.isEmpty)
                    Text(
                      l10n.formProgressSessionCount(series.sessionCount),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  if (!series.isEmpty) const Icon(Icons.chevron_right_rounded),
                ],
              ),
              if (series.isEmpty)
                Padding(
                  padding: EdgeInsets.only(top: context.tokens.spaceSm),
                  child: Text(
                    l10n.formProgressAutoEmptyBody,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                )
              else ...[
                SizedBox(height: context.tokens.space12),
                if (series.poseSnapshots.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      context.tokens.radiusMd,
                    ),
                    child: AspectRatio(
                      aspectRatio: 16 / 10,
                      child: FormPoseFigure(
                        snapshot: series.poseSnapshots.last,
                        color: accent,
                      ),
                    ),
                  ),
                SizedBox(height: context.tokens.spaceSm),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        series.poseSnapshots.length >= 2
                            ? '${l10n.bodyProgressDayNumber(1)} → '
                                  '${l10n.bodyProgressDayNumber(series.dayNumberOfSnapshot(series.poseSnapshots.last))}'
                            : l10n.bodyProgressDayNumber(1),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Text(
                      '${formatFormScore(series.firstScore)} → '
                      '${formatFormScore(series.latestScore)}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
