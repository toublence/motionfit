import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:motionfit_squat/features/records/presentation/widgets/record_components.dart';

/// Side-by-side and wipe comparison of any two stored photos.
class BodyProgressCompareScreen extends ConsumerStatefulWidget {
  const BodyProgressCompareScreen({super.key});

  @override
  ConsumerState<BodyProgressCompareScreen> createState() =>
      _BodyProgressCompareScreenState();
}

class _BodyProgressCompareScreenState
    extends ConsumerState<BodyProgressCompareScreen> {
  int? _beforeIndex;
  int? _afterIndex;
  double _wipe = 0.5;

  @override
  void initState() {
    super.initState();
    ref.read(analyticsServiceProvider).screenView('body_progress_compare');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final summary = ref.watch(bodyProgressSummaryProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.bodyProgressCompare)),
      body: SafeArea(
        top: false,
        child: ResponsivePage(
          child: switch (summary) {
            AsyncData(:final value) when value.photoCount >= 2 => _Content(
              summary: value,
              beforeIndex: _beforeIndex ?? 0,
              afterIndex: _afterIndex ?? value.photoCount - 1,
              wipe: _wipe,
              onBefore: (index) => setState(() => _beforeIndex = index),
              onAfter: (index) => setState(() => _afterIndex = index),
              onWipe: (value) => setState(() => _wipe = value),
            ),
            AsyncData() => Center(
              child: Text(
                l10n.bodyProgressCompareNeedsTwo,
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

class _Content extends StatelessWidget {
  const _Content({
    required this.summary,
    required this.beforeIndex,
    required this.afterIndex,
    required this.wipe,
    required this.onBefore,
    required this.onAfter,
    required this.onWipe,
  });

  final BodyProgressSummary summary;
  final int beforeIndex;
  final int afterIndex;
  final double wipe;
  final ValueChanged<int> onBefore;
  final ValueChanged<int> onAfter;
  final ValueChanged<double> onWipe;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    );
    final photos = summary.photos;
    final before = photos[beforeIndex.clamp(0, photos.length - 1)];
    final after = photos[afterIndex.clamp(0, photos.length - 1)];
    return ListView(
      padding: EdgeInsetsDirectional.only(bottom: context.tokens.spaceXl),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(context.tokens.radiusLg),
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: _WipeComparison(before: before, after: after, wipe: wipe),
          ),
        ),
        SizedBox(height: context.tokens.spaceSm),
        Slider(
          value: wipe,
          label: l10n.bodyProgressCompareHint,
          onChanged: onWipe,
        ),
        Text(
          l10n.bodyProgressCompareHint,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: context.tokens.spaceLg),
        _PhotoPicker(
          title: l10n.bodyProgressCompareBefore,
          summary: summary,
          selectedIndex: beforeIndex,
          onSelected: onBefore,
          dateFormat: dateFormat,
        ),
        SizedBox(height: context.tokens.spaceLg),
        _PhotoPicker(
          title: l10n.bodyProgressCompareAfter,
          summary: summary,
          selectedIndex: afterIndex,
          onSelected: onAfter,
          dateFormat: dateFormat,
        ),
      ],
    );
  }
}

class _WipeComparison extends StatelessWidget {
  const _WipeComparison({
    required this.before,
    required this.after,
    required this.wipe,
  });

  final BodyProgressPhoto before;
  final BodyProgressPhoto after;
  final double wipe;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        fit: StackFit.expand,
        children: [
          BodyProgressImage(photo: after),
          ClipRect(
            clipper: _WipeClipper(fraction: wipe),
            child: BodyProgressImage(photo: before),
          ),
          PositionedDirectional(
            start: constraints.maxWidth * wipe - 1,
            top: 0,
            bottom: 0,
            child: const ColoredBox(
              color: Colors.white,
              child: SizedBox(width: 2),
            ),
          ),
          PositionedDirectional(
            start: context.tokens.spaceSm,
            top: context.tokens.spaceSm,
            child: _Tag(label: l10n.bodyProgressCompareBefore),
          ),
          PositionedDirectional(
            end: context.tokens.spaceSm,
            top: context.tokens.spaceSm,
            child: _Tag(label: l10n.bodyProgressCompareAfter),
          ),
        ],
      ),
    );
  }
}

class _WipeClipper extends CustomClipper<Rect> {
  const _WipeClipper({required this.fraction});

  final double fraction;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width * fraction, size.height);

  @override
  bool shouldReclip(_WipeClipper oldClipper) =>
      oldClipper.fraction != fraction;
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: context.tokens.cameraOverlay,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({
    required this.title,
    required this.summary,
    required this.selectedIndex,
    required this.onSelected,
    required this.dateFormat,
  });

  final String title;
  final BodyProgressSummary summary;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CoachSectionHeader(title: title),
        SizedBox(height: context.tokens.spaceSm),
        SizedBox(
          // Thumbnail plus its day label, measured at the viewer's text scale
          // so a larger system font does not clip the row.
          height: 96 + MediaQuery.textScalerOf(context).scale(16) + 8,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: summary.photoCount,
            separatorBuilder: (context, index) =>
                SizedBox(width: context.tokens.spaceSm),
            itemBuilder: (context, index) {
              final photo = summary.photos[index];
              final selected = index == selectedIndex;
              return Semantics(
                selected: selected,
                button: true,
                label:
                    '$title ${l10n.bodyProgressDayNumber(summary.dayNumberOf(photo))}',
                child: InkWell(
                  onTap: () => onSelected(index),
                  borderRadius: BorderRadius.circular(context.tokens.radiusSm),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            context.tokens.radiusSm,
                          ),
                          border: Border.all(
                            color: selected
                                ? colors.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            context.tokens.radiusSm - 2,
                          ),
                          child: SizedBox(
                            width: 66,
                            height: 88,
                            child: BodyProgressImage(photo: photo),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.bodyProgressDayNumber(summary.dayNumberOf(photo)),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
