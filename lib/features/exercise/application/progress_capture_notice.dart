import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motionfit_squat/features/exercise/domain/exercise_type.dart';

enum ProgressCaptureKind { bodyProgress, formProgress }

class ProgressCaptureNotice {
  const ProgressCaptureNotice({
    required this.kind,
    required this.exerciseType,
    required this.at,
  });

  final ProgressCaptureKind kind;

  /// Null for Body Progress, which is not tied to one exercise.
  final ExerciseType? exerciseType;
  final DateTime at;
}

final progressCaptureNoticeProvider =
    NotifierProvider<ProgressCaptureNoticeController, ProgressCaptureNotice?>(
      ProgressCaptureNoticeController.new,
    );

/// Announces that today's Progress entry was recorded automatically.
///
/// The workout screen turns this into a brief message. It lives outside the
/// workout session state so the automatic capture does not have to reach into
/// three separate controllers' state classes to report itself.
class ProgressCaptureNoticeController extends Notifier<ProgressCaptureNotice?> {
  @override
  ProgressCaptureNotice? build() => null;

  void report(ProgressCaptureKind kind, {ExerciseType? exerciseType}) {
    state = ProgressCaptureNotice(
      kind: kind,
      exerciseType: exerciseType,
      at: DateTime.now(),
    );
  }

  /// Called once the message has been shown, so it is not repeated.
  void clear() => state = null;
}
