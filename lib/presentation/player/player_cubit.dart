import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import '../../data/progress_repository.dart';
import '../../data/settings_repository.dart';
import '../../domain/models/course.dart';
import '../../domain/models/lesson_progress.dart';
import '../../domain/progress_rules.dart';

enum PlayerStatus { loading, ready, failure }

class PlayerState {
  const PlayerState({
    this.status = PlayerStatus.loading,
    this.speed = 1.0,
    this.isCompleted = false,
  });

  final PlayerStatus status;
  final double speed;

  /// True once the lesson reached 90%, which also unlocks the next lesson.
  final bool isCompleted;

  PlayerState copyWith({
    PlayerStatus? status,
    double? speed,
    bool? isCompleted,
  }) => PlayerState(
    status: status ?? this.status,
    speed: speed ?? this.speed,
    isCompleted: isCompleted ?? this.isCompleted,
  );
}

/// Plays one lesson and records how far the student got.
///
/// The UI reads the fast-changing position straight from [controller]; this
/// cubit only emits coarse changes (loading/ready/failure, speed, completion).
class PlayerCubit extends Cubit<PlayerState> {
  PlayerCubit({
    required this.courseId,
    required this.lesson,
    required ProgressRepository progress,
    required SettingsRepository settings,
  }) : _progress = progress,
       _settings = settings,
       super(
         PlayerState(
           speed: speeds.contains(settings.playbackSpeed)
               ? settings.playbackSpeed
               : 1.0,
           isCompleted: progress.get(courseId, lesson.id)?.isCompleted ?? false,
         ),
       );

  static const speeds = [1.0, 1.25, 1.5, 2.0];

  /// A crash or kill loses at most this much watching time.
  static const _saveEvery = Duration(seconds: 5);
  static const _loadTimeout = Duration(seconds: 15);

  final String courseId;
  final Lesson lesson;
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

  Future<void> load() async {
    emit(state.copyWith(status: PlayerStatus.loading));
    final controller = VideoPlayerController.asset(lesson.video);
    _controller = controller;
    try {
      await controller.initialize().timeout(_loadTimeout);
    } catch (error) {
      // Missing or corrupt file, or an unsupported format.
      debugPrint('Could not open ${lesson.video}: $error');
      _disposeController();
      if (!isClosed) emit(state.copyWith(status: PlayerStatus.failure));
      return;
    }
    if (isClosed) return;

    _duration = controller.value.duration;
    _position = ProgressRules.resumePosition(
      _progress.get(courseId, lesson.id),
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

  Future<void> seekTo(Duration position) async => _controller?.seekTo(position);

  Future<void> setSpeed(double speed) async {
    emit(state.copyWith(speed: speed));
    await _controller?.setPlaybackSpeed(speed);
    await _settings.setPlaybackSpeed(speed);
  }

  void _onPlayerUpdate() {
    final value = _controller?.value;
    if (value == null || isClosed) return;

    if (value.hasError) {
      debugPrint('Playback error: ${value.errorDescription}');
      _controller?.removeListener(_onPlayerUpdate);
      unawaited(_saveProgress());
      emit(state.copyWith(status: PlayerStatus.failure));
      return;
    }
    if (!value.isInitialized) return;

    _position = value.position;
    _duration = value.duration;
    final justPaused = _wasPlaying && !value.isPlaying;
    _wasPlaying = value.isPlaying;

    if (!state.isCompleted && ProgressRules.isCompleted(_position, _duration)) {
      emit(state.copyWith(isCompleted: true));
      unawaited(_saveProgress());
    } else if (justPaused || (_position - _savedPosition).abs() >= _saveEvery) {
      unawaited(_saveProgress());
    }
  }

  Future<void> _saveProgress() async {
    // Nothing to save until a video has actually loaded.
    if (_duration <= Duration.zero) return;
    // Opening a lesson without watching it does not start it.
    final existing = _progress.get(courseId, lesson.id);
    if (_position <= Duration.zero && existing == null) return;

    _savedPosition = _position;
    await _progress.save(
      LessonProgress(
        courseId: courseId,
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
    _disposeController();
    await _saveProgress();
    return super.close();
  }
}
