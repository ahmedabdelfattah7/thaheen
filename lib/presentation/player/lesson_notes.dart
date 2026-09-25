import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n/l10n.dart';
import 'notes_cubit.dart';

/// The student's private note for this lesson, saved as they type.
class LessonNotes extends StatelessWidget {
  const LessonNotes({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cubit = context.read<NotesCubit>();
    final status = context.watch<NotesCubit>().state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(l10n.notes, style: theme.textTheme.titleMedium),
            const Spacer(),
            if (status == NoteStatus.saved)
              Text(
                '${l10n.notesSaved} ✓',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        // TextFormField keeps the text itself, so no controller is needed.
        TextFormField(
          initialValue: cubit.initialText,
          onChanged: cubit.onChanged,
          minLines: 3,
          maxLines: 8,
          decoration: InputDecoration(hintText: l10n.notesHint),
        ),
      ],
    );
  }
}
