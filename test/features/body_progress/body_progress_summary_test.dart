import 'package:flutter_test/flutter_test.dart';
import 'package:motionfit_squat/features/body_progress/domain/body_progress_photo.dart';
import 'package:motionfit_squat/features/body_progress/domain/body_progress_summary.dart';

BodyProgressPhoto photoOn(
  DateTime moment, {
  BodyView view = BodyView.front,
  String? id,
}) => BodyProgressPhoto(
  id: id ?? moment.toIso8601String(),
  capturedAt: moment,
  capturedOn: BodyProgressPhoto.dayKey(moment),
  bodyView: view,
  imageFile: 'body_${moment.millisecondsSinceEpoch}.jpg',
  imageWidth: 1200,
  imageHeight: 1600,
  createdAt: moment,
);

void main() {
  final origin = DateTime(2026, 3, 1, 8);

  test('an empty summary reports no photos and pending milestones', () {
    final summary = BodyProgressSummary(bodyView: BodyView.front, photos: []);

    expect(summary.isEmpty, isTrue);
    expect(summary.first, isNull);
    expect(summary.latest, isNull);
    expect(summary.spanDays, 0);
    expect(summary.currentDayNumber, 0);
    expect(summary.currentStreakDays, 0);
    expect(summary.milestones.every((milestone) => !milestone.reached), isTrue);
  });

  test('photos are ordered oldest first regardless of input order', () {
    final summary = BodyProgressSummary(
      bodyView: BodyView.front,
      photos: [
        photoOn(origin.add(const Duration(days: 9))),
        photoOn(origin),
        photoOn(origin.add(const Duration(days: 4))),
      ],
    );

    expect(summary.first!.capturedAt, origin);
    expect(summary.latest!.capturedAt, origin.add(const Duration(days: 9)));
    expect(summary.spanDays, 9);
    expect(summary.currentDayNumber, 10);
  });

  test('day numbers count the first photo as day 1', () {
    final later = origin.add(const Duration(days: 6));
    final summary = BodyProgressSummary(
      bodyView: BodyView.front,
      photos: [photoOn(origin), photoOn(later)],
    );

    expect(summary.dayNumberOf(summary.first!), 1);
    expect(summary.dayNumberOf(summary.latest!), 7);
  });

  test('a milestone resolves to the first photo on or after its offset', () {
    final summary = BodyProgressSummary(
      bodyView: BodyView.front,
      photos: [
        photoOn(origin),
        // Day 7 was skipped; day 9 is the first photo at or past that offset.
        photoOn(origin.add(const Duration(days: 8))),
      ],
    );

    final milestones = {
      for (final milestone in summary.milestones) milestone.day: milestone,
    };
    expect(milestones[1]!.photo!.capturedAt, origin);
    expect(
      milestones[7]!.photo!.capturedAt,
      origin.add(const Duration(days: 8)),
    );
    expect(milestones[30]!.reached, isFalse);
    expect(milestones[90]!.reached, isFalse);
  });

  test('recorded days counts calendar days, not photos', () {
    final summary = BodyProgressSummary(
      bodyView: BodyView.front,
      photos: [
        photoOn(origin, id: 'a'),
        photoOn(origin.add(const Duration(hours: 6)), id: 'b'),
        photoOn(origin.add(const Duration(days: 1)), id: 'c'),
      ],
    );

    expect(summary.photoCount, 3);
    expect(summary.recordedDayCount, 2);
  });

  test('the streak runs back from today', () {
    final today = DateTime.now();
    final summary = BodyProgressSummary(
      bodyView: BodyView.front,
      photos: [
        photoOn(today.subtract(const Duration(days: 2))),
        photoOn(today.subtract(const Duration(days: 1))),
        photoOn(today),
      ],
    );

    expect(summary.currentStreakDays, 3);
  });

  test('a gap before today ends the streak', () {
    final today = DateTime.now();
    final summary = BodyProgressSummary(
      bodyView: BodyView.front,
      photos: [
        photoOn(today.subtract(const Duration(days: 9))),
        photoOn(today.subtract(const Duration(days: 8))),
      ],
    );

    expect(summary.currentStreakDays, 0);
  });

  test('a day key is stable across times of day', () {
    final morning = DateTime(2026, 3, 1, 6, 30);
    final evening = DateTime(2026, 3, 1, 22, 15);

    expect(BodyProgressPhoto.dayKey(morning), '2026-03-01');
    expect(
      BodyProgressPhoto.dayKey(morning),
      BodyProgressPhoto.dayKey(evening),
    );
  });
}
