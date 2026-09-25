enum PlayerStatus { loading, ready, failure }

class PlayerState {
  const PlayerState({
    this.status = PlayerStatus.loading,
    this.speed = 1.0,
    this.isCompleted = false,
    this.isFullscreen = false,
    this.controlsVisible = true,
    this.seekPreview,
  });

  final PlayerStatus status;
  final double speed;

  /// True once the lesson reached 90%, which also unlocks the next lesson.
  final bool isCompleted;

  /// Fullscreen requested with the button (turning the phone also works).
  final bool isFullscreen;

  /// Play/pause, seek bar and buttons shown on top of the video.
  final bool controlsVisible;

  /// Where the seek bar thumb is while the student drags it.
  final Duration? seekPreview;

  PlayerState copyWith({
    PlayerStatus? status,
    double? speed,
    bool? isCompleted,
    bool? isFullscreen,
    bool? controlsVisible,
    Duration? seekPreview,
    bool clearSeekPreview = false,
  }) => PlayerState(
    status: status ?? this.status,
    speed: speed ?? this.speed,
    isCompleted: isCompleted ?? this.isCompleted,
    isFullscreen: isFullscreen ?? this.isFullscreen,
    controlsVisible: controlsVisible ?? this.controlsVisible,
    seekPreview: clearSeekPreview ? null : seekPreview ?? this.seekPreview,
  );
}
