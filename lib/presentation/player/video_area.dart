import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import '../../core/l10n/l10n.dart';
import '../../core/widgets/error_view.dart';
import 'player_controls.dart';
import 'player_cubit.dart';

/// The video with its controls, or a loading/error state in its place.
class VideoArea extends StatelessWidget {
  const VideoArea({super.key, required this.isFullscreen});

  final bool isFullscreen;

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
            ),
          ),
        ],
      ),
      PlayerStatus.ready => const SizedBox.shrink(),
    };
  }
}
