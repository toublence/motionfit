import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motionfit_squat/features/challenges/presentation/challenge_screen.dart'
    as squat;
import 'package:motionfit_squat/features/exercise/application/exercise_selection.dart';
import 'package:motionfit_squat/features/exercise/domain/exercise_type.dart';
import 'package:motionfit_squat/features/exercise/presentation/exercise_selector.dart';
import 'package:motionfit_squat/features/plank/challenges/presentation/challenge_screen.dart'
    as plank;
import 'package:motionfit_squat/features/pushup/challenges/presentation/challenge_screen.dart'
    as pushup;

class ExerciseChallengeScreen extends ConsumerWidget {
  const ExerciseChallengeScreen({super.key});

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
              ExerciseType.squat => const squat.ChallengeScreen(),
              ExerciseType.pushup => const pushup.ChallengeScreen(),
              ExerciseType.plank => const plank.ChallengeScreen(),
            },
          ),
        ),
      ],
    );
  }
}
