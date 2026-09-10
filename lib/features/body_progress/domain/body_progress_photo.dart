import 'package:motionfit_squat/features/squat/domain/models/workout_enums.dart';

/// Camera framing a Body Progress photo was taken from.
///
/// A day keeps one representative photo per view so the feature stays a
/// change log rather than a general photo gallery.
enum BodyView { front, side, back }

/// How a Body Progress photo came to exist.
///
/// The automatic capture is the main path: the app takes one frame per day as
/// the workout's calibration settles. Manual capture stays available for a
/// deliberate retake.
enum BodyProgressSource { auto, manual }

class BodyProgressPhoto {
  const BodyProgressPhoto({
    required this.id,
    required this.capturedAt,
    required this.capturedOn,
    required this.bodyView,
    required this.imageFile,
    required this.imageWidth,
    required this.imageHeight,
    required this.createdAt,
    this.source = BodyProgressSource.manual,
    this.sessionId,
  });

  final String id;
  final DateTime capturedAt;

  /// Local day key in `yyyy-MM-dd` form, unique per [bodyView].
  final String capturedOn;
  final BodyView bodyView;

  /// File name inside the Body Progress directory, never an absolute path.
  ///
  /// iOS rewrites the application container path on some restores, so only the
  /// name is persisted and the directory is resolved at read time.
  final String imageFile;
  final int imageWidth;
  final int imageHeight;
  final DateTime createdAt;
  final BodyProgressSource source;

  /// Workout that produced an automatic capture, null for a manual one.
  final String? sessionId;

  bool get isAutomatic => source == BodyProgressSource.auto;

  double get aspectRatio =>
      imageWidth > 0 && imageHeight > 0 ? imageWidth / imageHeight : 3 / 4;

  static String dayKey(DateTime moment) {
    final local = moment.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'captured_at': capturedAt.millisecondsSinceEpoch,
    'captured_on': capturedOn,
    'body_view': bodyView.name,
    'image_file': imageFile,
    'image_width': imageWidth,
    'image_height': imageHeight,
    'source': source.name,
    'session_id': sessionId,
    'created_at': createdAt.millisecondsSinceEpoch,
  };

  factory BodyProgressPhoto.fromMap(Map<String, Object?> map) =>
      BodyProgressPhoto(
        id: map['id']! as String,
        capturedAt: DateTime.fromMillisecondsSinceEpoch(
          map['captured_at']! as int,
        ),
        capturedOn: map['captured_on']! as String,
        bodyView: enumByName(
          BodyView.values,
          map['body_view'] as String?,
          BodyView.front,
        ),
        imageFile: map['image_file']! as String,
        imageWidth: (map['image_width'] as num?)?.toInt() ?? 0,
        imageHeight: (map['image_height'] as num?)?.toInt() ?? 0,
        source: enumByName(
          BodyProgressSource.values,
          map['source'] as String?,
          BodyProgressSource.manual,
        ),
        sessionId: map['session_id'] as String?,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          map['created_at']! as int,
        ),
      );
}
