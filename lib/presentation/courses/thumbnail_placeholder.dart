import 'package:flutter/material.dart';

/// Shown when a course has no thumbnail or the image fails to load.
class ThumbnailPlaceholder extends StatelessWidget {
  const ThumbnailPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colors.secondaryContainer,
      child: Icon(
        Icons.school_outlined,
        size: 40,
        color: colors.onSecondaryContainer,
      ),
    );
  }
}
