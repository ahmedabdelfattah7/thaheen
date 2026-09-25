import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../../domain/progress_rules.dart';
import 'course_card.dart';

/// Shortcut back into the most recently watched unfinished lesson.
class ContinueWatchingCard extends StatelessWidget {
  const ContinueWatchingCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final ContinueWatchingItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final progress = item.progress;
    final watched = progress.duration > Duration.zero
        ? progress.position.inMilliseconds / progress.duration.inMilliseconds
        : 0.0;

    return Card(
      color: colors.primaryContainer,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 96,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: CourseThumbnail(path: item.course.thumbnail),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.lesson.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      '${bidiIsolate(item.course.title)} · '
                      '${formatDuration(progress.position)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: watched.clamp(0.0, 1.0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.play_circle_fill, size: 36, color: colors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
