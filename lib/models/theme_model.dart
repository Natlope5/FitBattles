import 'package:shared_preferences/shared_preferences.dart';

// Enum for app themes
enum AppTheme {
  light, // Light theme
  dark,  // Dark theme
}

// Extension for converting AppTheme to and from a string
extension AppThemeExtension on AppTheme {
  // Converts the enum to a string for saving in SharedPreferences
  String toKey() {
    return toString().split('.').last;
  }

  // Converts a string from SharedPreferences back to AppTheme enum
  static AppTheme fromKey(String key) {
    return AppTheme.values.firstWhere(
          (e) => e.toString().split('.').last == key,
      orElse: () => AppTheme.light,
    );
  }
}

// Model class for theme management
class ThemeModel {
  AppTheme _theme; // Change to a private variable

  ThemeModel(this._theme);

  // Getter for the theme
  AppTheme get theme => _theme;

  // Setter to update the theme
  set theme(AppTheme newTheme) {
    _theme = newTheme;
    saveTheme(); // Save the new theme whenever it's set
  }

  // Method to save the current theme in SharedPreferences
  Future<void> saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_theme', _theme.toKey());
  }

  // Method to load the theme from SharedPreferences
  static Future<ThemeModel> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeKey = prefs.getString('app_theme') ?? AppTheme.light.toKey();
    final theme = AppThemeExtension.fromKey(themeKey);
    return ThemeModel(theme);
  }
}
