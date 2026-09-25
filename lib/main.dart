import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/course_repository.dart';
import 'data/notes_repository.dart';
import 'data/progress_repository.dart';
import 'data/settings_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorWidget.builder = _friendlyErrorWidget;
  // Only the lesson player rotates (for fullscreen).
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final prefs = await SharedPreferences.getInstance();
  runApp(
    ThaheenApp(
      courseRepository: CourseRepository(),
      progressRepository: ProgressRepository(prefs),
      notesRepository: NotesRepository(prefs),
      settingsRepository: SettingsRepository(prefs),
    ),
  );
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
