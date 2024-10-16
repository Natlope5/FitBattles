import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Enum for the two themes
enum AppTheme { light, dark }

class ThemePreferences {
  static const String _themeKey = 'appTheme';

  // Load theme preference
  Future<AppTheme> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    // Get the stored theme value or default to light theme if not found
    final themeString = prefs.getString(_themeKey) ?? AppTheme.light.toString();
    return AppTheme.values.firstWhere((e) => e.toString() == themeString, orElse: () => AppTheme.light);
  }

  // Save theme preference
  Future<void> saveTheme(AppTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme.toString());
  }
}

// The ThemeProvider class handles theme changes and notifies listeners
class ThemeProvider with ChangeNotifier {
  AppTheme _selectedTheme = AppTheme.light; // Default theme is light
  final ThemePreferences _themePreferences = ThemePreferences();

  ThemeProvider() {
    _loadTheme(); // Load theme preference on initialization
  }

  AppTheme get selectedTheme => _selectedTheme;

  // Check if the current theme is dark
  bool get isDarkMode => _selectedTheme == AppTheme.dark;

  // Load the theme from preferences
  void _loadTheme() async {
    _selectedTheme = await _themePreferences.loadTheme();
    notifyListeners(); // Notify listeners once the theme is loaded
  }

  // Toggle between dark and light themes
  void toggleTheme() {
    _selectedTheme = _selectedTheme == AppTheme.dark ? AppTheme.light : AppTheme.dark;
    _themePreferences.saveTheme(_selectedTheme);
    notifyListeners(); // Notify listeners after theme change
  }

  // Get the current ThemeData based on the selected theme
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
      // Set text to white for other widgets like Dropdown, TextFields, etc.
      labelLarge: TextStyle(color: Colors.white), // For dropdown text
      headlineMedium: TextStyle(color: Colors.white), // For other large titles
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF85C83E),
        foregroundColor: Colors.white,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      hintStyle: TextStyle(color: Colors.white), // For hint text in forms
    ),
  );

  // Light Theme Data
  ThemeData get _lightTheme => ThemeData(
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF5D6C8A),
      titleTextStyle: const TextStyle(color: Colors.black),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: Colors.black),
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black),
      // Set text to black for other widgets like Dropdown, TextFields, etc.
      labelLarge: TextStyle(color: Colors.black), // For dropdown text
      headlineMedium: TextStyle(color: Colors.black), // For other large titles
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF85C83E),
        foregroundColor: Colors.white,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      hintStyle: TextStyle(color: Colors.black), // For hint text in forms
    ),
  );
}
