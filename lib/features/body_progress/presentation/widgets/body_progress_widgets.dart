import 'package:flutter/material.dart';
import 'package:motionfit_squat/app/localization/generated/app_localizations.dart';
import 'package:motionfit_squat/app/theme/motionfit_tokens.dart';
import 'package:motionfit_squat/features/body_progress/domain/body_progress_photo.dart';
import 'package:motionfit_squat/features/body_progress/domain/body_progress_summary.dart';
import 'package:motionfit_squat/features/body_progress/presentation/widgets/body_progress_image.dart';

String bodyViewLabel(AppLocalizations l10n, BodyView view) => switch (view) {
  BodyView.front => l10n.bodyProgressViewFront,
  BodyView.side => l10n.bodyProgressViewSide,
  BodyView.back => l10n.bodyProgressViewBack,
};

/// Segmented picker for front, side and back framing.
class BodyViewSelector extends StatelessWidget {
  const BodyViewSelector({
    required this.selected,
    required this.onSelected,
    this.counts = const {},
    super.key,
  });

  final BodyView selected;
  final ValueChanged<BodyView> onSelected;
  final Map<BodyView, int> counts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SegmentedButton<BodyView>(
      showSelectedIcon: false,
      segments: [
        for (final view in BodyView.values)
          ButtonSegment<BodyView>(
            value: view,
            label: Text(
              counts[view] == null || counts[view] == 0
                  ? bodyViewLabel(l10n, view)
                  : '${bodyViewLabel(l10n, view)} ${counts[view]}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      selected: {selected},
      onSelectionChanged: (values) => onSelected(values.first),
    );
  }
}

/// A single photo with its day number and date caption.
class BodyProgressPhotoCard extends StatelessWidget {
  const BodyProgressPhotoCard({
    required this.photo,
    required this.dayNumber,
    required this.caption,
    this.onTap,
    this.onLongPress,
    this.expandImage = false,
    super.key,
  });

  final BodyProgressPhoto photo;
  final int dayNumber;
  final String caption;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Lets the image take whatever height is left instead of holding a fixed
  /// ratio. Grid cells have a fixed height, so a card that insists on a ratio
  /// overflows as soon as the caption text grows.
  final bool expandImage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      button: onTap != null,
      label: '${l10n.bodyProgressDayNumber(dayNumber)} $caption',
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(context.tokens.radiusMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (expandImage)
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(context.tokens.radiusMd),
                  child: BodyProgressImage(photo: photo),
                ),
              )
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(context.tokens.radiusMd),
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: BodyProgressImage(photo: photo),
                ),
              ),
            SizedBox(height: context.tokens.spaceSm),
            Text(
              l10n.bodyProgressDayNumber(dayNumber),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

/// Day 1 / 7 / 30 / 90 thumbnails, greyed out until each is reached.
class BodyProgressMilestoneStrip extends StatelessWidget {
  const BodyProgressMilestoneStrip({
    required this.summary,
    required this.formatDate,
    super.key,
  });

  final BodyProgressSummary summary;
  final String Function(DateTime) formatDate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final milestones = summary.milestones;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < milestones.length; index++) ...[
          if (index > 0) SizedBox(width: context.tokens.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(context.tokens.radiusSm),
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: milestones[index].photo == null
                        ? ColoredBox(
                            color: colors.surfaceContainerHighest,
                            child: Icon(
                              Icons.more_horiz_rounded,
                              color: colors.onSurfaceVariant,
                            ),
                          )
                        : BodyProgressImage(photo: milestones[index].photo!),
                  ),
                ),
                SizedBox(height: context.tokens.spaceXs),
                Text(
                  l10n.bodyProgressDayNumber(milestones[index].day),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  milestones[index].photo == null
                      ? l10n.bodyProgressMilestonePending
                      : formatDate(milestones[index].photo!.capturedAt),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Photo history, newest first.
///
/// Cells size themselves from the available width and let the image absorb the
/// leftover height, so a longer caption or a larger system font shrinks the
/// picture instead of overflowing the cell.
class BodyProgressHistoryGrid extends StatelessWidget {
  const BodyProgressHistoryGrid({
    required this.summary,
    required this.captionOf,
    this.onDelete,
    super.key,
  });

  final BodyProgressSummary summary;
  final String Function(BodyProgressPhoto photo) captionOf;
  final void Function(BodyProgressPhoto photo)? onDelete;

  @override
  Widget build(BuildContext context) {
    final newestFirst = summary.photos.reversed.toList(growable: false);
    final textScaler = MediaQuery.textScalerOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        const columns = 3;
        final spacing = context.tokens.space12;
        final cellWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        // Room for the picture at its natural ratio plus both caption lines,
        // measured at the viewer's text scale rather than assumed.
        final captionHeight = textScaler.scale(16) + textScaler.scale(14) + 4;
        final cellHeight = cellWidth * 4 / 3 + context.tokens.spaceSm +
            captionHeight;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            mainAxisExtent: cellHeight,
          ),
          itemCount: newestFirst.length,
          itemBuilder: (context, index) {
            final photo = newestFirst[index];
            return BodyProgressPhotoCard(
              photo: photo,
              dayNumber: summary.dayNumberOf(photo),
              caption: captionOf(photo),
              expandImage: true,
              onLongPress: onDelete == null ? null : () => onDelete!(photo),
            );
          },
        );
      },
    );
  }
}
