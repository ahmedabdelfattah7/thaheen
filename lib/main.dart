import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/bloc/app_bloc_observer.dart';
import 'core/router/app_router.dart';
import 'core/widgets/app_error_widget.dart';
import 'data/course_repository.dart';
import 'data/notes_repository.dart';
import 'data/progress_repository.dart';
import 'data/settings_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // No red error screens: unexpected build errors show a calm message.
  ErrorWidget.builder = (details) => AppErrorWidget(details: details);
  Bloc.observer = const AppBlocObserver();

  final prefs = await SharedPreferences.getInstance();
  runApp(
    ThaheenApp(
      router: createRouter(),
      courseRepository: CourseRepository(),
      progressRepository: ProgressRepository(prefs),
      notesRepository: NotesRepository(prefs),
      settingsRepository: SettingsRepository(prefs),
    ),
  );
}
