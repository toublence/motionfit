import 'package:flutter/material.dart';
import 'package:motionfit_squat/app/theme/motionfit_tokens.dart';

enum CoachStatusTone { positive, attention, unavailable, brand }

class MotionEyebrow extends StatelessWidget {
  const MotionEyebrow(this.label, {this.color, super.key});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) => Text(
    label.toUpperCase(),
    style: Theme.of(context).textTheme.labelSmall?.copyWith(
      color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.25,
    ),
  );
}

class MotionRule extends StatelessWidget {
  const MotionRule({super.key});

  @override
  Widget build(BuildContext context) => Container(
    height: 1,
    color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: .55),
  );
}

class CoachSectionHeader extends StatelessWidget {
  const CoachSectionHeader({
    required this.title,
    this.subtitle,
    this.action,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            if (subtitle != null) ...[
              const SizedBox(height: 3),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
      ?action,
    ],
  );
}

class CoachMetric {
  const CoachMetric({required this.value, required this.label, this.icon});

  final String value;
  final String label;
  final IconData? icon;
}

class CoachMetricStrip extends StatelessWidget {
  const CoachMetricStrip({
    required this.metrics,
    this.emphasizeFirst = false,
    super.key,
  });

  final List<CoachMetric> metrics;
  final bool emphasizeFirst;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (var index = 0; index < metrics.length; index++) ...[
        if (index > 0) const SizedBox(width: 12),
        Expanded(
          child: _CoachMetricItem(
            metric: metrics[index],
            emphasized: emphasizeFirst && index == 0,
          ),
        ),
      ],
    ],
  );
}

class _CoachMetricItem extends StatelessWidget {
  const _CoachMetricItem({required this.metric, required this.emphasized});

  final CoachMetric metric;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final color = emphasized
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurface;
    return Semantics(
      label: '${metric.label}: ${metric.value}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (metric.icon != null) ...[
                Icon(metric.icon, size: 18, color: color),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    metric.value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            metric.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class CoachInsightPanel extends StatelessWidget {
  const CoachInsightPanel({
    required this.icon,
    required this.title,
    required this.body,
    this.tone = CoachStatusTone.brand,
    this.trailing,
    this.bodyMaxLines,
    super.key,
  });

  final IconData icon;
  final String title;
  final String body;
  final CoachStatusTone tone;
  final Widget? trailing;
  final int? bodyMaxLines;

  @override
  Widget build(BuildContext context) {
    final color = coachToneColor(context, tone);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: BorderDirectional(start: BorderSide(color: color, width: 3)),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(14, 4, 0, 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall?.copyWith(color: color),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    maxLines: bodyMaxLines,
                    overflow: bodyMaxLines == null
                        ? null
                        : TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        ),
      ),
    );
  }
}

class CoachStatusPill extends StatelessWidget {
  const CoachStatusPill({
    required this.label,
    required this.tone,
    this.icon,
    super.key,
  });

  final String label;
  final CoachStatusTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final color = coachToneColor(context, tone);
    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color coachToneColor(BuildContext context, CoachStatusTone tone) =>
    switch (tone) {
      CoachStatusTone.positive => context.tokens.success,
      CoachStatusTone.attention => context.tokens.warning,
      CoachStatusTone.unavailable => context.tokens.unavailable,
      CoachStatusTone.brand => Theme.of(context).colorScheme.primary,
    };
