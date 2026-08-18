import 'package:flutter/material.dart';
import 'package:motionfit_squat/app/theme/motionfit_tokens.dart';

class RecordMetricTile extends StatelessWidget {
  const RecordMetricTile({
    required this.icon,
    required this.label,
    required this.value,
    this.emphasized = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: label,
      value: value,
      child: Container(
        constraints: const BoxConstraints(minWidth: 132, minHeight: 76),
        padding: EdgeInsets.all(context.tokens.spaceMd),
        decoration: BoxDecoration(
          color: emphasized
              ? colors.primaryContainer
              : colors.surfaceContainerHighest.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(context.tokens.radiusMd),
        ),
        child: ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 19,
                color: emphasized
                    ? colors.onPrimaryContainer
                    : colors.onSurfaceVariant,
              ),
              SizedBox(height: context.tokens.spaceSm),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: emphasized ? colors.onPrimaryContainer : null,
                ),
              ),
              SizedBox(height: context.tokens.spaceXs),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: emphasized
                      ? colors.onPrimaryContainer
                      : colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecordSectionCard extends StatelessWidget {
  const RecordSectionCard({
    required this.title,
    required this.child,
    this.icon,
    super.key,
  });

  final String title;
  final Widget child;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: EdgeInsets.all(context.tokens.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 21),
                SizedBox(width: context.tokens.spaceSm),
              ],
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          SizedBox(height: context.tokens.spaceMd),
          child,
        ],
      ),
    ),
  );
}

class RecordEmptyState extends StatelessWidget {
  const RecordEmptyState({
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
    super.key,
  });

  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: EdgeInsets.all(context.tokens.spaceLg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center_rounded,
              size: 52,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: context.tokens.spaceMd),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.tokens.spaceSm),
            Text(body, textAlign: TextAlign.center),
            SizedBox(height: context.tokens.spaceLg),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    ),
  );
}

class RecordLoadingState extends StatelessWidget {
  const RecordLoadingState({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) => Center(
    child: Semantics(
      label: label,
      liveRegion: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: context.tokens.spaceMd),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

class RecordErrorState extends StatelessWidget {
  const RecordErrorState({
    required this.title,
    required this.body,
    required this.retryLabel,
    required this.onRetry,
    super.key,
  });

  final String title;
  final String body;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: EdgeInsets.all(context.tokens.spaceLg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            SizedBox(height: context.tokens.spaceMd),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.tokens.spaceSm),
            Text(body, textAlign: TextAlign.center),
            SizedBox(height: context.tokens.spaceLg),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(retryLabel),
            ),
          ],
        ),
      ),
    ),
  );
}
