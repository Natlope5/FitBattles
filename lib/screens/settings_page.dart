import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitbattles/settings/theme_provider.dart';
import 'package:fitbattles/settings/app_colors.dart';
import 'package:fitbattles/settings/app_strings.dart';
import 'package:fitbattles/settings/app_dimens.dart';

import '../main.dart';

class GlobalNavigation {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Navigates to the login screen.
  static Future<void> navigateToLogin() async {
    navigatorKey.currentState?.pushReplacementNamed('/login');
  }

  /// Shows a SnackBar message.
  static void showMessage(String message) {
    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class AuthService {
  /// Handles user logout process.
  Future<void> logOut() async {
    // Implement logout logic here, such as clearing tokens or session data
    logger.i("User logged out");
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  bool _shareData = false;
  bool _receiveNotifications = true;
  bool _receiveChallengeNotifications = true;
  bool _dailyReminder = false;
  bool _profileVisibility = true;
  bool _allowFriendRequests = true;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// Loads the user's saved settings from local storage.
  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _shareData = prefs.getBool('shareData') ?? false;
      _receiveNotifications = prefs.getBool('receiveNotifications') ?? true;
      _receiveChallengeNotifications = prefs.getBool('receiveChallengeNotifications') ?? true;
      _dailyReminder = prefs.getBool('dailyReminder') ?? false;
      _profileVisibility = prefs.getBool('profileVisibility') ?? true;
      _allowFriendRequests = prefs.getBool('allowFriendRequests') ?? true;
    });
  }

  /// Saves the user's settings to local storage.
  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('shareData', _shareData);
    await prefs.setBool('receiveNotifications', _receiveNotifications);
    await prefs.setBool('receiveChallengeNotifications', _receiveChallengeNotifications);
    await prefs.setBool('dailyReminder', _dailyReminder);
    await prefs.setBool('profileVisibility', _profileVisibility);
    await prefs.setBool('allowFriendRequests', _allowFriendRequests);

    GlobalNavigation.showMessage(AppStrings.settingsSaved);
  }

  /// Logs out the user and navigates to the login screen.
  Future<void> _logOut() async {
    await _authService.logOut();
    GlobalNavigation.showMessage(AppStrings.loggedOut);
    await GlobalNavigation.navigateToLogin();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider(); // Directly instantiated ThemeProvider
    final isDarkTheme = themeProvider.isDarkMode; // Example getter in ThemeProvider

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.settings),
        backgroundColor: isDarkTheme ? Colors.black : AppColors.appBarColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.padding),
        children: [
          Text(
            'Select Theme',
            style: TextStyle(
              fontSize: AppDimens.sectionTitleFontSize,
              color: isDarkTheme ? Colors.white : Colors.black,
            ),
          ),
          // Theme selection UI...

          Text(
            'Privacy Settings',
            style: TextStyle(
              fontSize: AppDimens.sectionTitleFontSize,
              color: isDarkTheme ? Colors.white : Colors.black,
            ),
          ),
          _buildSwitchTile(
            title: 'Profile Visibility',
            subtitle: 'Allow others to see your profile.',
            value: _profileVisibility,
            onChanged: (bool newValue) {
              setState(() {
                _profileVisibility = newValue;
              });
            },
          ),
          _buildSwitchTile(
            title: 'Allow Friend Requests',
            subtitle: 'Let others send you friend requests.',
            value: _allowFriendRequests,
            onChanged: (bool newValue) {
              setState(() {
                _allowFriendRequests = newValue;
              });
            },
          ),
          _buildSwitchTile(
            title: 'Share Data with Friends',
            subtitle: 'Enable data sharing with friends.',
            value: _shareData,
            onChanged: (bool newValue) {
              setState(() {
                _shareData = newValue;
              });
            },
          ),
          _buildSwitchTile(
            title: 'Receive Notifications',
            subtitle: 'Get notifications about new challenges and updates.',
            value: _receiveNotifications,
            onChanged: (bool newValue) {
              setState(() {
                _receiveNotifications = newValue;
              });
            },
          ),
          _buildSwitchTile(
            title: 'Challenge Notifications',
            subtitle: 'Receive notifications for challenge activities.',
            value: _receiveChallengeNotifications,
            onChanged: (bool newValue) {
              setState(() {
                _receiveChallengeNotifications = newValue;
              });
            },
          ),
          _buildSwitchTile(
            title: 'Daily Reminder',
            subtitle: 'Get a daily reminder for challenges.',
            value: _dailyReminder,
            onChanged: (bool newValue) {
              setState(() {
                _dailyReminder = newValue;
              });
            },
          ),
          ElevatedButton(
            onPressed: _saveSettings,
            child: const Text('Save Settings'),
          ),
          ElevatedButton(
            onPressed: _logOut,
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  /// Builds a switch tile with a title, subtitle, and toggle switch.
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }
}
