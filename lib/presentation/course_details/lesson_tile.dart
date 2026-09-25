import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/utils/formatters.dart';
import '../../domain/models/course.dart';
import '../../domain/progress_rules.dart';

class LessonTile extends StatelessWidget {
  const LessonTile({
    super.key,
    required this.lesson,
    required this.status,
    required this.isLocked,
    required this.onTap,
  });

  final Lesson lesson;
  final LessonStatus status;
  final bool isLocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;

    final (icon, color, label) = isLocked
        ? (Icons.lock_outline, colors.outline, l10n.statusLocked)
        : switch (status) {
            LessonStatus.notStarted => (
              Icons.play_circle_outline,
              colors.primary,
              l10n.statusNotStarted,
            ),
            LessonStatus.inProgress => (
              Icons.timelapse,
              colors.tertiary,
              l10n.statusInProgress,
            ),
            LessonStatus.completed => (
              Icons.check_circle,
              colors.primary,
              l10n.statusCompleted,
            ),
          };

    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color),
      title: Text(
        lesson.title,
        style: TextStyle(color: isLocked ? colors.outline : null),
      ),
      subtitle: Text('${formatDuration(lesson.duration)} · $label'),
      // chevron_right mirrors automatically in RTL.
      trailing: isLocked ? null : const Icon(Icons.chevron_right),
    );
  }
}
