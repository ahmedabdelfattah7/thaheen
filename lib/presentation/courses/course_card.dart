import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/utils/formatters.dart';
import '../../domain/models/course.dart';

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
                  Text(course.title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    '${course.instructor} · ${l10n.lessonsCount(course.lessons.length)}',
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

/// Course image with a neutral placeholder when it is missing or broken.
class CourseThumbnail extends StatelessWidget {
  const CourseThumbnail({super.key, required this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    final path = this.path;
    if (path == null) return const _Placeholder();
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const _Placeholder(),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colors.secondaryContainer,
      child: Icon(
        Icons.school_outlined,
        size: 40,
        color: colors.onSecondaryContainer,
      ),
    );
  }
}
