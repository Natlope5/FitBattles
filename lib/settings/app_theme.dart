enum MyAppTheme { light, dark }

extension AppThemeExtension on MyAppTheme {
  String toKey() {
    switch (this) {
      case MyAppTheme.light:
        return 'light';
      case MyAppTheme.dark:
        return 'dark';
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
