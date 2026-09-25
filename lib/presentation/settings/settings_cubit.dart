import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/settings_repository.dart';

typedef SettingsState = ({ThemeMode themeMode, Locale locale});

/// App-wide theme and language. Both are saved on the device.
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._repository)
    : super((themeMode: _repository.themeMode, locale: _repository.locale));

  final SettingsRepository _repository;

  Future<void> toggleLanguage() async {
    final locale = state.locale.languageCode == 'ar'
        ? const Locale('en')
        : const Locale('ar');
    emit((themeMode: state.themeMode, locale: locale));
    await _repository.setLocale(locale);
  }

  /// Switches away from the brightness currently on screen, which may come
  /// from the system setting.
  Future<void> toggleTheme(Brightness current) async {
    final themeMode = current == Brightness.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    emit((themeMode: themeMode, locale: state.locale));
    await _repository.setThemeMode(themeMode);
  }
}
