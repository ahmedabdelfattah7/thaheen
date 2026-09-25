import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App preferences: theme, language and the last playback speed.
class SettingsRepository {
  SettingsRepository(this._prefs);

  static const supportedLanguages = ['ar', 'en'];

  static const _themeKey = 'settings.themeMode';
  static const _languageKey = 'settings.language';
  static const _speedKey = 'player.speed';

  final SharedPreferences _prefs;

  ThemeMode get themeMode =>
      ThemeMode.values.asNameMap()[_prefs.getString(_themeKey)] ??
      ThemeMode.system;

  Future<void> setThemeMode(ThemeMode mode) =>
      _prefs.setString(_themeKey, mode.name);

  /// Arabic unless the student picked English.
  Locale get locale {
    final code = _prefs.getString(_languageKey);
    return Locale(supportedLanguages.contains(code) ? code! : 'ar');
  }

  Future<void> setLocale(Locale locale) =>
      _prefs.setString(_languageKey, locale.languageCode);

  double get playbackSpeed => _prefs.getDouble(_speedKey) ?? 1.0;

  Future<void> setPlaybackSpeed(double speed) =>
      _prefs.setDouble(_speedKey, speed);
}
