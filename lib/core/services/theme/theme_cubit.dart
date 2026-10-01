import 'package:starter_app/core/cubit/safe_cubit.dart';
import 'package:flutter/material.dart';

import '../../data/constants/shared_preferences_constants.dart';
import '../local_storage/shared_preference/shared_preference_service.dart';

class ThemeCubit extends SafeCubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light) {
    _loadTheme();
  }

  void _loadTheme() {
    final isDark = SharedPreferenceService().getBool(
      SharPrefConstants.isDarkThemeKey,
    );
    emit(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleTheme() {
    final newTheme = state == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    SharedPreferenceService().setBool(
      SharPrefConstants.isDarkThemeKey,
      newTheme == ThemeMode.dark,
    );
    emit(newTheme);
  }
}
