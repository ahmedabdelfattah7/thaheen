import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/l10n/l10n.dart';
import 'core/theme/app_theme.dart';
import 'data/course_repository.dart';
import 'data/notes_repository.dart';
import 'data/progress_repository.dart';
import 'data/settings_repository.dart';
import 'presentation/courses/courses_cubit.dart';
import 'presentation/settings/settings_cubit.dart';

class ThaheenApp extends StatelessWidget {
  const ThaheenApp({
    super.key,
    required this.router,
    required this.courseRepository,
    required this.progressRepository,
    required this.notesRepository,
    required this.settingsRepository,
  });

  /// Created once by the caller, so switching theme or language keeps the
  /// navigation stack.
  final GoRouter router;
  final CourseRepository courseRepository;
  final ProgressRepository progressRepository;
  final NotesRepository notesRepository;
  final SettingsRepository settingsRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: progressRepository),
        RepositoryProvider.value(value: notesRepository),
        RepositoryProvider.value(value: settingsRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => SettingsCubit(settingsRepository)),
          BlocProvider(
            create: (_) =>
                CoursesCubit(courseRepository, progressRepository)..load(),
          ),
        ],
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settings) => MaterialApp.router(
            routerConfig: router,
            debugShowCheckedModeBanner: false,
            onGenerateTitle: (context) => context.l10n.appTitle,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: settings.themeMode,
            locale: settings.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
          ),
        ),
      ),
    );
  }
}
