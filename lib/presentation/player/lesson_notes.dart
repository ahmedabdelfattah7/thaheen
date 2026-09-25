import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n/l10n.dart';
import 'notes_cubit.dart';

class LessonNotes extends StatefulWidget {
  const LessonNotes({super.key});

  @override
  State<LessonNotes> createState() => _LessonNotesState();
}

class _LessonNotesState extends State<LessonNotes> {
  late final TextEditingController _text;

  @override
  void initState() {
    super.initState();
    _text = TextEditingController(text: context.read<NotesCubit>().initialText);
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
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
        TextField(
          controller: _text,
          onChanged: context.read<NotesCubit>().onChanged,
          minLines: 3,
          maxLines: 8,
          decoration: InputDecoration(hintText: l10n.notesHint),
        ),
      ],
    );
  }
}
