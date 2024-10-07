import 'package:fitbattles/models/theme_model.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  AppTheme _currentTheme = AppTheme.light; // Default to light theme
  final ThemeModel _themeModel = ThemeModel(AppTheme.light); // Initialize with default

  ThemeProvider() {
    loadTheme(); // Load the saved theme on initialization
  }

  AppTheme get currentTheme => _currentTheme;

  // Toggle the theme and notify listeners
  void toggleTheme(AppTheme theme) {
    _currentTheme = theme;

    // Use the setter to update the theme
    _themeModel.theme = theme; // This will also save the theme
    notifyListeners();
  }

  // Load the theme from preferences
  void loadTheme() async {
    final loadedThemeModel = await ThemeModel.loadTheme();
    _currentTheme = loadedThemeModel.theme; // Set the current theme from loaded model
    notifyListeners();
  }

  // Get the theme data for the current theme
  ThemeData get themeData {
    return _currentTheme == AppTheme.dark ? ThemeData.dark() : ThemeData.light();
  }
}
