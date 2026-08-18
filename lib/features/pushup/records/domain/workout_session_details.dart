import 'package:motionfit_squat/features/exercise/domain/exercise_type.dart';
import 'package:motionfit_squat/features/pushup/domain/models/rep_record.dart';
import 'package:motionfit_squat/features/pushup/domain/models/rep_analysis.dart';
import 'package:motionfit_squat/features/pushup/domain/models/workout_session.dart';
import 'package:motionfit_squat/features/pushup/domain/models/workout_set.dart';

class WorkoutSessionDetails {
  const WorkoutSessionDetails({
    required this.session,
    required this.sets,
    required this.reps,
  });

  final WorkoutSession session;
  final List<WorkoutSet> sets;
  final List<RepRecord> reps;
  ExerciseType get exerciseType => ExerciseType.pushup;

  List<RepAnalysis> get repAnalyses => RepAnalysis.fromRecords(
    records: reps,
    setNumbers: {for (final set in sets) set.id: set.setIndex},
    workoutStartedAt: session.startedAt,
  );

  double? get averageFormScore {
    final scores = reps
        .map((rep) => rep.overallFormScore)
        .whereType<double>()
        .toList();
    if (scores.isEmpty) return null;
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  List<String> get issueNames => reps
      .expand((rep) => rep.detectedIssues)
      .map((issue) => issue.name)
      .toList(growable: false);
}
