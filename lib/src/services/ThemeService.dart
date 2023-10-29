import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const THEME_MODE_KEY = 'theme_mode';
  ThemeMode _themeMode;

  ThemeService(this._themeMode);

  // Fetch the theme mode from shared preferences on initialization
  static Future<ThemeService> init() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(THEME_MODE_KEY) ?? false;
    return ThemeService(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  getThemeMode() => _themeMode;

  setThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;
    await _persistThemeMode();
    notifyListeners();
  }

  Future<void> _persistThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(THEME_MODE_KEY, _themeMode == ThemeMode.dark);
  }
}
