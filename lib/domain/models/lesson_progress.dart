/// How far a student got in one lesson.
class LessonProgress {
  const LessonProgress({
    required this.courseId,
    required this.lessonId,
    required this.position,
    required this.duration,
    required this.isCompleted,
    required this.updatedAt,
  });

  factory LessonProgress.fromJson(Map<String, dynamic> json) => LessonProgress(
    courseId: json['courseId'] as String,
    lessonId: json['lessonId'] as String,
    position: Duration(milliseconds: json['positionMs'] as int),
    duration: Duration(milliseconds: json['durationMs'] as int),
    isCompleted: json['completed'] as bool,
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  /// Lesson ids are only unique inside a course, so progress is keyed by both.
  static String keyOf(String courseId, String lessonId) =>
      '$courseId/$lessonId';

  final String courseId;
  final String lessonId;

  /// Last watched position.
  final Duration position;

  /// Real length of the video, as reported by the player.
  final Duration duration;
  final bool isCompleted;
  final DateTime updatedAt;

  String get key => keyOf(courseId, lessonId);

  LessonProgress copyWith({bool? isCompleted}) => LessonProgress(
    courseId: courseId,
    lessonId: lessonId,
    position: position,
    duration: duration,
    isCompleted: isCompleted ?? this.isCompleted,
    updatedAt: updatedAt,
  );

  Map<String, dynamic> toJson() => {
    'courseId': courseId,
    'lessonId': lessonId,
    'positionMs': position.inMilliseconds,
    'durationMs': duration.inMilliseconds,
    'completed': isCompleted,
    'updatedAt': updatedAt.toIso8601String(),
  };
}
