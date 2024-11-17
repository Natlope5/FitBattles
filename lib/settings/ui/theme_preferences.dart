import 'package:fitbattles/settings/ui/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_strings.dart'; // Import the strings file

class ThemePreferences {
  Future<MyAppTheme> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(AppStrings.appThemeKey) ?? AppStrings.defaultTheme; // Default to light theme
    return AppThemeExtension.fromKey(themeString); // Use fromKey method from extension
  }

  Future<void> saveTheme(MyAppTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppStrings.appThemeKey, theme.toKey()); // Call toKey() on the AppTheme instance
  }
}
