import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/empty_view.dart';
import 'continue_watching_card.dart';
import 'course_card.dart';
import 'courses_cubit.dart';

/// Search field, "Continue watching" card and the course cards.
class CoursesList extends StatelessWidget {
  const CoursesList({super.key, required this.state});

  final CoursesState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final courses = state.visibleCourses;
    final continueItem = state.continueWatching;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  message: l10n.noSearchResults(
                    bidiIsolate(state.query.trim()),
                  ),
                )
              : ListView(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 24),
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
                        progress: state.progressOf(course),
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
