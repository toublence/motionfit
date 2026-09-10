import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motionfit_squat/app/localization/generated/app_localizations.dart';
import 'package:motionfit_squat/app/theme/motionfit_tokens.dart';
import 'package:motionfit_squat/features/body_progress/application/body_progress_providers.dart';
import 'package:motionfit_squat/features/body_progress/domain/body_progress_photo.dart';

/// Renders a stored Body Progress photo.
///
/// The image directory is resolved at runtime rather than stored, so this
/// widget waits for that path before showing anything.
class BodyProgressImage extends ConsumerWidget {
  const BodyProgressImage({
    required this.photo,
    this.fit = BoxFit.cover,
    this.opacity = 1,
    super.key,
  });

  final BodyProgressPhoto photo;
  final BoxFit fit;
  final double opacity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final directory = ref.watch(bodyProgressDirectoryProvider);
    return switch (directory) {
      AsyncData(:final value) => _Image(
        file: File('${value.path}${Platform.pathSeparator}${photo.imageFile}'),
        fit: fit,
        opacity: opacity,
      ),
      AsyncError() => const _Unavailable(),
      _ => const ColoredBox(color: Colors.black12),
    };
  }
}

class _Image extends StatelessWidget {
  const _Image({required this.file, required this.fit, required this.opacity});

  final File file;
  final BoxFit fit;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    if (!file.existsSync()) return const _Unavailable();
    final image = Image.file(
      file,
      fit: fit,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) => const _Unavailable(),
    );
    if (opacity >= 1) return image;
    return Opacity(opacity: opacity, child: image);
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colors.surfaceContainerHighest,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(context.tokens.spaceSm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.image_not_supported_outlined,
                size: 20,
                color: colors.onSurfaceVariant,
              ),
              SizedBox(height: context.tokens.spaceXs),
              Text(
                AppLocalizations.of(context).bodyProgressMissingImage,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
