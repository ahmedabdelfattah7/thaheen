// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Thaheen';

  @override
  String get myCourses => 'My courses';

  @override
  String get searchHint => 'Search courses or instructors';

  @override
  String get continueWatching => 'Continue watching';

  @override
  String get resume => 'Resume';

  @override
  String lessonsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lessons',
      one: '1 lesson',
      zero: 'No lessons',
    );
    return '$_temp0';
  }

  @override
  String percentComplete(String percent) {
    return '$percent complete';
  }

  @override
  String completedOfTotal(int completed, int total) {
    return '$completed of $total completed';
  }

  @override
  String get noCourses => 'No courses yet';

  @override
  String noSearchResults(String query) {
    return 'No results for “$query”';
  }

  @override
  String get loadCoursesError => 'Couldn\'t load courses';

  @override
  String get retry => 'Try again';

  @override
  String get courseNotFound => 'Course not found';

  @override
  String get emptyCourse => 'This course has no lessons yet';

  @override
  String get statusNotStarted => 'Not started';

  @override
  String get statusInProgress => 'In progress';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusLocked => 'Locked';

  @override
  String get lockedLessonMessage =>
      'This lesson is locked. Finish the previous lesson to unlock it.';

  @override
  String get lessonNotFound => 'Lesson not found';

  @override
  String get videoError => 'This video can\'t be played';

  @override
  String get videoErrorHint => 'The file may be missing or damaged.';

  @override
  String get playbackSpeed => 'Playback speed';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get enterFullscreen => 'Full screen';

  @override
  String get exitFullscreen => 'Exit full screen';

  @override
  String get nextLesson => 'Next lesson';

  @override
  String get nextLessonLocked =>
      'Watch 90% of this lesson to unlock the next one';

  @override
  String get lessonCompleted => 'Nice! Lesson completed';

  @override
  String get lastLesson => 'This is the last lesson of the course';

  @override
  String get backToCourse => 'Back to course';

  @override
  String get notes => 'My notes';

  @override
  String get notesHint => 'Write your notes for this lesson…';

  @override
  String get notesSaved => 'Saved';

  @override
  String get switchLanguage => 'العربية';

  @override
  String get toggleTheme => 'Toggle dark mode';
}
