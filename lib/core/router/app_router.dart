import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/course_details/course_details_screen.dart';
import '../../presentation/courses/courses_screen.dart';
import '../../presentation/player/player_screen.dart';
import '../l10n/l10n.dart';
import '../widgets/empty_view.dart';

abstract final class AppRoutes {
  static String course(String courseId) => '/courses/$courseId';

  static String lesson(String courseId, String lessonId) =>
      '/courses/$courseId/lessons/$lessonId';
}

GoRouter createRouter() => GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const CoursesScreen(),
      routes: [
        GoRoute(
          path: 'courses/:courseId',
          builder: (context, state) =>
              CourseDetailsScreen(courseId: state.pathParameters['courseId']!),
          routes: [
            GoRoute(
              path: 'lessons/:lessonId',
              builder: (context, state) => PlayerScreen(
                courseId: state.pathParameters['courseId']!,
                lessonId: state.pathParameters['lessonId']!,
              ),
            ),
          ],
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(),
    body: EmptyView(message: context.l10n.courseNotFound),
  ),
);
