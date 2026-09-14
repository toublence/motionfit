import 'dart:async';
import 'package:motionfit_squat/core/providers.dart';
import 'package:motionfit_squat/features/settings/application/preferences_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motionfit_squat/features/exercise/domain/exercise_type.dart';

final selectedExerciseProvider =
    NotifierProvider<ExerciseSelectionController, ExerciseType>(
      ExerciseSelectionController.new,
    );

class ExerciseSelectionController extends Notifier<ExerciseType> {
  @override
  ExerciseType build() =>
      ExerciseType.values
          .where(
            (value) =>
                value.name == ref.read(initialPreferencesProvider).lastExercise,
          )
          .firstOrNull ??
      ExerciseType.squat;

  void select(ExerciseType exercise) {
    state = exercise;
    unawaited(
      ref
          .read(preferencesControllerProvider.notifier)
          .setLastExercise(exercise.name)
          .catchError((Object _) {}),
    );
  }
}
