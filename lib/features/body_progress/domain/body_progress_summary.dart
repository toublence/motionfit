import 'package:motionfit_squat/features/body_progress/domain/body_progress_photo.dart';

/// Milestone offsets the Body Progress screen highlights, in days from the
/// first photo of a view.
const bodyProgressMilestoneDays = <int>[1, 7, 30, 90];

class BodyProgressMilestone {
  const BodyProgressMilestone({
    required this.day,
    required this.photo,
    required this.reached,
  });

  final int day;

  /// Closest photo at or after [day], null while the milestone is pending.
  final BodyProgressPhoto? photo;
  final bool reached;
}

/// Read model behind the Body Progress home screen.
///
/// Photos arrive newest first from the repository and are re-sorted here so
/// comparison and timelapse surfaces can share one chronological list.
class BodyProgressSummary {
  BodyProgressSummary({
    required this.bodyView,
    required List<BodyProgressPhoto> photos,
  }) : photos = List.unmodifiable(
         [...photos]..sort((a, b) => a.capturedAt.compareTo(b.capturedAt)),
       );

  final BodyView bodyView;

  /// Oldest first, so index 0 is always the Day 1 reference.
  final List<BodyProgressPhoto> photos;

  bool get isEmpty => photos.isEmpty;

  BodyProgressPhoto? get first => photos.isEmpty ? null : photos.first;

  BodyProgressPhoto? get latest => photos.isEmpty ? null : photos.last;

  int get photoCount => photos.length;

  /// Whole days between the first and the latest photo, 0 for a single entry.
  int get spanDays {
    final start = first;
    final end = latest;
    if (start == null || end == null) return 0;
    return _dayOnly(end.capturedAt).difference(_dayOnly(start.capturedAt)).inDays;
  }

  /// `Day N` label of the latest photo, counting the first photo as day 1.
  int get currentDayNumber => photos.isEmpty ? 0 : spanDays + 1;

  /// Distinct calendar days that hold at least one photo.
  int get recordedDayCount =>
      photos.map((photo) => photo.capturedOn).toSet().length;

  /// Consecutive days ending today or yesterday that hold a photo.
  int get currentStreakDays {
    if (photos.isEmpty) return 0;
    final days = photos.map((photo) => _dayOnly(photo.capturedAt)).toSet();
    final today = _dayOnly(DateTime.now());
    var cursor = days.contains(today)
        ? today
        : today.subtract(const Duration(days: 1));
    if (!days.contains(cursor)) return 0;
    var streak = 0;
    while (days.contains(cursor)) {
      streak++;
      cursor = _dayOnly(cursor.subtract(const Duration(days: 1)));
    }
    return streak;
  }

  int dayNumberOf(BodyProgressPhoto photo) {
    final start = first;
    if (start == null) return 1;
    return _dayOnly(
          photo.capturedAt,
        ).difference(_dayOnly(start.capturedAt)).inDays +
        1;
  }

  /// Milestone photos for Day 1 / 7 / 30 / 90, using the earliest photo taken
  /// on or after each offset so a skipped day still resolves.
  List<BodyProgressMilestone> get milestones {
    final start = first;
    if (start == null) {
      return bodyProgressMilestoneDays
          .map(
            (day) =>
                BodyProgressMilestone(day: day, photo: null, reached: false),
          )
          .toList(growable: false);
    }
    final origin = _dayOnly(start.capturedAt);
    return bodyProgressMilestoneDays.map((day) {
      final target = origin.add(Duration(days: day - 1));
      for (final photo in photos) {
        if (!_dayOnly(photo.capturedAt).isBefore(target)) {
          return BodyProgressMilestone(day: day, photo: photo, reached: true);
        }
      }
      return BodyProgressMilestone(day: day, photo: null, reached: false);
    }).toList(growable: false);
  }

  static DateTime _dayOnly(DateTime moment) {
    final local = moment.toLocal();
    return DateTime(local.year, local.month, local.day);
  }
}
