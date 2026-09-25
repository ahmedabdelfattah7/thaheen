import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/utils/formatters.dart';
import '../../domain/models/course.dart';
import 'course_thumbnail.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.course,
    required this.progress,
    required this.onTap,
  });

  final Course course;

  /// Share of completed lessons, 0.0–1.0.
  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = l10n.localeName;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 2.2,
              child: CourseThumbnail(path: course.thumbnail),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title.of(lang),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${bidiIsolate(course.instructor.of(lang))} · '
                    '${l10n.lessonsCount(course.lessons.length)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (course.lessons.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.percentComplete(formatPercent(progress, locale)),
                          style: theme.textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
