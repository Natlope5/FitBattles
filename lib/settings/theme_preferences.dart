// lib/settings/theme_preferences.dart
import 'package:fitbattles/settings/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferences {
  static const String _themeKey = 'appTheme';

  Future<MyAppTheme> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_themeKey) ?? MyAppTheme.light.toKey(); // Default to light theme
    return AppThemeExtension.fromKey(themeString); // Use fromKey method from extension
  }

  Future<void> saveTheme(MyAppTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme.toKey()); // Call toKey() on the AppTheme instance
  }
}
