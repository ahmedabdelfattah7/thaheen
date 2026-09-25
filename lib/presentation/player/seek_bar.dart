import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import '../../core/utils/formatters.dart';
import 'player_cubit.dart';

/// `current ━━━●──── total`. Slider follows the text direction, so in Arabic
/// the bar fills right-to-left and dragging works the same way.
class SeekBar extends StatelessWidget {
  const SeekBar({super.key, required this.controller});

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    const timeStyle = TextStyle(color: Colors.white, fontSize: 12);
    final cubit = context.read<PlayerCubit>();
    final preview = context.select((PlayerCubit c) => c.state.seekPreview);

    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, _) {
        final maxMs = math.max(value.duration.inMilliseconds, 1).toDouble();
        final position = preview ?? value.position;
        return Row(
          children: [
            Text(formatDuration(position), style: timeStyle),
            Expanded(
              child: Slider(
                value: position.inMilliseconds.toDouble().clamp(0.0, maxMs),
                max: maxMs,
                activeColor: Colors.white,
                inactiveColor: Colors.white30,
                onChanged: (ms) =>
                    cubit.previewSeek(Duration(milliseconds: ms.round())),
                onChangeEnd: (ms) =>
                    cubit.seekTo(Duration(milliseconds: ms.round())),
              ),
            ),
            Text(formatDuration(value.duration), style: timeStyle),
          ],
        );
      },
    );
  }
}
