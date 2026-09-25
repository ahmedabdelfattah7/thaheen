import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Replaces Flutter's red error screen (see `ErrorWidget.builder` in main).
/// It is built without a BuildContext above it, so the text is static,
/// bilingual and carries its own direction and style.
class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({super.key, required this.details});

  final FlutterErrorDetails details;

  @override
  Widget build(BuildContext context) {
    final debugInfo = kDebugMode ? '\n\n${details.exceptionAsString()}' : '';
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'حدث خطأ غير متوقع\nSomething went wrong$debugInfo',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
