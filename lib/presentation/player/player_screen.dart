import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../core/l10n/l10n.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/state_views.dart';
import '../../domain/models/course.dart';
import '../../domain/progress_rules.dart';
import '../courses/courses_cubit.dart';
import 'lesson_notes.dart';
import 'notes_cubit.dart';
import 'player_controls.dart';
import 'player_cubit.dart';

/// The lesson route. It owns orientation/fullscreen, and keys the player by
/// lesson so "Next lesson" always gets a fresh cubit and video controller.
/// (go_router reuses the page when only the lesson id in the URL changes.)
class PlayerScreen extends StatefulWidget {
  const PlayerScreen({
    super.key,
    required this.courseId,
    required this.lessonId,
  });

  final String courseId;
  final String lessonId;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  /// Fullscreen requested with the button (rotating the phone also works).
  bool _forcedFullscreen = false;
  bool? _landscape;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Hide the system bars while the phone is sideways.
    final landscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    if (landscape == _landscape) return;
    _landscape = landscape;
    SystemChrome.setEnabledSystemUIMode(
      landscape ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleFullscreen(bool isFullscreen) {
    setState(() => _forcedFullscreen = !isFullscreen);
    SystemChrome.setPreferredOrientations(
      isFullscreen
          ? const [DeviceOrientation.portraitUp]
          : const [
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<CoursesCubit>().state;
    final course = state.courseById(widget.courseId);
    final lesson = course?.lessonById(widget.lessonId);

    if (state.status == CoursesStatus.loading) {
      return const Scaffold(body: LoadingView());
    }
    if (course == null || lesson == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyView(message: l10n.lessonNotFound),
      );
    }

    final isFullscreen =
        _forcedFullscreen ||
        MediaQuery.orientationOf(context) == Orientation.landscape;

    return MultiBlocProvider(
      key: ValueKey('${course.id}/${lesson.id}'),
      providers: [
        BlocProvider(
          create: (context) => PlayerCubit(
            courseId: course.id,
            lesson: lesson,
            progress: context.read(),
            settings: context.read(),
          )..load(),
        ),
        BlocProvider(
          create: (context) => NotesCubit(
            courseId: course.id,
            lessonId: lesson.id,
            repository: context.read(),
          ),
        ),
      ],
      child: _LessonPlayer(
        course: course,
        lesson: lesson,
        isFullscreen: isFullscreen,
        onToggleFullscreen: () => _toggleFullscreen(isFullscreen),
      ),
    );
  }
}

class _LessonPlayer extends StatelessWidget {
  const _LessonPlayer({
    required this.course,
    required this.lesson,
    required this.isFullscreen,
    required this.onToggleFullscreen,
  });

  final Course course;
  final Lesson lesson;
  final bool isFullscreen;
  final VoidCallback onToggleFullscreen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final status = context.select((PlayerCubit c) => c.state.status);
    final video = _VideoArea(
      isFullscreen: isFullscreen,
      onToggleFullscreen: onToggleFullscreen,
    );

    return BlocListener<PlayerCubit, PlayerState>(
      listenWhen: (previous, current) =>
          !previous.isCompleted && current.isCompleted,
      listener: (context, state) => ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('${l10n.lessonCompleted} ✓'))),
      child: isFullscreen
          ? Scaffold(
              backgroundColor: status == PlayerStatus.failure
                  ? null
                  : Colors.black,
              body: SafeArea(child: video),
            )
          : Scaffold(
              appBar: AppBar(title: Text(lesson.title)),
              body: ListView(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ColoredBox(
                      color: status == PlayerStatus.failure
                          ? Colors.transparent
                          : Colors.black,
                      child: video,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          lesson.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          course.title,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        _NextLessonButton(course: course, lesson: lesson),
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

class _VideoArea extends StatelessWidget {
  const _VideoArea({
    required this.isFullscreen,
    required this.onToggleFullscreen,
  });

  final bool isFullscreen;
  final VoidCallback onToggleFullscreen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<PlayerCubit>();
    final status = context.select((PlayerCubit c) => c.state.status);
    final controller = cubit.controller;

    return switch (status) {
      PlayerStatus.loading => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
      PlayerStatus.failure => ErrorView(
        message: l10n.videoError,
        details: l10n.videoErrorHint,
        onRetry: cubit.retry,
      ),
      PlayerStatus.ready when controller != null => Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
          ),
          Positioned.fill(
            child: PlayerControls(
              controller: controller,
              isFullscreen: isFullscreen,
              onToggleFullscreen: onToggleFullscreen,
            ),
          ),
        ],
      ),
      PlayerStatus.ready => const SizedBox.shrink(),
    };
  }
}

/// Opens the next lesson, but only once this one is completed (which is
/// exactly what unlocks the next lesson).
class _NextLessonButton extends StatelessWidget {
  const _NextLessonButton({required this.course, required this.lesson});

  final Course course;
  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final isCompleted = context.select((PlayerCubit c) => c.state.isCompleted);
    final next = ProgressRules.nextLesson(course, lesson.id);

    if (next == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.lastLesson, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => context.go(AppRoutes.course(course.id)),
            icon: const Icon(Icons.flag_outlined),
            label: Text(l10n.backToCourse),
          ),
        ],
      );
    }

    return FilledButton.icon(
      onPressed: isCompleted
          ? () => context.go(AppRoutes.lesson(course.id, next.id))
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
      label: Text('${l10n.nextLesson}: ${bidiIsolate(next.title)}'),
    );
  }
}
