import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motionfit_squat/core/providers.dart';
import 'package:motionfit_squat/features/exercise/domain/exercise_type.dart';
import 'package:motionfit_squat/features/form_progress/data/form_pose_repository.dart';
import 'package:motionfit_squat/features/form_progress/domain/form_progress_point.dart';
import 'package:motionfit_squat/features/form_progress/domain/form_progress_series.dart';
import 'package:motionfit_squat/features/plank/providers.dart' as plank_providers;
import 'package:motionfit_squat/features/plank/records/application/records_providers.dart'
    as plank_records;
import 'package:motionfit_squat/features/plank/records/domain/workout_session_details.dart'
    as plank;
import 'package:motionfit_squat/features/pushup/providers.dart'
    as pushup_providers;
import 'package:motionfit_squat/features/pushup/records/application/records_providers.dart'
    as pushup_records;
import 'package:motionfit_squat/features/pushup/records/domain/workout_session_details.dart'
    as pushup;
import 'package:motionfit_squat/features/records/application/records_providers.dart'
    as squat_records;
import 'package:motionfit_squat/features/records/domain/workout_session_details.dart'
    as squat;
import 'package:motionfit_squat/features/squat/domain/models/workout_enums.dart';

/// Each exercise keeps its own database, so the snapshot repository is
/// resolved per exercise rather than shared.
final formPoseRepositoryProvider =
    Provider.family<FormPoseRepository, ExerciseType>((ref, exercise) {
      final database = switch (exercise) {
        ExerciseType.squat => ref.watch(appDatabaseProvider),
        ExerciseType.pushup => ref.watch(pushup_providers.appDatabaseProvider),
        ExerciseType.plank => ref.watch(plank_providers.appDatabaseProvider),
      };
      return FormPoseRepository(
        database,
        onError: (error, stackTrace, reason) {
          ref
              .read(crashReportingServiceProvider)
              .recordNonFatal(error, stackTrace, reason: reason);
        },
      );
    });

/// Exercise currently shown on the Form Progress detail screen.
final selectedFormExerciseProvider =
    NotifierProvider<SelectedFormExercise, ExerciseType>(
      SelectedFormExercise.new,
    );

class SelectedFormExercise extends Notifier<ExerciseType> {
  @override
  ExerciseType build() => ExerciseType.squat;

  void select(ExerciseType exercise) => state = exercise;
}

/// Form history for one exercise, built entirely from analysis that already
/// ran when each workout finished.
final formProgressSeriesProvider =
    FutureProvider.family<FormProgressSeries, ExerciseType>((
      ref,
      exercise,
    ) async {
      final points = switch (exercise) {
        ExerciseType.squat => (await ref.watch(
          squat_records.allSessionsProvider.future,
        )).map(_fromSquat),
        ExerciseType.pushup => (await ref.watch(
          pushup_records.allSessionsProvider.future,
        )).map(_fromPushup),
        ExerciseType.plank => (await ref.watch(
          plank_records.allSessionsProvider.future,
        )).map(_fromPlank),
      };
      final poses = await ref
          .watch(formPoseRepositoryProvider(exercise))
          .loadAll();
      return FormProgressSeries(
        exerciseType: exercise,
        points: points.whereType<FormProgressPoint>().toList(growable: false),
        poses: poses,
      );
    });

/// Session count per exercise, used by the exercise picker.
final formProgressSessionCountsProvider =
    FutureProvider<Map<ExerciseType, int>>((ref) async {
      final counts = <ExerciseType, int>{};
      for (final exercise in ExerciseType.values) {
        final series = await ref.watch(
          formProgressSeriesProvider(exercise).future,
        );
        counts[exercise] = series.sessionCount;
      }
      return counts;
    });

FormProgressPoint? _fromSquat(squat.WorkoutSessionDetails details) =>
    _point(
      exercise: ExerciseType.squat,
      sessionId: details.session.id,
      startedAt: details.session.startedAt,
      completed: details.session.completed,
      interrupted: details.session.interrupted,
      totalReps: details.session.totalReps,
      durationSeconds: details.session.activeDurationSeconds,
      formScore: details.averageFormScore,
      confidences: details.reps.map((rep) => rep.confidence),
      issues: details.reps.expand((rep) => rep.detectedIssues),
    );

FormProgressPoint? _fromPushup(pushup.WorkoutSessionDetails details) =>
    _point(
      exercise: ExerciseType.pushup,
      sessionId: details.session.id,
      startedAt: details.session.startedAt,
      completed: details.session.completed,
      interrupted: details.session.interrupted,
      totalReps: details.session.totalReps,
      durationSeconds: details.session.activeDurationSeconds,
      formScore: details.averageFormScore,
      confidences: details.reps.map((rep) => rep.confidence),
      issues: details.reps.expand((rep) => rep.detectedIssues),
    );

FormProgressPoint? _fromPlank(plank.WorkoutSessionDetails details) => _point(
  exercise: ExerciseType.plank,
  sessionId: details.session.id,
  startedAt: details.session.startedAt,
  completed: details.session.completed,
  interrupted: details.session.interrupted,
  totalReps: details.session.totalReps,
  durationSeconds: details.session.activeDurationSeconds,
  formScore: details.averageFormScore,
  confidences: details.reps.map((rep) => rep.confidence),
  issues: details.reps.expand((rep) => rep.detectedIssues),
);

/// Interrupted or empty sessions are skipped so the trend reflects real work.
FormProgressPoint? _point({
  required ExerciseType exercise,
  required String sessionId,
  required DateTime startedAt,
  required bool completed,
  required bool interrupted,
  required int totalReps,
  required int durationSeconds,
  required double? formScore,
  required Iterable<double> confidences,
  required Iterable<FormIssue> issues,
}) {
  if (!completed || interrupted || totalReps <= 0) return null;
  final confidenceValues = confidences.toList(growable: false);
  final accuracy = confidenceValues.isEmpty
      ? null
      : confidenceValues.reduce((a, b) => a + b) / confidenceValues.length;
  return FormProgressPoint(
    sessionId: sessionId,
    exerciseType: exercise,
    workoutDate: startedAt.toLocal(),
    formScore: formScore,
    accuracy: accuracy,
    reps: totalReps,
    durationSeconds: durationSeconds,
    issues: issues.toList(growable: false),
  );
}
