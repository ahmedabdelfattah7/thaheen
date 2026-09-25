import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/empty_view.dart';
import '../../domain/models/course.dart';
import '../courses/course_thumbnail.dart';
import '../courses/courses_state.dart';
import 'lesson_tile.dart';

/// Course header, overall progress and the lessons grouped by section.
class CourseOutline extends StatelessWidget {
  const CourseOutline({super.key, required this.course, required this.state});

  final Course course;
  final CoursesState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final total = course.lessons.length;
    final completed = state.completedLessonsOf(course);
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
                Text(
                  // Isolated so Arabic punctuation stays put in the English UI.
                  bidiIsolate(course.description),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
              if (total > 0) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: state.progressOf(course),
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
              status: state.statusOf(course, lesson),
              isLocked: !state.isUnlocked(course, lesson),
              onOpen: () => context.go(AppRoutes.lesson(course.id, lesson.id)),
            ),
        ],
      ],
    );
  }
}
