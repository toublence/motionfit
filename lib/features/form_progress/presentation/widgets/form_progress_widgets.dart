import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:motionfit_squat/app/localization/generated/app_localizations.dart';
import 'package:motionfit_squat/app/theme/exercise_colors.dart';
import 'package:motionfit_squat/app/theme/motionfit_tokens.dart';
import 'package:motionfit_squat/core/widgets/coach_ui.dart';
import 'package:motionfit_squat/features/exercise/domain/exercise_type.dart';
import 'package:motionfit_squat/features/form_progress/domain/form_pose_snapshot.dart';
import 'package:motionfit_squat/features/form_progress/domain/form_progress_point.dart';
import 'package:motionfit_squat/features/form_progress/domain/form_progress_series.dart';
import 'package:motionfit_squat/features/form_progress/presentation/widgets/form_pose_figure.dart';

String formExerciseLabel(AppLocalizations l10n, ExerciseType exercise) =>
    switch (exercise) {
      ExerciseType.squat => l10n.navSquat,
      ExerciseType.pushup => l10n.exercisePushup,
      ExerciseType.plank => l10n.exercisePlank,
    };

String formatFormScore(double? score) =>
    score == null ? '--' : score.round().toString();

String formatAccuracy(double? accuracy) =>
    accuracy == null ? '--' : '${(accuracy * 100).round()}%';

/// Summarises the change between the first and the latest scored workout.
class FormScoreDeltaPill extends StatelessWidget {
  const FormScoreDeltaPill({required this.delta, super.key});

  final double? delta;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final value = delta;
    if (value == null || value.round() == 0) {
      return CoachStatusPill(
        label: l10n.formProgressUnchanged,
        tone: CoachStatusTone.unavailable,
      );
    }
    final points = value.abs().round();
    final improved = value > 0;
    return CoachStatusPill(
      label: improved
          ? l10n.formProgressImprovedBy(points)
          : l10n.formProgressDeclinedBy(points),
      tone: improved ? CoachStatusTone.positive : CoachStatusTone.attention,
      icon: improved
          ? Icons.trending_up_rounded
          : Icons.trending_down_rounded,
    );
  }
}

/// Score-over-time line for one exercise.
///
/// Deliberately unlabelled on the axes: the numbers that matter are already
/// shown as the first, current, and change metrics above it.
class FormScoreTrend extends StatelessWidget {
  const FormScoreTrend({required this.series, this.height = 120, super.key});

  final FormProgressSeries series;
  final double height;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scored = series.scoredPoints;
    if (scored.length < 2) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            l10n.formProgressNeedsTwoSessions,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
    return Semantics(
      label:
          '${l10n.formProgressTrend} '
          '${formatFormScore(series.firstScore)} '
          '${formatFormScore(series.latestScore)}',
      child: ExcludeSemantics(
        child: SizedBox(
          height: height,
          child: CustomPaint(
            painter: _TrendPainter(
              scores: scored
                  .map((point) => point.formScore!)
                  .toList(growable: false),
              color: ExerciseColors.of(series.exerciseType),
              gridColor: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  const _TrendPainter({
    required this.scores,
    required this.color,
    required this.gridColor,
  });

  final List<double> scores;
  final Color color;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (scores.length < 2) return;
    // A fixed 0-100 range keeps the slope honest. An auto-fitted axis would
    // make a two-point gain look like a transformation.
    const minScore = 0.0;
    const maxScore = 100.0;
    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (final fraction in const [0.0, 0.5, 1.0]) {
      final y = size.height * fraction;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final step = size.width / (scores.length - 1);
    final points = <Offset>[
      for (var index = 0; index < scores.length; index++)
        Offset(
          index * step,
          size.height *
              (1 -
                  ((scores[index] - minScore) / (maxScore - minScore))
                      .clamp(0.0, 1.0)),
        ),
    ];

    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.28), color.withValues(alpha: 0)],
      ).createShader(Offset.zero & size);
    final area = Path()..moveTo(points.first.dx, size.height);
    for (final point in points) {
      area.lineTo(point.dx, point.dy);
    }
    area
      ..lineTo(points.last.dx, size.height)
      ..close();
    canvas.drawPath(area, fill);

    final line = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(path, line);

    final dot = Paint()..color = color;
    canvas.drawCircle(points.last, math.max(3.5, size.height * 0.035), dot);
  }

  @override
  bool shouldRepaint(_TrendPainter oldDelegate) =>
      oldDelegate.scores != scores || oldDelegate.color != color;
}

/// A representative pose with the day, score, and main issue of that workout.
class FormPoseCard extends StatelessWidget {
  const FormPoseCard({
    required this.snapshot,
    required this.exerciseType,
    required this.dayNumber,
    required this.caption,
    required this.issueLabel,
    super.key,
  });

  final FormPoseSnapshot snapshot;
  final ExerciseType exerciseType;
  final int dayNumber;
  final String caption;
  final String? issueLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(context.tokens.radiusMd),
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: FormPoseFigure(
              snapshot: snapshot,
              color: ExerciseColors.of(exerciseType),
            ),
          ),
        ),
        SizedBox(height: context.tokens.spaceSm),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.bodyProgressDayNumber(dayNumber),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              formatFormScore(snapshot.formScore),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: ExerciseColors.of(exerciseType),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        Text(
          caption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
        ),
        if (issueLabel != null)
          Text(
            issueLabel!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: context.tokens.warning),
          ),
      ],
    );
  }
}

/// One row of the workout history list.
class FormProgressSessionRow extends StatelessWidget {
  const FormProgressSessionRow({
    required this.point,
    required this.dayNumber,
    required this.dateLabel,
    required this.onTap,
    super.key,
  });

  final FormProgressPoint point;
  final int dayNumber;
  final String dateLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: ExerciseColors.tintOf(
          point.exerciseType,
          Theme.of(context).brightness,
        ),
        child: Text(
          '$dayNumber',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: ExerciseColors.of(point.exerciseType),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      title: Text(dateLabel),
      subtitle: Text(
        '${l10n.formProgressScoreLabel} ${formatFormScore(point.formScore)}'
        ' · ${l10n.formProgressAccuracy} ${formatAccuracy(point.accuracy)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}
