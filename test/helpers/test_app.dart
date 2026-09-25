import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thaheen/app.dart';
import 'package:thaheen/core/router/app_router.dart';
import 'package:thaheen/data/course_repository.dart';
import 'package:thaheen/data/notes_repository.dart';
import 'package:thaheen/data/progress_repository.dart';
import 'package:thaheen/data/settings_repository.dart';

/// Serves a fixed string as the catalog file.
class FakeBundle extends CachingAssetBundle {
  FakeBundle(this.catalog);

  final String catalog;

  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(Uint8List.fromList(utf8.encode(catalog)));
}

/// Saved progress for one lesson, in the format stored on the device.
Map<String, Object> savedProgress(
  String courseId,
  String lessonId, {
  required int positionMs,
  required int durationMs,
  bool completed = false,
}) => {
  'progress.v1': jsonEncode({
    '$courseId/$lessonId': {
      'courseId': courseId,
      'lessonId': lessonId,
      'positionMs': positionMs,
      'durationMs': durationMs,
      'completed': completed,
      'updatedAt': '2026-09-25T10:00:00.000',
    },
  }),
};

/// Starts the real app on a phone-sized screen with in-memory storage.
/// [prefs] seeds saved data; [bundle] replaces the bundled catalog.
Future<void> pumpThaheenApp(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
  AssetBundle? bundle,
}) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues(prefs);
  final sharedPreferences = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ThaheenApp(
      router: createRouter(),
      courseRepository: CourseRepository(bundle: bundle),
      progressRepository: ProgressRepository(sharedPreferences),
      notesRepository: NotesRepository(sharedPreferences),
      settingsRepository: SettingsRepository(sharedPreferences),
    ),
  );
  await tester.pumpAndSettle();
}
