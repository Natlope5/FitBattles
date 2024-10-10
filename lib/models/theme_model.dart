import 'package:flutter/material.dart';

class ThemeModel {
  // Light theme settings
  final ThemeData lightTheme = ThemeData(
    primaryColor: Color(0xFF5D6C8A), // App bar color
    scaffoldBackgroundColor: Color(0xFF5D6C8A), // Background color for the app
    buttonTheme: ButtonThemeData(
      buttonColor: Color(0xFF85C83E), // Button background color
      textTheme: ButtonTextTheme.primary, // Button text color (black)
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.black), // Body text color
      bodyMedium: TextStyle(color: Colors.black), // Body text color
    ),
  );

  // Dark theme settings
  final ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.black, // Background color for dark mode
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.black, // App bar color in dark mode
    ),
    cardColor: Color(0xFF5D6C8A), // Container background color
    buttonTheme: ButtonThemeData(
      buttonColor: Color(0xFF85C83E), // Button background color in dark mode
      textTheme: ButtonTextTheme.primary, // Button text color
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.white), // Body text color in dark mode
      bodyMedium: TextStyle(color: Colors.white), // Body text color in dark mode
    ),
  );
}
