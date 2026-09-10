import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:motionfit_squat/app/localization/generated/app_localizations.dart';
import 'package:motionfit_squat/app/theme/motionfit_tokens.dart';
import 'package:motionfit_squat/core/providers.dart';
import 'package:motionfit_squat/core/widgets/coach_ui.dart';
import 'package:motionfit_squat/core/widgets/responsive_page.dart';
import 'package:motionfit_squat/core/widgets/timelapse_player.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bodyProgressTitle),
        actions: [
          IconButton(
            tooltip: l10n.bodyProgressManualCapture,
            onPressed: _openCapture,
            icon: const Icon(Icons.photo_camera_outlined),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ResponsivePage(
          child: switch (summary) {
            AsyncData(:final value) => _Content(
              summary: value,
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
  const _Content({required this.summary, required this.onRefresh});

  final BodyProgressSummary summary;
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
          if (summary.isEmpty)
            const _EmptyState()
          else ...[
            _BodyTimeline(summary: summary, dateFormat: dateFormat),
            SizedBox(height: context.tokens.spaceXl),
            if (summary.photoCount >= 2) ...[
              CoachSectionHeader(title: l10n.bodyProgressCompare),
              SizedBox(height: context.tokens.space12),
              _HeroComparison(summary: summary, dateFormat: dateFormat),
              SizedBox(height: context.tokens.spaceSm),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton.icon(
                  onPressed: () =>
                      context.push('/records/body-progress/compare'),
                  icon: const Icon(Icons.compare_rounded, size: 18),
                  label: Text(l10n.bodyProgressCompare),
                ),
              ),
              SizedBox(height: context.tokens.spaceLg),
            ],
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
            SizedBox(height: context.tokens.spaceXl),
            _StatsRow(summary: summary),
            SizedBox(height: context.tokens.space12),
            Text(
              l10n.bodyProgressAutoHint,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

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
              Icon(Icons.photo_camera_rounded, size: 36, color: colors.primary),
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
      ],
    );
  }
}

class _BodyTimeline extends StatelessWidget {
  const _BodyTimeline({required this.summary, required this.dateFormat});

  final BodyProgressSummary summary;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (summary.photoCount == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(context.tokens.radiusLg),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: BodyProgressImage(photo: summary.photos.single),
            ),
          ),
          SizedBox(height: context.tokens.spaceSm),
          Text(
            l10n.bodyProgressAutoHint,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }
    return TimelapsePlayer(
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
