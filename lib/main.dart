import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorWidget.builder = _friendlyErrorWidget;
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const ThaheenApp());
}

/// Replaces Flutter's red error screen with a calm message. It has no
/// BuildContext, so the text is static and bilingual.
Widget _friendlyErrorWidget(FlutterErrorDetails details) {
  final debugInfo = kDebugMode ? '\n\n${details.exceptionAsString()}' : '';
  return Directionality(
    textDirection: TextDirection.rtl,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'حدث خطأ غير متوقع\nSomething went wrong$debugInfo',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ),
    ),
  );
}
