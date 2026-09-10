import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motionfit_squat/core/providers.dart';
import 'package:motionfit_squat/features/body_progress/application/body_progress_providers.dart';
import 'package:motionfit_squat/features/body_progress/domain/body_progress_photo.dart';
import 'package:motionfit_squat/features/exercise/application/progress_capture_notice.dart';
import 'package:uuid/uuid.dart';

/// A frame written by whichever exercise's pose engine captured it.
typedef CapturedWorkoutFrame = ({
  String directory,
  String fileName,
  int width,
  int height,
});

final bodyProgressAutoCaptureProvider = Provider<BodyProgressAutoCapture>((
  ref,
) {
  return BodyProgressAutoCapture(ref);
});

/// Records one Body Progress photo per day, without the user asking.
///
/// The workout controllers call this once calibration reports a settled pose.
/// That moment is the same every day: the user standing in frame, fully
/// detected, before the first rep. Nothing here can fail a workout; every error
/// path returns false and is reported separately.
class BodyProgressAutoCapture {
  BodyProgressAutoCapture(this._ref);

  static const _uuid = Uuid();

  /// The automatic capture always uses the front framing. Side and back stay
  /// manual, because the app cannot tell which way the user is facing.
  static const captureView = BodyView.front;

  final Ref _ref;

  /// Captures today's photo unless one already exists.
  ///
  /// Returns true only when a new photo was written, so the caller can show a
  /// one-off confirmation without repeating it on later workouts that day.
  Future<bool> captureIfNeeded({
    required Future<CapturedWorkoutFrame> Function() captureFrame,
    required String sessionId,
  }) async {
    try {
      final repository = _ref.read(bodyProgressRepositoryProvider);
      final now = DateTime.now();
      final dayKey = BodyProgressPhoto.dayKey(now);
      // Checked before the capture so a repeat workout never even asks the
      // camera for a frame.
      if (await repository.hasPhotoOn(dayKey, captureView)) return false;

      final frame = await captureFrame();
      final photo = BodyProgressPhoto(
        id: _uuid.v4(),
        capturedAt: now,
        capturedOn: dayKey,
        bodyView: captureView,
        imageFile: frame.fileName,
        imageWidth: frame.width,
        imageHeight: frame.height,
        source: BodyProgressSource.auto,
        sessionId: sessionId,
        createdAt: now,
      );
      // The insert is the real guard. Two workouts starting at once would both
      // pass the check above, and only one of them wins the day key.
      final stored = await repository.savePhotoIfAbsent(photo);
      if (stored) {
        _ref.invalidate(bodyProgressPhotosProvider);
        _ref
            .read(progressCaptureNoticeProvider.notifier)
            .report(ProgressCaptureKind.bodyProgress);
      }
      return stored;
    } on Object catch (error, stackTrace) {
      _ref
          .read(crashReportingServiceProvider)
          .recordNonFatal(
            error,
            stackTrace,
            reason: 'body_progress_auto_capture',
          );
      return false;
    }
  }
}
