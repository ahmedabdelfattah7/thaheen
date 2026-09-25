import 'models/course.dart';
import 'models/lesson_progress.dart';

enum LessonStatus { notStarted, inProgress, completed }

/// The unfinished lesson shown in the "Continue watching" card.
typedef ContinueWatchingItem = ({
  Course course,
  Lesson lesson,
  LessonProgress progress,
});

/// All learning rules of the app. Pure functions: no Flutter, no storage.
abstract final class ProgressRules {
  /// Share of a lesson that must be watched to complete it.
  static const completionThreshold = 0.9;

  /// Reopening a lesson this close to its end starts it over.
  static const restartMargin = Duration(seconds: 3);

  static bool isCompleted(Duration position, Duration duration) {
    if (duration <= Duration.zero) return false;
    return position.inMilliseconds >=
        duration.inMilliseconds * completionThreshold;
  }

  static LessonStatus statusOf(LessonProgress? progress) {
    if (progress == null) return LessonStatus.notStarted;
    if (progress.isCompleted) return LessonStatus.completed;
    return progress.position > Duration.zero
        ? LessonStatus.inProgress
        : LessonStatus.notStarted;
  }

  /// The first lesson is always open. Any other lesson opens once the lesson
  /// before it (in watch order, across sections) is completed.
  static bool isUnlocked(
    Course course,
    String lessonId,
    Map<String, LessonProgress> progress,
  ) {
    final lessons = course.lessons;
    final index = lessons.indexWhere((l) => l.id == lessonId);
    if (index < 0) return false;
    if (index == 0) return true;
    return _isDone(course, lessons[index - 1], progress);
  }

  static int completedLessons(
    Course course,
    Map<String, LessonProgress> progress,
  ) => course.lessons.where((l) => _isDone(course, l, progress)).length;

  /// Completed lessons ÷ all lessons, from 0.0 to 1.0. An empty course is 0.
  static double courseProgress(
    Course course,
    Map<String, LessonProgress> progress,
  ) {
    final total = course.lessons.length;
    if (total == 0) return 0;
    return completedLessons(course, progress) / total;
  }

  static Lesson? nextLesson(Course course, String lessonId) {
    final lessons = course.lessons;
    final index = lessons.indexWhere((l) => l.id == lessonId);
    if (index < 0 || index == lessons.length - 1) return null;
    return lessons[index + 1];
  }

  /// Where playback should start: the saved position, or the beginning when
  /// there is none or the student had already reached the very end.
  static Duration resumePosition(LessonProgress? progress, Duration duration) {
    final position = progress?.position ?? Duration.zero;
    if (position <= Duration.zero || position >= duration - restartMargin) {
      return Duration.zero;
    }
    return position;
  }

  /// The most recently watched lesson that is started but not completed.
  static ContinueWatchingItem? continueWatching(
    List<Course> courses,
    Map<String, LessonProgress> progress,
  ) {
    final unfinished =
        progress.values
            .where((p) => statusOf(p) == LessonStatus.inProgress)
            .toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    for (final p in unfinished) {
      for (final course in courses) {
        if (course.id != p.courseId) continue;
        final lesson = course.lessonById(p.lessonId);
        if (lesson != null) {
          return (course: course, lesson: lesson, progress: p);
        }
      }
    }
    return null;
  }

  static bool _isDone(
    Course course,
    Lesson lesson,
    Map<String, LessonProgress> progress,
  ) =>
      progress[LessonProgress.keyOf(course.id, lesson.id)]?.isCompleted ??
      false;
}
