import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import '../../core/l10n/l10n.dart';
import 'player_cubit.dart';
import 'seek_bar.dart';
import 'speed_button.dart';

/// Overlay on top of the video: play/pause, seek bar, speed and fullscreen.
/// Tapping the video shows or hides it; the cubit hides it while playing.
class PlayerControls extends StatelessWidget {
  const PlayerControls({
    super.key,
    required this.controller,
    required this.isFullscreen,
  });

  final VideoPlayerController controller;
  final bool isFullscreen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<PlayerCubit>();
    final visible = context.select((PlayerCubit c) => c.state.controlsVisible);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: cubit.toggleControls,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: IgnorePointer(
          ignoring: !visible,
          child: ColoredBox(
            color: Colors.black38,
            child: IconTheme(
              data: const IconThemeData(color: Colors.white),
              child: Stack(
                children: [
                  Center(
                    child: ValueListenableBuilder(
                      valueListenable: controller,
                      builder: (context, value, _) => IconButton(
                        iconSize: 64,
                        tooltip: value.isPlaying ? l10n.pause : l10n.play,
                        // Media glyphs are never mirrored, even in RTL.
                        icon: Icon(
                          value.isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                        ),
                        onPressed: cubit.togglePlay,
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    start: 8,
                    end: 8,
                    bottom: 0,
                    child: Row(
                      children: [
                        Expanded(child: SeekBar(controller: controller)),
                        const SpeedButton(),
                        IconButton(
                          tooltip: isFullscreen
                              ? l10n.exitFullscreen
                              : l10n.enterFullscreen,
                          icon: Icon(
                            isFullscreen
                                ? Icons.fullscreen_exit
                                : Icons.fullscreen,
                          ),
                          onPressed: () => cubit.setFullscreen(!isFullscreen),
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
