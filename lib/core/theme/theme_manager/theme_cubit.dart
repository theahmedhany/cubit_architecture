import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cache/shared_pref_helper.dart';
import '../../localization/locale_keys.g.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const String themeKey = 'app_theme_mode';

  static const ThemeMode _defaultTheme = ThemeMode.light;

  ThemeCubit() : super(_defaultTheme) {
    unawaited(_loadSavedTheme());
  }

  // Load saved theme safely
  Future<void> _loadSavedTheme() async {
    final savedMode = SharedPrefHelper.getInt(
      key: themeKey,
      defaultValue: _defaultTheme.index,
    );

    final savedThemeIndex = savedMode;

    final isValidIndex =
        savedThemeIndex >= 0 && savedThemeIndex < ThemeMode.values.length;

    if (!isValidIndex) return;

    _safeEmit(ThemeMode.values[savedThemeIndex]);
  }

  // Update theme and persist it
  Future<void> updateTheme(ThemeMode newMode) async {
    await SharedPrefHelper.setData(key: themeKey, value: newMode.index);

    _safeEmit(newMode);
  }

  // Toggle between light & dark
  Future<void> toggleTheme() async {
    bool isCurrentlyDark = false;

    if (state == ThemeMode.dark) {
      isCurrentlyDark = true;
    } else if (state == ThemeMode.system &&
        PlatformDispatcher.instance.platformBrightness == Brightness.dark) {
      isCurrentlyDark = true;
    }

    ThemeMode newMode;

    if (isCurrentlyDark) {
      newMode = ThemeMode.light;
    } else {
      newMode = ThemeMode.dark;
    }

    await updateTheme(newMode);
  }

  // Display name
  String get currentThemeName {
    switch (state) {
      case ThemeMode.light:
        return LocaleKeys.themes_light_theme.tr();

      case ThemeMode.dark:
        return LocaleKeys.themes_dark_theme.tr();

      case ThemeMode.system:
        return LocaleKeys.themes_system_theme.tr();
    }
  }

  void _safeEmit(ThemeMode state) {
    if (!isClosed) {
      emit(state);
    }
  }
}
