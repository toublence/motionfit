import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motionfit_squat/app/localization/generated/app_localizations.dart';
import 'package:motionfit_squat/app/theme/exercise_colors.dart';
import 'package:motionfit_squat/features/exercise/application/exercise_selection.dart';
import 'package:motionfit_squat/features/exercise/domain/exercise_type.dart';

class ExerciseSelector extends ConsumerWidget {
  const ExerciseSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedExerciseProvider);
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final exerciseColor = ExerciseColors.of(selected);
    return SegmentedButton<ExerciseType>(
      segments: [
        ButtonSegment(value: ExerciseType.squat, label: Text(l10n.navSquat)),
        ButtonSegment(
          value: ExerciseType.pushup,
          label: Text(_pushup(context)),
        ),
        ButtonSegment(value: ExerciseType.plank, label: Text(_plank(context))),
      ],
      selected: {selected},
      showSelectedIcon: false,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? ExerciseColors.tintOf(selected, Theme.of(context).brightness)
              : Colors.transparent,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? exerciseColor
              : colors.onSurfaceVariant,
        ),
        side: WidgetStatePropertyAll(BorderSide(color: colors.outlineVariant)),
      ),
      onSelectionChanged: (value) {
        ref.read(selectedExerciseProvider.notifier).select(value.single);
      },
    );
  }
}

String _pushup(BuildContext context) => switch (Localizations.localeOf(
  context,
).languageCode) {
  'ar' => 'تمارين الضغط',
  'de' => 'Liegestütze',
  'es' => 'Flexiones',
  'fr' => 'Pompes',
  'ja' => 'プッシュアップ',
  'ko' => '푸시업',
  'zh' => Localizations.localeOf(context).scriptCode == 'Hant' ? '伏地挺身' : '俯卧撑',
  _ => 'Pushup',
};

String _plank(BuildContext context) =>
    switch (Localizations.localeOf(context).languageCode) {
      'ar' => 'البلانك',
      'de' => 'Plank',
      'es' => 'Plancha',
      'fr' => 'Gainage',
      'ja' => 'プランク',
      'ko' => '플랭크',
      'zh' =>
        Localizations.localeOf(context).scriptCode == 'Hant' ? '平板支撐' : '平板支撑',
      _ => 'Plank',
    };
