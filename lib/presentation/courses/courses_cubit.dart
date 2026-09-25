import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/course_repository.dart';
import '../../data/progress_repository.dart';
import '../../domain/models/lesson_progress.dart';
import 'courses_state.dart';

export 'courses_state.dart';

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
    } catch (error, stackTrace) {
      // Missing file, invalid JSON or a wrong field type: show a retry.
      addError(error, stackTrace);
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
