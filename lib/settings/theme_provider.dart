import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enum to define the two themes
enum AppTheme { light, dark }

class ThemePreferences {
  static const String _themeKey = 'appTheme';

  // Load the user's preferred theme from shared preferences
  Future<AppTheme> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_themeKey) ?? AppTheme.light.toString();
    return AppTheme.values.firstWhere((e) => e.toString() == themeString, orElse: () => AppTheme.light);
  }

  // Save the user's preferred theme to shared preferences
  Future<void> saveTheme(AppTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme.toString());
  }
}

class ThemeProvider with ChangeNotifier {
  AppTheme _selectedTheme = AppTheme.light;
  final ThemePreferences _themePreferences = ThemePreferences();



  ThemeProvider() {
    _loadTheme();
  }

  AppTheme get selectedTheme => _selectedTheme;
  bool get isDarkMode => _selectedTheme == AppTheme.dark;

  // Load the user's saved theme
  void _loadTheme() async {
    _selectedTheme = await _themePreferences.loadTheme();
    notifyListeners();
  }

  // Toggle between light and dark themes
  void toggleTheme() {
    _selectedTheme = _selectedTheme == AppTheme.dark ? AppTheme.light : AppTheme.dark;
    _themePreferences.saveTheme(_selectedTheme);
    notifyListeners();
  }

  // Return the current theme data based on the selected theme
  ThemeData get currentTheme {
    return _selectedTheme == AppTheme.dark ? _darkTheme : _lightTheme;
  }

  // Dark theme configuration
  ThemeData get _darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF5D6C8A), // Blue tone
      titleTextStyle: TextStyle(color: Colors.white),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: Colors.white),
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      labelLarge: TextStyle(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF85C83E), // Green tone
        foregroundColor: Colors.white,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      hintStyle: TextStyle(color: Colors.white),
    ),
  );

  // Light theme configuration
  ThemeData get _lightTheme => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF5D6C8A), // Blue tone
      titleTextStyle: TextStyle(color: Colors.black),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: Colors.black),
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black),
      labelLarge: TextStyle(color: Colors.black),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF85C83E), // Green tone
        foregroundColor: Colors.white,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      hintStyle: TextStyle(color: Colors.white),
    ),
  );
}
