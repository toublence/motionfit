import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motionfit_squat/core/providers.dart';
import 'package:motionfit_squat/features/body_progress/data/body_progress_camera.dart';
import 'package:motionfit_squat/features/body_progress/data/body_progress_repository.dart';
import 'package:motionfit_squat/features/body_progress/domain/body_progress_photo.dart';
import 'package:motionfit_squat/features/body_progress/domain/body_progress_summary.dart';

final bodyProgressCameraProvider = Provider<BodyProgressCamera>((ref) {
  return BodyProgressCamera();
});

/// Body Progress photos are not exercise specific, so they live in the shared
/// squat database rather than being duplicated per exercise.
final bodyProgressRepositoryProvider = Provider<BodyProgressRepository>((ref) {
  return BodyProgressRepository(
    ref.watch(appDatabaseProvider),
    onError: (error, stackTrace, reason) {
      ref
          .read(crashReportingServiceProvider)
          .recordNonFatal(error, stackTrace, reason: reason);
    },
  );
});

/// Directory that stores the captured images, resolved by the native plugin.
final bodyProgressDirectoryProvider = FutureProvider<Directory>((ref) {
  return ref.watch(bodyProgressCameraProvider).directory();
});

final selectedBodyViewProvider =
    NotifierProvider<SelectedBodyView, BodyView>(SelectedBodyView.new);

class SelectedBodyView extends Notifier<BodyView> {
  @override
  BodyView build() => BodyView.front;

  void select(BodyView view) => state = view;
}

/// Every stored photo, oldest first, across all views.
final bodyProgressPhotosProvider = FutureProvider<List<BodyProgressPhoto>>((
  ref,
) {
  return ref.watch(bodyProgressRepositoryProvider).loadPhotos();
});

/// Read model for the currently selected body view.
final bodyProgressSummaryProvider = FutureProvider<BodyProgressSummary>((
  ref,
) async {
  final view = ref.watch(selectedBodyViewProvider);
  final photos = await ref.watch(bodyProgressPhotosProvider.future);
  return BodyProgressSummary(
    bodyView: view,
    photos: photos.where((photo) => photo.bodyView == view).toList(),
  );
});

/// Number of photos stored for each view, used by the view selector.
final bodyProgressViewCountsProvider = FutureProvider<Map<BodyView, int>>((
  ref,
) async {
  final photos = await ref.watch(bodyProgressPhotosProvider.future);
  return {
    for (final view in BodyView.values)
      view: photos.where((photo) => photo.bodyView == view).length,
  };
});
