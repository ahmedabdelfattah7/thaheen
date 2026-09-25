import 'localized_text.dart';

/// A course from the bundled catalog (`assets/data/courses.json`).
class Course {
  const Course({
    required this.id,
    required this.title,
    required this.instructor,
    this.description = LocalizedText.empty,
    this.thumbnail,
    this.sections = const [],
  });

  factory Course.fromJson(Map<String, dynamic> json) => Course(
    id: json['id'] as String,
    title: LocalizedText.fromJson(json['title']),
    instructor: LocalizedText.fromJson(json['instructor'] ?? ''),
    description: LocalizedText.fromJson(json['description'] ?? ''),
    thumbnail: json['thumbnail'] as String?,
    sections: [
      for (final section in json['sections'] as List? ?? const [])
        Section.fromJson(section as Map<String, dynamic>),
    ],
  );

  final String id;
  final LocalizedText title;
  final LocalizedText instructor;
  final LocalizedText description;
  final String? thumbnail;
  final List<Section> sections;

  /// All lessons in watch order (sections flattened).
  List<Lesson> get lessons => [for (final s in sections) ...s.lessons];

  Lesson? lessonById(String lessonId) {
    for (final lesson in lessons) {
      if (lesson.id == lessonId) return lesson;
    }
    return null;
  }
}

class Section {
  const Section({
    required this.id,
    required this.title,
    this.lessons = const [],
  });

  factory Section.fromJson(Map<String, dynamic> json) => Section(
    id: json['id'] as String,
    title: LocalizedText.fromJson(json['title']),
    lessons: [
      for (final lesson in json['lessons'] as List? ?? const [])
        Lesson.fromJson(lesson as Map<String, dynamic>),
    ],
  );

  final String id;
  final LocalizedText title;
  final List<Lesson> lessons;
}

class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.duration,
    required this.video,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
    id: json['id'] as String,
    title: LocalizedText.fromJson(json['title']),
    duration: Duration(seconds: (json['durationSec'] as num?)?.toInt() ?? 0),
    video: json['video'] as String,
  );

  final String id;
  final LocalizedText title;

  /// Display length from the catalog. Completion uses the real video length.
  final Duration duration;

  /// Asset path of the lesson video.
  final String video;
}
