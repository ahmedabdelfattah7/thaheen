import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/formatters.dart';
import 'player_cubit.dart';

/// Opens the next lesson, but only once this one is completed (which is
/// exactly what unlocks the next lesson).
class NextLessonButton extends StatelessWidget {
  const NextLessonButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final cubit = context.read<PlayerCubit>();
    final courseId = cubit.course.id;
    final next = cubit.nextLesson;
    final isCompleted = context.select((PlayerCubit c) => c.state.isCompleted);

    if (next == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.lastLesson, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => context.go(AppRoutes.course(courseId)),
            icon: const Icon(Icons.flag_outlined),
            label: Text(l10n.backToCourse),
          ),
        ],
      );
    }

    return FilledButton.icon(
      onPressed: isCompleted
          ? () => context.go(AppRoutes.lesson(courseId, next.id))
          : () => ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(l10n.nextLessonLocked))),
      style: isCompleted
          ? null
          : FilledButton.styleFrom(
              backgroundColor: colors.surfaceContainerHighest,
              foregroundColor: colors.onSurfaceVariant,
            ),
      // arrow_forward mirrors in RTL, so it points "forward" in Arabic too.
      icon: Icon(isCompleted ? Icons.arrow_forward : Icons.lock_outline),
      iconAlignment: IconAlignment.end,
      label: Text(
        '${l10n.nextLesson}: ${bidiIsolate(next.title.of(l10n.localeName))}',
      ),
    );
  }
}
