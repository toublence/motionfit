import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motionfit_squat/features/exercise/application/exercise_selection.dart';
import 'package:motionfit_squat/features/exercise/domain/exercise_type.dart';
import 'package:motionfit_squat/features/exercise/presentation/exercise_selector.dart';
import 'package:motionfit_squat/features/plank/workout/presentation/screens/plank_home_screen.dart';
import 'package:motionfit_squat/features/pushup/presentation/screens/pushup_home_screen.dart';
import 'package:motionfit_squat/features/squat/presentation/screens/squat_home_screen.dart';

class ExerciseHomeScreen extends ConsumerWidget {
  const ExerciseHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedExerciseProvider);
    return Column(
      children: [
        const SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(20, 10, 20, 0),
            child: SizedBox(width: double.infinity, child: ExerciseSelector()),
          ),
        ),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: switch (selected) {
              ExerciseType.squat => const SquatHomeScreen(),
              ExerciseType.pushup => const PushupHomeScreen(),
              ExerciseType.plank => const PlankHomeScreen(),
            },
          ),
        ),
      ],
    );
  }
}
