import 'package:flutter/material.dart';

import 'thumbnail_placeholder.dart';

/// Course image with a neutral placeholder when it is missing or broken.
class CourseThumbnail extends StatelessWidget {
  const CourseThumbnail({super.key, required this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    final path = this.path;
    if (path == null) return const ThumbnailPlaceholder();
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const ThumbnailPlaceholder(),
    );
  }
}
