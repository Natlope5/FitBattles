import 'package:flutter/material.dart';

// Enum for the two themes
enum AppTheme { light, dark }

class ThemePreferences {
  static const String key = 'theme';

  // Mock implementation for saving theme preference
  Future<void> saveTheme(AppTheme theme) async {
    // Use shared_preferences or another method to save the theme
  }

  // Mock implementation for loading theme preference
  Future<AppTheme> loadTheme() async {
    // Use shared_preferences or another method to load the theme
    return AppTheme.light; // Default to light theme
  }
}

// The ThemeProvider class handles theme changes and notifying listeners
class ThemeProvider with ChangeNotifier {
  AppTheme _selectedTheme = AppTheme.light; // Initialize with a default value
  final ThemePreferences _themePreferences = ThemePreferences();

  ThemeProvider() {
    _loadTheme(); // Call _loadTheme to set the initial theme
  }

  AppTheme get selectedTheme => _selectedTheme;

  // Check if the current theme is dark
  bool get isDarkMode => _selectedTheme == AppTheme.dark;

  // Load the theme from preferences
  void _loadTheme() async {
    _selectedTheme = await _themePreferences.loadTheme();
    notifyListeners(); // Notify listeners once the theme is loaded
  }

  void toggleTheme() {
    _selectedTheme = _selectedTheme == AppTheme.dark ? AppTheme.light : AppTheme.dark;
    _themePreferences.saveTheme(_selectedTheme);
    notifyListeners();
  }

  ThemeData get currentTheme {
    return _selectedTheme == AppTheme.dark ? _darkTheme : _lightTheme;
  }

  // Dark Theme Data
  ThemeData get _darkTheme => ThemeData(
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF5D6C8A),
      titleTextStyle: TextStyle(color: Colors.white),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: Colors.white),
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF85C83E),
        foregroundColor: Colors.white,
      ),
    ),
  );

  // Light Theme Data
  ThemeData get _lightTheme => ThemeData(
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[200]!,
      titleTextStyle: const TextStyle(color: Colors.black),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: Colors.black),
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF85C83E),
        foregroundColor: Colors.black,
      ),
    ),
  );
}
