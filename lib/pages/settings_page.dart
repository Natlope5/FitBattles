import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth
import '../settings/app_colors.dart';
import '../settings/app_dimens.dart';
import '../settings/app_strings.dart';
import '../settings/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_page.dart'; // Replace with the actual login page import

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
  GlobalKey<ScaffoldMessengerState>(); // Step 1: Create a GlobalKey
  bool _shareData = false;
  bool _receiveNotifications = true;
  bool _receiveChallengeNotifications = true;
  bool _dailyReminder = false;
  late bool _isDarkThemeEnabled;
  String _selectedLanguage = 'English';

  final List<String> _languages = [
    'English',
    'Spanish',
    'French',
    'Chinese',
    'German'
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _shareData = prefs.getBool('shareData') ?? false;
      _receiveNotifications = prefs.getBool('receiveNotifications') ?? true;
      _receiveChallengeNotifications =
          prefs.getBool('receiveChallengeNotifications') ?? true;
      _dailyReminder = prefs.getBool('dailyReminder') ?? false;
      _selectedLanguage = prefs.getString('selectedLanguage') ?? 'English';
      _isDarkThemeEnabled = Theme.of(context).brightness == Brightness.dark;

      if (!_languages.contains(_selectedLanguage)) {
        _selectedLanguage = 'English'; // fallback to default
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppStrings.settings,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Color(-15592942)
              : AppColors.appBarColor,
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Color(-15592942)
            : Color(0xFF5D6C8A),
        body: ListView(
          padding: const EdgeInsets.all(AppDimens.padding),
          children: [
            // Language Dropdown Menu using _buildListTile
            _buildListTile(
              title: 'Select Language',
              trailing: DropdownButton<String>(
                value: _selectedLanguage,
                dropdownColor: Theme.of(context).brightness == Brightness.dark
                    ? Color(-15592942)
                    : Colors.white,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
                iconEnabledColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                items: _languages.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedLanguage = newValue;
                    });
                  }
                },
              ),
            ),
            _buildSwitchTile(
              title: AppStrings.darkTheme,
              subtitle: "Turn dark mode on or off.",
              value: _isDarkThemeEnabled,
              onChanged: (bool newValue) {
                setState(() {
                  _isDarkThemeEnabled = newValue;
                  themeProvider.toggleTheme();
                  _saveThemePreference(newValue);
                });
              },
            ),
            _buildSwitchTile(
              title: AppStrings.shareData,
              subtitle: AppStrings.shareDataDesc,
              value: _shareData,
              onChanged: (bool newValue) {
                setState(() {
                  _shareData = newValue;
                });
              },
            ),
            _buildSwitchTile(
              title: AppStrings.receiveNotifications,
              subtitle: AppStrings.receiveNotificationsDesc,
              value: _receiveNotifications,
              onChanged: (bool newValue) {
                setState(() {
                  _receiveNotifications = newValue;
                });
              },
            ),
            _buildSwitchTile(
              title: 'Receive Challenge Notifications',
              subtitle: 'Get notified about new challenges.',
              value: _receiveChallengeNotifications,
              onChanged: (bool newValue) {
                setState(() {
                  _receiveChallengeNotifications = newValue;
                });
              },
            ),
            _buildSwitchTile(
              title: 'Daily Reminder',
              subtitle: 'Receive a daily reminder for your tasks.',
              value: _dailyReminder,
              onChanged: (bool newValue) {
                setState(() {
                  _dailyReminder = newValue;
                });
              },
            ),
            ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF85C83E),
              ),
              child: const Text(
                AppStrings.saveSettings,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: _logOut,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'Log Out',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required Widget trailing,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      ),
      elevation: AppDimens.cardElevation,
      color: Theme.of(context).brightness == Brightness.dark
          ? Color(-15592942) // Dark mode background color
          : Colors.white, // Light mode background color
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
        trailing: trailing,
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      ),
      elevation: AppDimens.cardElevation,
      color: Theme.of(context).brightness == Brightness.dark
          ? Color(-15592942)
          : Colors.white,
      child: SwitchListTile(
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.switchActiveColor,
      ),
    );
  }

  Future<void> _saveThemePreference(bool isDarkThemeEnabled) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkThemeEnabled', isDarkThemeEnabled);
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('shareData', _shareData);
    await prefs.setBool('receiveNotifications', _receiveNotifications);
    await prefs.setBool('receiveChallengeNotifications', _receiveChallengeNotifications);
    await prefs.setBool('dailyReminder', _dailyReminder);
    await prefs.setString('selectedLanguage', _selectedLanguage);

    _showMessage(AppStrings.settingsSaved);
  }

  Future<void> _logOut() async {
    await FirebaseAuth.instance.signOut();

    scaffoldMessengerKey.currentState?.showSnackBar(
      const SnackBar(content: Text('Logging out...')),
    );

    await Future.delayed(const Duration(seconds: 1));

    Navigator.of(scaffoldMessengerKey.currentContext!).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => LoginPage(
          title: '',
          setLocale: (locale) {},
        ),
      ),
          (Route<dynamic> route) => false,
    );
  }

  void _showMessage(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}