import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:motionfit_squat/app/localization/generated/app_localizations.dart';

class PlanStepper extends StatelessWidget {
  const PlanStepper({
    required this.label,
    required this.value,
    required this.minimum,
    required this.maximum,
    required this.onChanged,
    this.valueLabel,
    this.hapticsEnabled = true,
    super.key,
  });

  final String label;
  final int value;
  final int minimum;
  final int maximum;
  final ValueChanged<int> onChanged;
  final String Function(int value)? valueLabel;
  final bool hapticsEnabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Future<void> change(int next) async {
      final normalized = next.clamp(minimum, maximum).toInt();
      if (normalized == value) return;
      if (hapticsEnabled) await HapticFeedback.selectionClick();
      onChanged(normalized);
    }

    return Semantics(
      label: label,
      value: (valueLabel ?? (number) => '$number')(value),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.titleMedium),
          ),
          IconButton.outlined(
            tooltip: l10n.semanticsDecrease,
            onPressed: value <= minimum ? null : () => change(value - 1),
            icon: const Icon(Icons.remove),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () async {
              final result = await showDialog<int>(
                context: context,
                builder: (context) => _NumberInputDialog(
                  title: label,
                  initialValue: value,
                  minimum: minimum,
                  maximum: maximum,
                ),
              );
              if (result != null) await change(result);
            },
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 72, minHeight: 48),
              child: Center(
                child: Text(
                  (valueLabel ?? (number) => '$number')(value),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            tooltip: l10n.semanticsIncrease,
            onPressed: value >= maximum ? null : () => change(value + 1),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class _NumberInputDialog extends StatefulWidget {
  const _NumberInputDialog({
    required this.title,
    required this.initialValue,
    required this.minimum,
    required this.maximum,
  });

  final String title;
  final int initialValue;
  final int minimum;
  final int maximum;

  @override
  State<_NumberInputDialog> createState() => _NumberInputDialogState();
}

class _NumberInputDialogState extends State<_NumberInputDialog> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.initialValue}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    final parsed = int.tryParse(_controller.text.trim());
    if (parsed == null) {
      setState(() => _error = l10n.validationNumberRequired);
      return;
    }
    final normalized = parsed.clamp(widget.minimum, widget.maximum).toInt();
    Navigator.of(context).pop(normalized);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          hintText: l10n.homeDirectInputHint,
          errorText: _error,
          helperText: l10n.validationRange(widget.minimum, widget.maximum),
        ),
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.commonSave)),
      ],
    );
  }
}
