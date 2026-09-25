import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n/l10n.dart';
import '../../core/widgets/empty_view.dart';
import '../../core/widgets/loading_view.dart';
import '../courses/courses_cubit.dart';
import 'lesson_player_view.dart';
import 'notes_cubit.dart';
import 'player_cubit.dart';

/// The lesson route. go_router reuses this page when only the lesson id in
/// the URL changes ("Next lesson"), so the providers are keyed by lesson to
/// give every lesson a fresh cubit and video controller.
class PlayerScreen extends StatelessWidget {
  const PlayerScreen({
    super.key,
    required this.courseId,
    required this.lessonId,
  });

  final String courseId;
  final String lessonId;

  @override
  Widget build(BuildContext context) {
    final status = context.select((CoursesCubit c) => c.state.status);
    final course = context.select(
      (CoursesCubit c) => c.state.courseById(courseId),
    );
    final lesson = course?.lessonById(lessonId);

    if (status == CoursesStatus.loading) {
      return const Scaffold(body: LoadingView());
    }
    if (course == null || lesson == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyView(message: context.l10n.lessonNotFound),
      );
    }

    return MultiBlocProvider(
      key: ValueKey('${course.id}/${lesson.id}'),
      providers: [
        BlocProvider(
          create: (context) => PlayerCubit(
            course: course,
            lesson: lesson,
            progress: context.read(),
            settings: context.read(),
          )..load(),
        ),
        BlocProvider(
          create: (context) => NotesCubit(
            courseId: course.id,
            lessonId: lesson.id,
            repository: context.read(),
          ),
        ),
      ],
      child: LessonPlayerView(course: course, lesson: lesson),
    );
  }
}
