import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models/lesson_progress.dart';

/// Stores lesson progress on the device so it survives app restarts.
///
/// All progress is kept in memory and written to SharedPreferences as one
/// small JSON map. [changes] lets screens update as soon as the player saves.
class ProgressRepository {
  ProgressRepository(this._prefs) : _progress = _load(_prefs);

  static const _key = 'progress.v1';

  final SharedPreferences _prefs;
  final Map<String, LessonProgress> _progress;
  final _changes = StreamController<Map<String, LessonProgress>>.broadcast();

  Stream<Map<String, LessonProgress>> get changes => _changes.stream;

  Map<String, LessonProgress> getAll() => Map.unmodifiable(_progress);

  LessonProgress? get(String courseId, String lessonId) =>
      _progress[LessonProgress.keyOf(courseId, lessonId)];

  /// Saves [progress]. Completion is sticky: rewatching a completed lesson
  /// never makes it incomplete again.
  Future<void> save(LessonProgress progress) async {
    final wasCompleted = _progress[progress.key]?.isCompleted ?? false;
    _progress[progress.key] = wasCompleted
        ? progress.copyWith(isCompleted: true)
        : progress;
    _changes.add(getAll());
    await _prefs.setString(
      _key,
      jsonEncode({
        for (final entry in _progress.entries) entry.key: entry.value.toJson(),
      }),
    );
  }

  static Map<String, LessonProgress> _load(SharedPreferences prefs) {
    final raw = prefs.getString(_key);
    if (raw == null) return {};
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return {
        for (final entry in json.entries)
          entry.key: LessonProgress.fromJson(
            entry.value as Map<String, dynamic>,
          ),
      };
    } catch (_) {
      // Corrupt data should not lock the student out of the app.
      return {};
    }
  }
}
