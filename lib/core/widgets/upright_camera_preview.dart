import 'package:flutter/material.dart';

class UprightCameraPreview extends StatelessWidget {
  const UprightCameraPreview({
    required this.textureId,
    required this.rotationDegrees,
    required this.handlesCropAndRotation,
    required this.mirrorInFlutter,
    required this.sourceWidth,
    required this.sourceHeight,
  });

  final int textureId;
  final int rotationDegrees;
  final bool handlesCropAndRotation;
  final bool mirrorInFlutter;
  final int sourceWidth;
  final int sourceHeight;

  @override
  Widget build(BuildContext context) {
    final normalizedRotation = ((rotationDegrees % 360) + 360) % 360;
    final manualQuarterTurns = normalizedRotation ~/ 90;
    final hasSourceSize = sourceWidth > 0 && sourceHeight > 0;
    final rawWidth = !handlesCropAndRotation && manualQuarterTurns.isOdd
        ? sourceHeight
        : sourceWidth;
    final rawHeight = !handlesCropAndRotation && manualQuarterTurns.isOdd
        ? sourceWidth
        : sourceHeight;
    Widget preview = hasSourceSize
        ? SizedBox(
            width: rawWidth.toDouble(),
            height: rawHeight.toDouble(),
            child: Texture(textureId: textureId),
          )
        : Texture(textureId: textureId);
    if (!handlesCropAndRotation) {
      // ImageReader-backed Flutter textures do not apply CameraX rotation or
      // front-camera mirror metadata, so correct both in the widget layer.
      preview = RotatedBox(quarterTurns: manualQuarterTurns, child: preview);
      if (mirrorInFlutter) {
        preview = Transform.flip(flipX: true, child: preview);
      }
    } else if (mirrorInFlutter) {
      preview = Transform.flip(flipX: true, child: preview);
    }
    if (!hasSourceSize) return ClipRect(child: preview);
    return ClipRect(
      child: FittedBox(fit: BoxFit.cover, child: preview),
    );
  }
}
