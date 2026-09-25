import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/l10n/l10n.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/course_repository.dart';
import 'data/notes_repository.dart';
import 'data/progress_repository.dart';
import 'data/settings_repository.dart';
import 'presentation/courses/courses_cubit.dart';
import 'presentation/settings/settings_cubit.dart';

class ThaheenApp extends StatefulWidget {
  const ThaheenApp({
    super.key,
    required this.courseRepository,
    required this.progressRepository,
    required this.notesRepository,
    required this.settingsRepository,
  });

  final CourseRepository courseRepository;
  final ProgressRepository progressRepository;
  final NotesRepository notesRepository;
  final SettingsRepository settingsRepository;

  @override
  State<ThaheenApp> createState() => _ThaheenAppState();
}

class _ThaheenAppState extends State<ThaheenApp> {
  // Created once, so switching theme or language keeps the navigation stack.
  final _router = createRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: widget.courseRepository),
        RepositoryProvider.value(value: widget.progressRepository),
        RepositoryProvider.value(value: widget.notesRepository),
        RepositoryProvider.value(value: widget.settingsRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => SettingsCubit(widget.settingsRepository)),
          BlocProvider(
            create: (_) =>
                CoursesCubit(widget.courseRepository, widget.progressRepository)
                  ..load(),
          ),
        ],
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settings) => MaterialApp.router(
            routerConfig: _router,
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
