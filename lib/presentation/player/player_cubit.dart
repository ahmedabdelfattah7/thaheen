import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import '../../data/progress_repository.dart';
import '../../data/settings_repository.dart';
import '../../domain/models/course.dart';
import '../../domain/models/lesson_progress.dart';
import '../../domain/progress_rules.dart';
import 'player_state.dart';

export 'player_state.dart';

/// Plays one lesson and owns everything the player screen shows: loading and
/// errors, speed, completion, fullscreen and the on-screen controls.
///
/// The fast-changing position is read straight from [controller] by the seek
/// bar; this cubit only emits coarse changes.
class PlayerCubit extends Cubit<PlayerState> {
  PlayerCubit({
    required this.course,
    required this.lesson,
    required ProgressRepository progress,
    required SettingsRepository settings,
  }) : _progress = progress,
       _settings = settings,
       nextLesson = ProgressRules.nextLesson(course, lesson.id),
       super(
         PlayerState(
           speed: speeds.contains(settings.playbackSpeed)
               ? settings.playbackSpeed
               : 1.0,
           isCompleted:
               progress.get(course.id, lesson.id)?.isCompleted ?? false,
         ),
       );

  static const speeds = [1.0, 1.25, 1.5, 2.0];

  /// A crash or kill loses at most this much watching time.
  static const _saveEvery = Duration(seconds: 5);
  static const _loadTimeout = Duration(seconds: 15);
  static const _controlsTimeout = Duration(seconds: 3);

  final Course course;
  final Lesson lesson;

  /// The lesson after this one, or null for the last lesson of the course.
  final Lesson? nextLesson;
  final ProgressRepository _progress;
  final SettingsRepository _settings;

  VideoPlayerController? _controller;
  VideoPlayerController? get controller => _controller;

  // Last position/length from a healthy player. Errors reset the controller
  // value to zero, so saves always use these instead.
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Duration _savedPosition = Duration.zero;
  bool _wasPlaying = false;
  Timer? _hideControlsTimer;

  Future<void> load() async {
    emit(state.copyWith(status: PlayerStatus.loading));
    final controller = VideoPlayerController.asset(lesson.video);
    _controller = controller;
    try {
      await controller.initialize().timeout(_loadTimeout);
    } catch (error, stackTrace) {
      // Missing or corrupt file, or an unsupported format.
      _disposeController();
      if (isClosed) return;
      addError(error, stackTrace);
      emit(state.copyWith(status: PlayerStatus.failure));
      return;
    }
    if (isClosed) return;

    _duration = controller.value.duration;
    _position = ProgressRules.resumePosition(
      _progress.get(course.id, lesson.id),
      _duration,
    );
    _savedPosition = _position;
    await controller.seekTo(_position);
    if (isClosed) return;
    await controller.setPlaybackSpeed(state.speed);
    if (isClosed) return;

    controller.addListener(_onPlayerUpdate);
    emit(state.copyWith(status: PlayerStatus.ready));
    await controller.play();
  }

  Future<void> retry() {
    _disposeController();
    return load();
  }

  Future<void> togglePlay() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    controller.value.isPlaying
        ? await controller.pause()
        : await controller.play();
  }

  /// Moves the seek bar thumb while the student drags it.
  void previewSeek(Duration position) {
    _hideControlsTimer?.cancel();
    emit(state.copyWith(seekPreview: position));
  }

  Future<void> seekTo(Duration position) async {
    await _controller?.seekTo(position);
    if (isClosed) return;
    emit(state.copyWith(clearSeekPreview: true));
    _scheduleHideControls();
  }

  Future<void> setSpeed(double speed) async {
    emit(state.copyWith(speed: speed));
    _scheduleHideControls();
    await _controller?.setPlaybackSpeed(speed);
    await _settings.setPlaybackSpeed(speed);
  }

  /// The fullscreen button forces landscape and hides the system bars.
  /// Turning the phone sideways also shows the fullscreen layout.
  Future<void> setFullscreen(bool fullscreen) async {
    emit(state.copyWith(isFullscreen: fullscreen));
    await SystemChrome.setPreferredOrientations(
      fullscreen
          ? const [
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]
          : const [DeviceOrientation.portraitUp],
    );
    await SystemChrome.setEnabledSystemUIMode(
      fullscreen ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
  }

  /// Tapping the video shows or hides the controls.
  void toggleControls() {
    final visible = !state.controlsVisible;
    emit(state.copyWith(controlsVisible: visible));
    if (visible) _scheduleHideControls();
  }

  /// Controls fade out after a few seconds, but only while playing.
  void _scheduleHideControls() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(_controlsTimeout, () {
      final playing = _controller?.value.isPlaying ?? false;
      if (!isClosed && playing) emit(state.copyWith(controlsVisible: false));
    });
  }

  void _onPlayerUpdate() {
    final value = _controller?.value;
    if (value == null || isClosed) return;

    if (value.hasError) {
      addError(value.errorDescription ?? 'Playback error', StackTrace.current);
      _controller?.removeListener(_onPlayerUpdate);
      unawaited(_saveProgress());
      emit(state.copyWith(status: PlayerStatus.failure));
      return;
    }
    if (!value.isInitialized) return;

    _position = value.position;
    _duration = value.duration;

    if (value.isPlaying != _wasPlaying) {
      _wasPlaying = value.isPlaying;
      if (value.isPlaying) {
        _scheduleHideControls();
      } else {
        // Paused or finished: keep the controls on screen and save.
        emit(state.copyWith(controlsVisible: true));
        unawaited(_saveProgress());
      }
    }

    if (!state.isCompleted && ProgressRules.isCompleted(_position, _duration)) {
      emit(state.copyWith(isCompleted: true));
      unawaited(_saveProgress());
    } else if ((_position - _savedPosition).abs() >= _saveEvery) {
      unawaited(_saveProgress());
    }
  }

  Future<void> _saveProgress() async {
    // Nothing to save until a video has actually loaded.
    if (_duration <= Duration.zero) return;
    // Opening a lesson without watching it does not start it.
    final existing = _progress.get(course.id, lesson.id);
    if (_position <= Duration.zero && existing == null) return;

    _savedPosition = _position;
    await _progress.save(
      LessonProgress(
        courseId: course.id,
        lessonId: lesson.id,
        position: _position,
        duration: _duration,
        isCompleted: state.isCompleted,
        updatedAt: DateTime.now(),
      ),
    );
  }

  void _disposeController() {
    final controller = _controller;
    _controller = null;
    if (controller == null) return;
    controller.removeListener(_onPlayerUpdate);
    // Not awaited: dispose never completes if the platform failed to create
    // the player (e.g. a missing asset on iOS).
    unawaited(controller.dispose());
  }

  @override
  Future<void> close() async {
    _hideControlsTimer?.cancel();
    _disposeController();
    // Undo what the fullscreen button changed.
    unawaited(SystemChrome.setPreferredOrientations(const []));
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
    await _saveProgress();
    return super.close();
  }
}
