import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import '../../core/l10n/l10n.dart';
import '../../core/utils/formatters.dart';
import 'player_cubit.dart';

/// Overlay on top of the video: play/pause, seek bar, speed and fullscreen.
/// Tap the video to show or hide it; it hides itself while playing.
class PlayerControls extends StatefulWidget {
  const PlayerControls({
    super.key,
    required this.controller,
    required this.isFullscreen,
    required this.onToggleFullscreen,
  });

  final VideoPlayerController controller;
  final bool isFullscreen;
  final VoidCallback onToggleFullscreen;

  @override
  State<PlayerControls> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends State<PlayerControls> {
  bool _visible = true;
  bool _isPlaying = false;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onPlayingChanged);
    _scheduleHide();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onPlayingChanged);
    _hideTimer?.cancel();
    super.dispose();
  }

  /// Controls stay on screen whenever the video is paused or finished.
  void _onPlayingChanged() {
    final isPlaying = widget.controller.value.isPlaying;
    if (isPlaying == _isPlaying) return;
    setState(() {
      _isPlaying = isPlaying;
      if (!isPlaying) _visible = true;
    });
    if (isPlaying) _scheduleHide();
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && widget.controller.value.isPlaying) {
        setState(() => _visible = false);
      }
    });
  }

  void _toggleVisible() {
    setState(() => _visible = !_visible);
    if (_visible) _scheduleHide();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<PlayerCubit>();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggleVisible,
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: IgnorePointer(
          ignoring: !_visible,
          child: ColoredBox(
            color: Colors.black38,
            child: IconTheme(
              data: const IconThemeData(color: Colors.white),
              child: Stack(
                children: [
                  Center(
                    child: ValueListenableBuilder(
                      valueListenable: widget.controller,
                      builder: (context, value, _) => IconButton(
                        iconSize: 64,
                        tooltip: value.isPlaying ? l10n.pause : l10n.play,
                        // Media glyphs are never mirrored, even in RTL.
                        icon: Icon(
                          value.isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                        ),
                        onPressed: () {
                          cubit.togglePlay();
                          _scheduleHide();
                        },
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    start: 8,
                    end: 8,
                    bottom: 0,
                    child: Row(
                      children: [
                        Expanded(
                          child: _SeekBar(
                            controller: widget.controller,
                            onSeek: (position) {
                              cubit.seekTo(position);
                              _scheduleHide();
                            },
                          ),
                        ),
                        _SpeedButton(onSelected: _scheduleHide),
                        IconButton(
                          tooltip: widget.isFullscreen
                              ? l10n.exitFullscreen
                              : l10n.enterFullscreen,
                          icon: Icon(
                            widget.isFullscreen
                                ? Icons.fullscreen_exit
                                : Icons.fullscreen,
                          ),
                          onPressed: widget.onToggleFullscreen,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// `current ━━━●──── total`. Slider follows the text direction, so in Arabic
/// the bar fills right-to-left and dragging works the same way.
class _SeekBar extends StatefulWidget {
  const _SeekBar({required this.controller, required this.onSeek});

  final VideoPlayerController controller;
  final ValueChanged<Duration> onSeek;

  @override
  State<_SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<_SeekBar> {
  /// Position under the finger while dragging, so the thumb doesn't jump.
  double? _dragMs;

  @override
  Widget build(BuildContext context) {
    const timeStyle = TextStyle(color: Colors.white, fontSize: 12);
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (context, value, _) {
        final maxMs = math.max(value.duration.inMilliseconds, 1).toDouble();
        final positionMs = (_dragMs ?? value.position.inMilliseconds.toDouble())
            .clamp(0.0, maxMs);
        return Row(
          children: [
            Text(
              formatDuration(Duration(milliseconds: positionMs.round())),
              style: timeStyle,
            ),
            Expanded(
              child: Slider(
                value: positionMs,
                max: maxMs,
                activeColor: Colors.white,
                inactiveColor: Colors.white30,
                onChangeStart: (v) => setState(() => _dragMs = v),
                onChanged: (v) => setState(() => _dragMs = v),
                onChangeEnd: (v) {
                  widget.onSeek(Duration(milliseconds: v.round()));
                  setState(() => _dragMs = null);
                },
              ),
            ),
            Text(formatDuration(value.duration), style: timeStyle),
          ],
        );
      },
    );
  }
}

class _SpeedButton extends StatelessWidget {
  const _SpeedButton({required this.onSelected});

  final VoidCallback onSelected;

  static String _label(double speed) =>
      '${speed == speed.roundToDouble() ? speed.toInt() : speed}x';

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PlayerCubit>();
    final speed = context.select((PlayerCubit c) => c.state.speed);
    return PopupMenuButton<double>(
      tooltip: context.l10n.playbackSpeed,
      initialValue: speed,
      onSelected: (value) {
        cubit.setSpeed(value);
        onSelected();
      },
      itemBuilder: (context) => [
        for (final option in PlayerCubit.speeds)
          CheckedPopupMenuItem(
            value: option,
            checked: option == speed,
            child: Text(_label(option)),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Text(
          _label(speed),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
