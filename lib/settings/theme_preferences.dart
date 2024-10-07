// settings/theme_preferences.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitbattles/models/theme_model.dart';

class ThemePreferences {
  static const String _themeKey = 'appTheme';

  Future<ThemeModel> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_themeKey) ?? AppTheme.light.toKey(); // Default to light theme
    return ThemeModel(AppThemeExtension.fromKey(themeString)); // Use fromKey method from extension
  }

  Future<void> saveTheme(ThemeModel theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme.theme.toKey()); // Call toKey() on the AppTheme instance
  }
}
