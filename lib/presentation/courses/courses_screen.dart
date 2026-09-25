import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/state_views.dart';
import '../../domain/progress_rules.dart';
import '../settings/settings_cubit.dart';
import 'continue_watching_card.dart';
import 'course_card.dart';
import 'courses_cubit.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = context.read<SettingsCubit>();

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
            onPressed: () => settings.toggleTheme(Theme.of(context).brightness),
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
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
          CoursesStatus.loaded => _CourseList(state: state),
        },
      ),
    );
  }
}

class _CourseList extends StatelessWidget {
  const _CourseList({required this.state});

  final CoursesState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final courses = state.visibleCourses;
    final continueItem = state.query.isEmpty
        ? ProgressRules.continueWatching(state.courses, state.progress)
        : null;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            onChanged: context.read<CoursesCubit>().search,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: l10n.searchHint,
              prefixIcon: const Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: courses.isEmpty
              ? EmptyView(
                  icon: Icons.search_off,
                  message: l10n.noSearchResults(state.query.trim()),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    if (continueItem != null) ...[
                      Text(
                        l10n.continueWatching,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ContinueWatchingCard(
                        item: continueItem,
                        onTap: () => context.go(
                          AppRoutes.lesson(
                            continueItem.course.id,
                            continueItem.lesson.id,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    for (final course in courses) ...[
                      CourseCard(
                        course: course,
                        progress: ProgressRules.courseProgress(
                          course,
                          state.progress,
                        ),
                        onTap: () => context.go(AppRoutes.course(course.id)),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}
