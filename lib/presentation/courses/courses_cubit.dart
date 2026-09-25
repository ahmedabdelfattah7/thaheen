import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/course_repository.dart';
import '../../data/progress_repository.dart';
import '../../domain/models/course.dart';
import '../../domain/models/lesson_progress.dart';

enum CoursesStatus { loading, loaded, failure }

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

  Course? courseById(String id) {
    for (final course in courses) {
      if (course.id == id) return course;
    }
    return null;
  }

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

/// App-wide catalog + progress. Both the courses list and the course
/// details screen read from it, and it refreshes whenever progress is saved.
class CoursesCubit extends Cubit<CoursesState> {
  CoursesCubit(this._courses, ProgressRepository progress)
    : super(CoursesState(progress: progress.getAll())) {
    _progressChanges = progress.changes.listen(
      (progress) => emit(state.copyWith(progress: progress)),
    );
  }

  final CourseRepository _courses;
  late final StreamSubscription<Map<String, LessonProgress>> _progressChanges;

  Future<void> load() async {
    emit(state.copyWith(status: CoursesStatus.loading));
    try {
      final courses = await _courses.getCourses();
      emit(state.copyWith(status: CoursesStatus.loaded, courses: courses));
    } catch (error) {
      // Missing file, invalid JSON or a wrong field type: show a retry.
      debugPrint('Could not load courses: $error');
      emit(state.copyWith(status: CoursesStatus.failure));
    }
  }

  void search(String query) => emit(state.copyWith(query: query));

  @override
  Future<void> close() async {
    await _progressChanges.cancel();
    return super.close();
  }
}
