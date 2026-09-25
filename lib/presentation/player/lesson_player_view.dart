import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n/l10n.dart';
import '../../domain/models/course.dart';
import 'lesson_notes.dart';
import 'next_lesson_button.dart';
import 'player_cubit.dart';
import 'video_area.dart';

/// Portrait: video on top, then lesson info, "Next lesson" and notes.
/// Fullscreen (button or phone turned sideways): only the video.
class LessonPlayerView extends StatelessWidget {
  const LessonPlayerView({
    super.key,
    required this.course,
    required this.lesson,
  });

  final Course course;
  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = l10n.localeName;
    final theme = Theme.of(context);
    final failed = context.select(
      (PlayerCubit c) => c.state.status == PlayerStatus.failure,
    );
    final isFullscreen =
        context.select((PlayerCubit c) => c.state.isFullscreen) ||
        MediaQuery.orientationOf(context) == Orientation.landscape;
    final video = VideoArea(isFullscreen: isFullscreen);

    return BlocListener<PlayerCubit, PlayerState>(
      listenWhen: (previous, current) =>
          !previous.isCompleted && current.isCompleted,
      listener: (context, state) => ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('${l10n.lessonCompleted} ✓'))),
      child: isFullscreen
          ? Scaffold(
              backgroundColor: failed ? null : Colors.black,
              body: SafeArea(child: video),
            )
          : Scaffold(
              appBar: AppBar(title: Text(lesson.title.of(lang))),
              body: ListView(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ColoredBox(
                      color: failed ? Colors.transparent : Colors.black,
                      child: video,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          lesson.title.of(lang),
                          style: theme.textTheme.titleLarge,
                        ),
                        Text(
                          course.title.of(lang),
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        const NextLessonButton(),
                        const SizedBox(height: 24),
                        const LessonNotes(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
