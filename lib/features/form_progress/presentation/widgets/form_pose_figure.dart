import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:motionfit_squat/features/form_progress/domain/form_pose_snapshot.dart';

/// Draws a stored representative pose as a skeleton figure.
///
/// The figure is normalized to its own bounding box, so poses recorded at
/// different distances from the camera line up with each other. That is what
/// keeps a form timelapse readable across weeks of workouts.
class FormPoseFigure extends StatelessWidget {
  const FormPoseFigure({
    required this.snapshot,
    required this.color,
    this.background,
    super.key,
  });

  final FormPoseSnapshot snapshot;
  final Color color;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ColoredBox(
      color: background ?? colors.surfaceContainerHighest,
      child: snapshot.isRenderable
          ? CustomPaint(
              painter: _FigurePainter(
                landmarks: snapshot.landmarks,
                color: color,
                mirrored: snapshot.mirrored,
              ),
              size: Size.infinite,
            )
          : const SizedBox.expand(),
    );
  }
}

class _FigurePainter extends CustomPainter {
  const _FigurePainter({
    required this.landmarks,
    required this.color,
    required this.mirrored,
  });

  final List<FormPosePoint> landmarks;
  final Color color;
  final bool mirrored;

  /// Torso and limbs only. Face points add noise without telling the user
  /// anything about squat, push-up, or plank form.
  static const _connections = <(int, int)>[
    (11, 12),
    (11, 13),
    (13, 15),
    (12, 14),
    (14, 16),
    (11, 23),
    (12, 24),
    (23, 24),
    (23, 25),
    (25, 27),
    (27, 29),
    (29, 31),
    (27, 31),
    (24, 26),
    (26, 28),
    (28, 30),
    (30, 32),
    (28, 32),
  ];

  static const _minimumConfidence = 0.25;
  static const _padding = 0.1;
  static const _firstBodyLandmark = 11;

  @override
  void paint(Canvas canvas, Size size) {
    final usable = <int, FormPosePoint>{};
    for (
      var index = _firstBodyLandmark;
      index < landmarks.length && index < 33;
      index++
    ) {
      final point = landmarks[index];
      if (point.confidence >= _minimumConfidence &&
          point.x.isFinite &&
          point.y.isFinite) {
        usable[index] = point;
      }
    }
    if (usable.length < 6) return;

    final xs = usable.values.map((point) => point.x);
    final ys = usable.values.map((point) => point.y);
    final minX = xs.reduce(math.min);
    final maxX = xs.reduce(math.max);
    final minY = ys.reduce(math.min);
    final maxY = ys.reduce(math.max);
    final spanX = math.max(maxX - minX, 0.0001);
    final spanY = math.max(maxY - minY, 0.0001);
    // A single scale for both axes keeps the body's proportions intact.
    final scale = math.min(
      size.width * (1 - 2 * _padding) / spanX,
      size.height * (1 - 2 * _padding) / spanY,
    );
    final offsetX = (size.width - spanX * scale) / 2;
    final offsetY = (size.height - spanY * scale) / 2;

    Offset project(FormPosePoint point) {
      final normalized = (point.x - minX) / spanX;
      final x = mirrored ? 1 - normalized : normalized;
      return Offset(
        offsetX + x * spanX * scale,
        offsetY + (point.y - minY) * scale,
      );
    }

    final line = Paint()
      ..color = color
      ..strokeWidth = math.max(3, size.shortestSide * 0.018)
      ..strokeCap = StrokeCap.round;
    final joint = Paint()..color = color;
    final jointRadius = math.max(2.5, size.shortestSide * 0.014);

    for (final connection in _connections) {
      final from = usable[connection.$1];
      final to = usable[connection.$2];
      if (from == null || to == null) continue;
      canvas.drawLine(project(from), project(to), line);
    }
    for (final point in usable.values) {
      canvas.drawCircle(project(point), jointRadius, joint);
    }
  }

  @override
  bool shouldRepaint(_FigurePainter oldDelegate) =>
      oldDelegate.landmarks != landmarks ||
      oldDelegate.color != color ||
      oldDelegate.mirrored != mirrored;
}
