import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:motionfit_squat/features/pushup/domain/models/pose_frame.dart';
import 'package:motionfit_squat/features/pushup/domain/models/workout_enums.dart';

class PoseOverlay extends StatelessWidget {
  const PoseOverlay({
    required this.landmarks,
    required this.previewTransform,
    required this.sourceWidth,
    required this.sourceHeight,
    required this.feedbackLevel,
    this.flipHorizontally = false,
    super.key,
  });

  final List<PoseLandmark> landmarks;
  final List<double> previewTransform;
  final int sourceWidth;
  final int sourceHeight;
  final PoseFeedbackLevel feedbackLevel;
  final bool flipHorizontally;

  @override
  Widget build(BuildContext context) {
    // Rendering follows the current landmark payload, not full-body/counting
    // readiness. Partial detections should still show every reliable joint.
    if (landmarks.length < 33) {
      return const SizedBox.shrink();
    }
    final color = switch (feedbackLevel) {
      PoseFeedbackLevel.good => const Color(0xFFA7F36B),
      PoseFeedbackLevel.caution => const Color(0xFFFFD54F),
      PoseFeedbackLevel.poor => const Color(0xFFFF5252),
      PoseFeedbackLevel.unavailable => const Color(0xFFFFD54F),
    };
    return IgnorePointer(
      child: CustomPaint(
        painter: _PosePainter(
          landmarks: landmarks,
          previewTransform: previewTransform,
          sourceWidth: sourceWidth,
          sourceHeight: sourceHeight,
          flipHorizontally: flipHorizontally,
          color: color,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _PosePainter extends CustomPainter {
  const _PosePainter({
    required this.landmarks,
    required this.previewTransform,
    required this.sourceWidth,
    required this.sourceHeight,
    required this.flipHorizontally,
    required this.color,
  });

  final List<PoseLandmark> landmarks;
  final List<double> previewTransform;
  final int sourceWidth;
  final int sourceHeight;
  final bool flipHorizontally;
  final Color color;

  static const _connections = <(int, int)>[
    (0, 1),
    (1, 2),
    (2, 3),
    (3, 7),
    (0, 4),
    (4, 5),
    (5, 6),
    (6, 8),
    (9, 10),
    (11, 12),
    (11, 13),
    (13, 15),
    (15, 17),
    (15, 19),
    (15, 21),
    (17, 19),
    (12, 14),
    (14, 16),
    (16, 18),
    (16, 20),
    (16, 22),
    (18, 20),
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

  static const _minimumPointConfidence = 0.20;
  static const _minimumConnectionConfidence = 0.25;
  static const _frameMargin = 0.04;
  static const _maximumNormalizedSegmentLength = 0.65;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;
    final lineOutline = Paint()
      ..strokeWidth = 7.5
      ..strokeCap = StrokeCap.round;
    final lineGlow = Paint()
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    final pointPaint = Paint();
    final pointOutline = Paint();
    final pointGlow = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    final matrix = previewTransform.length == 9
        ? previewTransform
        : const <double>[1, 0, 0, 0, 1, 0, 0, 0, 1];
    final source = sourceWidth > 0 && sourceHeight > 0
        ? Size(sourceWidth.toDouble(), sourceHeight.toDouble())
        : size;
    final coverScale = math.max(
      size.width / source.width,
      size.height / source.height,
    );
    final renderedWidth = source.width * coverScale;
    final renderedHeight = source.height * coverScale;
    final coverOffsetX = (size.width - renderedWidth) / 2;
    final coverOffsetY = (size.height - renderedHeight) / 2;

    Offset? offset(PoseLandmark point, double minimumConfidence) {
      if (!point.x.isFinite ||
          !point.y.isFinite ||
          !point.confidence.isFinite ||
          point.confidence < minimumConfidence) {
        return null;
      }
      final divisor = matrix[6] * point.x + matrix[7] * point.y + matrix[8];
      final safeDivisor = divisor.abs() < 0.000001 ? 1.0 : divisor;
      final x =
          (matrix[0] * point.x + matrix[1] * point.y + matrix[2]) / safeDivisor;
      final y =
          (matrix[3] * point.x + matrix[4] * point.y + matrix[5]) / safeDivisor;
      if (!x.isFinite ||
          !y.isFinite ||
          x < -_frameMargin ||
          x > 1 + _frameMargin ||
          y < -_frameMargin ||
          y > 1 + _frameMargin) {
        return null;
      }
      return Offset(
        coverOffsetX +
            (flipHorizontally ? 1 - x : x) * source.width * coverScale,
        coverOffsetY + y * source.height * coverScale,
      );
    }

    for (final connection in _connections) {
      final from = landmarks[connection.$1];
      final to = landmarks[connection.$2];
      final fromOffset = offset(from, _minimumConnectionConfidence);
      final toOffset = offset(to, _minimumConnectionConfidence);
      if (fromOffset == null || toOffset == null) continue;
      final segmentLength = math.sqrt(
        math.pow(from.x - to.x, 2) + math.pow(from.y - to.y, 2),
      );
      if (segmentLength > _maximumNormalizedSegmentLength) continue;
      final confidence = from.confidence < to.confidence
          ? from.confidence
          : to.confidence;
      final alpha =
          ((confidence - _minimumConnectionConfidence) /
                  (1 - _minimumConnectionConfidence))
              .clamp(0.25, 1.0)
              .toDouble();
      lineGlow.color = color.withValues(alpha: 0.55 * alpha);
      canvas.drawLine(fromOffset, toOffset, lineGlow);
      lineOutline.color = Colors.black.withValues(alpha: 0.72 * alpha);
      canvas.drawLine(fromOffset, toOffset, lineOutline);
      line.color = color.withValues(alpha: alpha);
      canvas.drawLine(fromOffset, toOffset, line);
    }
    for (var index = 0; index < 33; index++) {
      final point = landmarks[index];
      final position = offset(point, _minimumPointConfidence);
      if (position == null) continue;
      final alpha =
          ((point.confidence - _minimumPointConfidence) /
                  (1 - _minimumPointConfidence))
              .clamp(0.30, 1.0)
              .toDouble();
      pointGlow.color = color.withValues(alpha: 0.55 * alpha);
      canvas.drawCircle(position, 8, pointGlow);
      pointOutline.color = Colors.black.withValues(alpha: 0.78 * alpha);
      canvas.drawCircle(position, 6.5, pointOutline);
      pointPaint.color = color.withValues(alpha: alpha);
      canvas.drawCircle(position, 4.5, pointPaint);
    }
  }

  @override
  bool shouldRepaint(_PosePainter oldDelegate) =>
      oldDelegate.landmarks != landmarks ||
      oldDelegate.previewTransform != previewTransform ||
      oldDelegate.sourceWidth != sourceWidth ||
      oldDelegate.sourceHeight != sourceHeight ||
      oldDelegate.flipHorizontally != flipHorizontally ||
      oldDelegate.color != color;
}
