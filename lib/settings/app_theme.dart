import 'package:fitbattles/settings/app_strings.dart';

enum MyAppTheme { light, dark }

extension AppThemeExtension on MyAppTheme {
  String toKey() {
    switch (this) {
      case MyAppTheme.light:
        return AppStrings.lightTheme; // Use the string from AppStrings
      case MyAppTheme.dark:
        return AppStrings.darkTheme; // Use the string from AppStrings
    }
  }

  static MyAppTheme fromKey(String key) {
    switch (key) {
      case 'dark':
        return MyAppTheme.dark;
      case 'light':
      default:
        return MyAppTheme.light;
    }
  }
}
