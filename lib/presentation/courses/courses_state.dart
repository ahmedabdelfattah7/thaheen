import '../../domain/models/course.dart';
import '../../domain/models/lesson_progress.dart';
import '../../domain/progress_rules.dart';

enum CoursesStatus { loading, loaded, failure }

/// Catalog + saved progress. The getters answer everything the courses and
/// course-details screens need, so the widgets hold no logic.
class CoursesState {
  const CoursesState({
    this.status = CoursesStatus.loading,
    this.courses = const [],
    this.progress = const {},
    this.query = '',
  });

  final CoursesStatus status;
  final List<Course> courses;
  final Map<String, LessonProgress> progress;
  final String query;

  /// Courses whose title or instructor matches the search query.
  List<Course> get visibleCourses {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return courses;
    return courses
        .where(
          (c) =>
              c.title.toLowerCase().contains(q) ||
              c.instructor.toLowerCase().contains(q),
        )
        .toList();
  }

  /// Hidden while searching.
  ContinueWatchingItem? get continueWatching => query.trim().isEmpty
      ? ProgressRules.continueWatching(courses, progress)
      : null;

  Course? courseById(String id) {
    for (final course in courses) {
      if (course.id == id) return course;
    }
    return null;
  }

  double progressOf(Course course) =>
      ProgressRules.courseProgress(course, progress);

  int completedLessonsOf(Course course) =>
      ProgressRules.completedLessons(course, progress);

  LessonStatus statusOf(Course course, Lesson lesson) => ProgressRules.statusOf(
    progress[LessonProgress.keyOf(course.id, lesson.id)],
  );

  bool isUnlocked(Course course, Lesson lesson) =>
      ProgressRules.isUnlocked(course, lesson.id, progress);

  CoursesState copyWith({
    CoursesStatus? status,
    List<Course>? courses,
    Map<String, LessonProgress>? progress,
    String? query,
  }) => CoursesState(
    status: status ?? this.status,
    courses: courses ?? this.courses,
    progress: progress ?? this.progress,
    query: query ?? this.query,
  );
}
