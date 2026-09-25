import 'package:flutter_test/flutter_test.dart';
import 'package:thaheen/domain/models/course.dart';
import 'package:thaheen/domain/models/lesson_progress.dart';
import 'package:thaheen/domain/progress_rules.dart';

const _lesson = Duration(seconds: 100);

// Two sections: [a, b] then [c].
const course = Course(
  id: 'course',
  title: 'Course',
  instructor: 'Dr.',
  sections: [
    Section(
      id: 's1',
      title: 'S1',
      lessons: [
        Lesson(id: 'a', title: 'a', duration: _lesson, video: 'a.mp4'),
        Lesson(id: 'b', title: 'b', duration: _lesson, video: 'b.mp4'),
      ],
    ),
    Section(
      id: 's2',
      title: 'S2',
      lessons: [Lesson(id: 'c', title: 'c', duration: _lesson, video: 'c.mp4')],
    ),
  ],
);

LessonProgress progress(
  String lessonId, {
  int seconds = 10,
  bool completed = false,
  String courseId = 'course',
  DateTime? updatedAt,
}) => LessonProgress(
  courseId: courseId,
  lessonId: lessonId,
  position: Duration(seconds: seconds),
  duration: _lesson,
  isCompleted: completed,
  updatedAt: updatedAt ?? DateTime(2026),
);

Map<String, LessonProgress> byKey(List<LessonProgress> items) => {
  for (final p in items) p.key: p,
};

void main() {
  group('isCompleted (90% rule)', () {
    test('is false just below 90%', () {
      expect(
        ProgressRules.isCompleted(const Duration(milliseconds: 89999), _lesson),
        isFalse,
      );
    });

    test('is true at exactly 90% and after', () {
      expect(
        ProgressRules.isCompleted(const Duration(seconds: 90), _lesson),
        isTrue,
      );
      expect(ProgressRules.isCompleted(_lesson, _lesson), isTrue);
    });

    test('is false while the duration is unknown (zero)', () {
      expect(ProgressRules.isCompleted(Duration.zero, Duration.zero), isFalse);
    });
  });

  group('statusOf', () {
    test('maps progress to not started / in progress / completed', () {
      expect(ProgressRules.statusOf(null), LessonStatus.notStarted);
      expect(
        ProgressRules.statusOf(progress('a', seconds: 0)),
        LessonStatus.notStarted,
      );
      expect(ProgressRules.statusOf(progress('a')), LessonStatus.inProgress);
      expect(
        ProgressRules.statusOf(progress('a', completed: true)),
        LessonStatus.completed,
      );
    });
  });

  group('isUnlocked (sequential unlock)', () {
    test('the first lesson is always unlocked', () {
      expect(ProgressRules.isUnlocked(course, 'a', {}), isTrue);
    });

    test('a lesson stays locked while the previous one is unfinished', () {
      expect(ProgressRules.isUnlocked(course, 'b', {}), isFalse);
      expect(
        ProgressRules.isUnlocked(
          course,
          'b',
          byKey([progress('a', seconds: 80)]),
        ),
        isFalse,
      );
    });

    test('a lesson unlocks once the previous one is completed', () {
      expect(
        ProgressRules.isUnlocked(
          course,
          'b',
          byKey([progress('a', completed: true)]),
        ),
        isTrue,
      );
    });

    test('the rule crosses section boundaries', () {
      final onlyA = byKey([progress('a', completed: true)]);
      expect(ProgressRules.isUnlocked(course, 'c', onlyA), isFalse);

      final aAndB = byKey([
        progress('a', completed: true),
        progress('b', completed: true),
      ]);
      expect(ProgressRules.isUnlocked(course, 'c', aAndB), isTrue);
    });

    test('an unknown lesson is locked', () {
      expect(ProgressRules.isUnlocked(course, 'zzz', {}), isFalse);
    });
  });

  group('courseProgress (progress %)', () {
    test('counts completed lessons over all lessons', () {
      expect(ProgressRules.courseProgress(course, {}), 0);
      expect(
        ProgressRules.courseProgress(
          course,
          byKey([progress('a', completed: true), progress('b', seconds: 50)]),
        ),
        closeTo(1 / 3, 1e-9),
      );
      expect(
        ProgressRules.courseProgress(
          course,
          byKey([
            progress('a', completed: true),
            progress('b', completed: true),
            progress('c', completed: true),
          ]),
        ),
        1.0,
      );
    });

    test('is 0 (not NaN) for a course with no lessons', () {
      const empty = Course(id: 'empty', title: 'Empty', instructor: 'Dr.');
      expect(ProgressRules.courseProgress(empty, {}), 0);
    });

    test('ignores the same lesson id in another course', () {
      final other = byKey([
        progress('a', completed: true, courseId: 'another-course'),
      ]);
      expect(ProgressRules.courseProgress(course, other), 0);
    });
  });

  group('nextLesson', () {
    test('follows watch order across sections and ends at the last lesson', () {
      expect(ProgressRules.nextLesson(course, 'a')?.id, 'b');
      expect(ProgressRules.nextLesson(course, 'b')?.id, 'c');
      expect(ProgressRules.nextLesson(course, 'c'), isNull);
    });
  });

  group('resumePosition', () {
    test('starts from zero when there is no saved position', () {
      expect(ProgressRules.resumePosition(null, _lesson), Duration.zero);
    });

    test('resumes from the saved position', () {
      expect(
        ProgressRules.resumePosition(progress('a', seconds: 42), _lesson),
        const Duration(seconds: 42),
      );
    });

    test('starts over when the student had reached the very end', () {
      expect(
        ProgressRules.resumePosition(progress('a', seconds: 98), _lesson),
        Duration.zero,
      );
    });
  });

  group('continueWatching', () {
    test('returns the most recently watched unfinished lesson', () {
      final item = ProgressRules.continueWatching(
        [course],
        byKey([
          progress('a', updatedAt: DateTime(2026, 1, 1)),
          progress('b', updatedAt: DateTime(2026, 1, 3)),
          progress('c', completed: true, updatedAt: DateTime(2026, 1, 5)),
        ]),
      );
      expect(item?.lesson.id, 'b');
      expect(item?.course.id, 'course');
    });

    test('is null when nothing is in progress', () {
      expect(
        ProgressRules.continueWatching([
          course,
        ], byKey([progress('a', completed: true)])),
        isNull,
      );
    });
  });
}
