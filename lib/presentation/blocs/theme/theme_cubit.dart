import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final SharedPreferences sharedPreferences;
  static const String _themeKey = 'THEME_MODE';

  ThemeCubit({required this.sharedPreferences}) : super(ThemeMode.dark);

  void toggleTheme() {
    // Dark mode only
  }

  void setTheme(ThemeMode mode) {
    // Dark mode only
  }

  bool get isDarkMode => true;
}
