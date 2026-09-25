import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/state_views.dart';
import '../../domain/models/course.dart';
import '../../domain/models/lesson_progress.dart';
import '../../domain/progress_rules.dart';
import '../courses/course_card.dart';
import '../courses/courses_cubit.dart';
import 'lesson_tile.dart';

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
          appBar: AppBar(title: Text(course?.title ?? '')),
          body: switch (state.status) {
            CoursesStatus.loading => const LoadingView(),
            CoursesStatus.failure => ErrorView(
              message: l10n.loadCoursesError,
              onRetry: context.read<CoursesCubit>().load,
            ),
            CoursesStatus.loaded when course == null => EmptyView(
              message: l10n.courseNotFound,
            ),
            CoursesStatus.loaded => _CourseOutline(
              course: course!,
              progress: state.progress,
            ),
          },
        );
      },
    );
  }
}

class _CourseOutline extends StatelessWidget {
  const _CourseOutline({required this.course, required this.progress});

  final Course course;
  final Map<String, LessonProgress> progress;

  void _openLesson(BuildContext context, Lesson lesson) {
    if (!ProgressRules.isUnlocked(course, lesson.id, progress)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(context.l10n.lockedLessonMessage)),
        );
      return;
    }
    context.go(AppRoutes.lesson(course.id, lesson.id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final total = course.lessons.length;
    final completed = ProgressRules.completedLessons(course, progress);
    final locale = Localizations.localeOf(context).toLanguageTag();

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        AspectRatio(
          aspectRatio: 2,
          child: CourseThumbnail(path: course.thumbnail),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(course.title, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                course.instructor,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (course.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(course.description, style: theme.textTheme.bodyMedium),
              ],
              if (total > 0) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: ProgressRules.courseProgress(course, progress),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                const SizedBox(height: 8),
                Text(
                  '${l10n.completedOfTotal(completed, total)} · '
                  '${formatPercent(completed / total, locale)}',
                  style: theme.textTheme.labelMedium,
                ),
              ],
            ],
          ),
        ),
        if (total == 0)
          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: EmptyView(
              icon: Icons.video_library_outlined,
              message: l10n.emptyCourse,
            ),
          ),
        for (final section in course.sections) ...[
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 4),
            child: Text(
              section.title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          for (final lesson in section.lessons)
            LessonTile(
              lesson: lesson,
              status: ProgressRules.statusOf(
                progress[LessonProgress.keyOf(course.id, lesson.id)],
              ),
              isLocked: !ProgressRules.isUnlocked(course, lesson.id, progress),
              onTap: () => _openLesson(context, lesson),
            ),
        ],
      ],
    );
  }
}
