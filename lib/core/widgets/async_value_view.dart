import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    required this.value,
    required this.data,
    required this.loadingLabel,
    required this.errorTitle,
    required this.errorBody,
    this.onRetry,
    this.retryLabel,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(T value) data;
  final String loadingLabel;
  final String errorTitle;
  final String errorBody;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) => switch (value) {
    AsyncData(:final value) => data(value),
    AsyncError() => Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40),
            const SizedBox(height: 12),
            Text(errorTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(errorBody, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onRetry,
                child: Text(retryLabel ?? errorTitle),
              ),
            ],
          ],
        ),
      ),
    ),
    _ => Center(
      child: Semantics(
        label: loadingLabel,
        child: const CircularProgressIndicator(),
      ),
    ),
  };
}
