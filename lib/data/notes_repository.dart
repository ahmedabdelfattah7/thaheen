import 'package:shared_preferences/shared_preferences.dart';

/// One private note per lesson, stored on the device.
class NotesRepository {
  NotesRepository(this._prefs);

  final SharedPreferences _prefs;

  static String _key(String courseId, String lessonId) =>
      'notes.$courseId/$lessonId';

  String getNote(String courseId, String lessonId) =>
      _prefs.getString(_key(courseId, lessonId)) ?? '';

  Future<void> saveNote(String courseId, String lessonId, String text) {
    final key = _key(courseId, lessonId);
    return text.trim().isEmpty
        ? _prefs.remove(key)
        : _prefs.setString(key, text);
  }
}
