import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n/l10n.dart';
import '../../core/widgets/empty_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../settings/settings_cubit.dart';
import 'courses_cubit.dart';
import 'courses_list.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = context.read<SettingsCubit>();
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myCourses),
        actions: [
          TextButton(
            onPressed: settings.toggleLanguage,
            child: Text(l10n.switchLanguage),
          ),
          IconButton(
            tooltip: l10n.toggleTheme,
            onPressed: () => settings.toggleTheme(brightness),
            icon: Icon(
              brightness == Brightness.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
        ],
      ),
      body: BlocBuilder<CoursesCubit, CoursesState>(
        builder: (context, state) => switch (state.status) {
          CoursesStatus.loading => const LoadingView(),
          CoursesStatus.failure => ErrorView(
            message: l10n.loadCoursesError,
            onRetry: context.read<CoursesCubit>().load,
          ),
          CoursesStatus.loaded when state.courses.isEmpty => EmptyView(
            message: l10n.noCourses,
          ),
          CoursesStatus.loaded => CoursesList(state: state),
        },
      ),
    );
  }
}
