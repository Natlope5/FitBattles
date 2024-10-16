import 'package:flutter/material.dart';
import 'package:fitbattles/settings/app_colors.dart';

class ThemeModel {
  // Light theme settings
  final ThemeData lightTheme = ThemeData(
    primaryColor: AppColors.appBarColor,
    scaffoldBackgroundColor: AppColors.scaffoldBackgroundColor,
    buttonTheme: ButtonThemeData(
      buttonColor: AppColors.buttonBackgroundColor,
      textTheme: ButtonTextTheme.primary,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black),
    ),
  );

  // Dark theme settings
  final ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.black,
    ),
    cardColor: AppColors.cardColor,
    buttonTheme: ButtonThemeData(
      buttonColor: AppColors.buttonBackgroundColor,
      textTheme: ButtonTextTheme.primary,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
    ),
  );
}
