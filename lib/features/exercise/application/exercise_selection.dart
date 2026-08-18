import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motionfit_squat/features/exercise/domain/exercise_type.dart';

final selectedExerciseProvider =
    NotifierProvider<ExerciseSelectionController, ExerciseType>(
      ExerciseSelectionController.new,
    );

class ExerciseSelectionController extends Notifier<ExerciseType> {
  @override
  ExerciseType build() => ExerciseType.squat;

  void select(ExerciseType exercise) => state = exercise;
}
