import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motionfit_squat/core/providers.dart';
import 'package:motionfit_squat/features/exercise/application/progress_capture_notice.dart';
import 'package:motionfit_squat/features/exercise/domain/exercise_type.dart';
import 'package:motionfit_squat/features/form_progress/application/form_progress_providers.dart';
import 'package:motionfit_squat/features/form_progress/domain/form_pose_snapshot.dart';

final formProgressAutoCaptureProvider = Provider<FormProgressAutoCapture>((
  ref,
) {
  return FormProgressAutoCapture(ref);
});

/// Records one representative pose per exercise per day, without the user
/// asking.
///
/// The workout controllers call this when the first scored rep of a session
/// completes. Each exercise keeps its own database, so the day key alone
/// enforces one entry per exercise per day. Nothing here can fail a workout.
class FormProgressAutoCapture {
  FormProgressAutoCapture(this._ref);

  final Ref _ref;

  /// True when today's pose for [exercise] is already recorded.
  ///
  /// Checked before building a snapshot so a repeat workout skips the work.
  Future<bool> hasCapturedToday(ExerciseType exercise) async {
    try {
      return await _ref
          .read(formPoseRepositoryProvider(exercise))
          .hasSnapshotOn(FormPoseSnapshot.dayKey(DateTime.now()));
    } on Object {
      // Treat an unreadable index as "not captured". A duplicate is rejected by
      // the unique day key anyway, and skipping wrongly would lose the day.
      return false;
    }
  }

  /// Stores [snapshot] unless today's entry for [exercise] already exists.
  ///
  /// Returns true only when a new pose was written.
  Future<bool> captureIfNeeded({
    required ExerciseType exercise,
    required FormPoseSnapshot snapshot,
  }) async {
    try {
      final repository = _ref.read(formPoseRepositoryProvider(exercise));
      // The insert is the real guard: the unique day index rejects a second
      // write even when two callbacks race.
      final stored = await repository.saveIfAbsent(snapshot);
      if (stored) {
        _ref.invalidate(formProgressSeriesProvider(exercise));
        _ref
            .read(progressCaptureNoticeProvider.notifier)
            .report(
              ProgressCaptureKind.formProgress,
              exerciseType: exercise,
            );
      }
      return stored;
    } on Object catch (error, stackTrace) {
      _ref
          .read(crashReportingServiceProvider)
          .recordNonFatal(
            error,
            stackTrace,
            reason: 'form_progress_auto_capture',
          );
      return false;
    }
  }
}
