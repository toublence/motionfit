import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motionfit_squat/core/database/app_database.dart';
import 'package:motionfit_squat/core/providers.dart' as shared;
import 'package:motionfit_squat/features/plank/challenges/data/challenge_repository.dart';
import 'package:motionfit_squat/features/plank/workout/domain/services/workout_repository.dart';

export 'package:motionfit_squat/core/providers.dart'
    hide
        appDatabaseProvider,
        workoutRepositoryProvider,
        challengeRepositoryProvider;

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw StateError('Plank AppDatabase was not initialized.');
});

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  throw StateError('Plank WorkoutRepository was not initialized.');
});

final challengeRepositoryProvider = Provider<ChallengeRepository>((ref) {
  return ChallengeRepository(
    ref.watch(appDatabaseProvider),
    onError: (error, stackTrace, reason) {
      ref
          .read(shared.crashReportingServiceProvider)
          .recordNonFatal(error, stackTrace, reason: reason);
    },
  );
});
