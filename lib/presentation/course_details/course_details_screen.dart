import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n/l10n.dart';
import '../../core/widgets/empty_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../courses/courses_cubit.dart';
import 'course_outline.dart';

class CourseDetailsScreen extends StatelessWidget {
  const CourseDetailsScreen({super.key, required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<CoursesCubit, CoursesState>(
      builder: (context, state) {
        final course = state.courseById(courseId);
        return Scaffold(
          appBar: AppBar(title: Text(course?.title.of(l10n.localeName) ?? '')),
          body: switch (state.status) {
            CoursesStatus.loading => const LoadingView(),
            CoursesStatus.failure => ErrorView(
              message: l10n.loadCoursesError,
              onRetry: context.read<CoursesCubit>().load,
            ),
            CoursesStatus.loaded when course == null => EmptyView(
              message: l10n.courseNotFound,
            ),
            CoursesStatus.loaded => CourseOutline(
              course: course!,
              state: state,
            ),
          },
        );
      },
    );
  }
}
