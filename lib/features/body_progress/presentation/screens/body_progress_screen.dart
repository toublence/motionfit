import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:motionfit_squat/app/localization/generated/app_localizations.dart';
import 'package:motionfit_squat/app/theme/motionfit_tokens.dart';
import 'package:motionfit_squat/core/providers.dart';
import 'package:motionfit_squat/core/widgets/coach_ui.dart';
import 'package:motionfit_squat/core/widgets/responsive_page.dart';
import 'package:motionfit_squat/features/body_progress/application/body_progress_providers.dart';
import 'package:motionfit_squat/features/body_progress/domain/body_progress_photo.dart';
import 'package:motionfit_squat/features/body_progress/domain/body_progress_summary.dart';
import 'package:motionfit_squat/features/body_progress/presentation/widgets/body_progress_image.dart';
import 'package:motionfit_squat/features/body_progress/presentation/widgets/body_progress_widgets.dart';
import 'package:motionfit_squat/features/records/presentation/widgets/record_components.dart';

class BodyProgressScreen extends ConsumerStatefulWidget {
  const BodyProgressScreen({super.key});

  @override
  ConsumerState<BodyProgressScreen> createState() => _BodyProgressScreenState();
}

class _BodyProgressScreenState extends ConsumerState<BodyProgressScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(analyticsServiceProvider).screenView('body_progress');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final summary = ref.watch(bodyProgressSummaryProvider);
    final counts = ref.watch(bodyProgressViewCountsProvider).value ?? const {};
    final selected = ref.watch(selectedBodyViewProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.bodyProgressTitle)),
      body: SafeArea(
        top: false,
        child: ResponsivePage(
          child: switch (summary) {
            AsyncData(:final value) => _Content(
              summary: value,
              counts: counts,
              selected: selected,
              onSelectView: (view) =>
                  ref.read(selectedBodyViewProvider.notifier).select(view),
              onCapture: _openCapture,
              onRefresh: _refresh,
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

  Future<void> _refresh() async {
    ref
      ..invalidate(bodyProgressPhotosProvider)
      ..invalidate(bodyProgressDirectoryProvider);
    await ref.read(bodyProgressPhotosProvider.future);
  }

  Future<void> _openCapture() async {
    await context.push('/records/body-progress/capture');
    if (!mounted) return;
    ref.invalidate(bodyProgressPhotosProvider);
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.summary,
    required this.counts,
    required this.selected,
    required this.onSelectView,
    required this.onCapture,
    required this.onRefresh,
  });

  final BodyProgressSummary summary;
  final Map<BodyView, int> counts;
  final BodyView selected;
  final ValueChanged<BodyView> onSelectView;
  final Future<void> Function() onCapture;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    );
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsetsDirectional.only(bottom: context.tokens.spaceXl),
        children: [
          _AutoStatusBanner(summary: summary),
          SizedBox(height: context.tokens.spaceMd),
          BodyViewSelector(
            selected: selected,
            onSelected: onSelectView,
            counts: counts,
          ),
          SizedBox(height: context.tokens.spaceLg),
          if (summary.isEmpty)
            _EmptyState(onCapture: onCapture)
          else ...[
            _StatsRow(summary: summary),
            SizedBox(height: context.tokens.spaceLg),
            _HeroComparison(summary: summary, dateFormat: dateFormat),
            SizedBox(height: context.tokens.spaceLg),
            // Viewing what was recorded comes first. Capturing by hand is the
            // fallback, not the main action.
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: summary.photoCount < 2
                        ? null
                        : () =>
                              context.push('/records/body-progress/timelapse'),
                    icon: const Icon(Icons.play_arrow_rounded, size: 18),
                    label: Text(
                      l10n.bodyProgressTimelapse,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                SizedBox(width: context.tokens.spaceSm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: summary.photoCount < 2
                        ? null
                        : () => context.push('/records/body-progress/compare'),
                    icon: const Icon(Icons.compare_rounded, size: 18),
                    label: Text(
                      l10n.bodyProgressCompare,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.tokens.spaceSm),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: onCapture,
                icon: const Icon(Icons.photo_camera_outlined, size: 18),
                label: Text(
                  _hasPhotoToday(summary)
                      ? l10n.bodyProgressReplaceToday
                      : l10n.bodyProgressManualCapture,
                ),
              ),
            ),
            SizedBox(height: context.tokens.spaceXl),
            CoachSectionHeader(title: l10n.bodyProgressMilestones),
            SizedBox(height: context.tokens.space12),
            BodyProgressMilestoneStrip(
              summary: summary,
              formatDate: dateFormat.format,
            ),
            SizedBox(height: context.tokens.spaceXl),
            CoachSectionHeader(
              title: l10n.bodyProgressHistory,
              subtitle: l10n.bodyProgressPhotoCount(summary.photoCount),
            ),
            SizedBox(height: context.tokens.space12),
            Consumer(
              builder: (context, ref, _) => BodyProgressHistoryGrid(
                summary: summary,
                captionOf: (photo) => dateFormat.format(photo.capturedAt),
                onDelete: (photo) => _confirmDelete(context, ref, photo),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static bool _hasPhotoToday(BodyProgressSummary summary) {
    final today = BodyProgressPhoto.dayKey(DateTime.now());
    return summary.photos.any((photo) => photo.capturedOn == today);
  }
}


/// Shows whether today's photo is already in, and explains that the app takes
/// it on its own. This replaces the old capture-first framing.
class _AutoStatusBanner extends StatelessWidget {
  const _AutoStatusBanner({required this.summary});

  final BodyProgressSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final today = BodyProgressPhoto.dayKey(DateTime.now());
    final recorded = summary.photos.any(
      (photo) => photo.capturedOn == today,
    );
    return CoachInsightPanel(
      icon: recorded
          ? Icons.check_circle_rounded
          : Icons.auto_awesome_motion_rounded,
      title: recorded
          ? l10n.bodyProgressRecordedToday
          : l10n.bodyProgressPendingToday,
      body: l10n.bodyProgressAutoHint,
      tone: recorded ? CoachStatusTone.positive : CoachStatusTone.brand,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCapture});

  final Future<void> Function() onCapture;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(context.tokens.spaceLg),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(context.tokens.radiusLg),
          ),
          child: Column(
            children: [
              Icon(
                Icons.photo_camera_rounded,
                size: 36,
                color: colors.primary,
              ),
              SizedBox(height: context.tokens.space12),
              Text(
                l10n.bodyProgressAutoEmptyTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: context.tokens.spaceSm),
              Text(
                l10n.bodyProgressAutoEmptyBody,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: context.tokens.spaceLg),
        TextButton.icon(
          onPressed: onCapture,
          icon: const Icon(Icons.photo_camera_outlined, size: 18),
          label: Text(l10n.bodyProgressManualCapture),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.summary});

  final BodyProgressSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return CoachMetricStrip(
      emphasizeFirst: true,
      metrics: [
        CoachMetric(
          value: '${summary.currentDayNumber}',
          label: l10n.bodyProgressSpanDays(summary.spanDays),
          icon: Icons.timeline_rounded,
        ),
        CoachMetric(
          value: '${summary.recordedDayCount}',
          label: l10n.bodyProgressRecordedDays,
          icon: Icons.event_available_rounded,
        ),
        CoachMetric(
          value: '${summary.currentStreakDays}',
          label: l10n.bodyProgressStreak,
          icon: Icons.local_fire_department_rounded,
        ),
      ],
    );
  }
}

/// Day 1 next to the latest photo, the single view that shows the change.
class _HeroComparison extends StatelessWidget {
  const _HeroComparison({required this.summary, required this.dateFormat});

  final BodyProgressSummary summary;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    final first = summary.first;
    final latest = summary.latest;
    if (first == null || latest == null) return const SizedBox.shrink();
    if (identical(first, latest)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(context.tokens.radiusLg),
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: BodyProgressImage(photo: latest),
        ),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: BodyProgressPhotoCard(
            photo: first,
            dayNumber: summary.dayNumberOf(first),
            caption: dateFormat.format(first.capturedAt),
          ),
        ),
        SizedBox(width: context.tokens.space12),
        Expanded(
          child: BodyProgressPhotoCard(
            photo: latest,
            dayNumber: summary.dayNumberOf(latest),
            caption: dateFormat.format(latest.capturedAt),
          ),
        ),
      ],
    );
  }
}

Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  BodyProgressPhoto photo,
) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.bodyProgressDeletePhoto),
        content: Text(l10n.bodyProgressDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.bodyProgressDeletePhoto),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final directory = await ref.read(bodyProgressDirectoryProvider.future);
    await ref
        .read(bodyProgressRepositoryProvider)
        .deletePhoto(photo.id, directory: directory);
    ref.invalidate(bodyProgressPhotosProvider);
}
