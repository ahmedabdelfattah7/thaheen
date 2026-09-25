import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n/l10n.dart';
import '../../core/utils/formatters.dart';
import 'player_cubit.dart';

/// Shows the current speed and opens a menu with 1x, 1.25x, 1.5x and 2x.
class SpeedButton extends StatelessWidget {
  const SpeedButton({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PlayerCubit>();
    final speed = context.select((PlayerCubit c) => c.state.speed);

    return PopupMenuButton<double>(
      tooltip: context.l10n.playbackSpeed,
      initialValue: speed,
      onSelected: cubit.setSpeed,
      itemBuilder: (context) => [
        for (final option in PlayerCubit.speeds)
          CheckedPopupMenuItem(
            value: option,
            checked: option == speed,
            child: Text(formatSpeed(option)),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Text(
          formatSpeed(speed),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
