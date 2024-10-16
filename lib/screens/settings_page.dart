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
  bool _shareData = false;
  bool _receiveNotifications = true;
  bool _receiveChallengeNotifications = true;
  bool _dailyReminder = false;
  String _selectedLanguage = 'English';

  // Languages: Added more options including Chinese, Italian, and German
  final List<String> _languages = ['English', 'Spanish', 'French', 'Chinese', 'German'];

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
      _receiveChallengeNotifications = prefs.getBool('receiveChallengeNotifications') ?? true;
      _dailyReminder = prefs.getBool('dailyReminder') ?? false;
      _selectedLanguage = prefs.getString('selectedLanguage') ?? 'English';

      // Ensure the selected language is valid
      if (!_languages.contains(_selectedLanguage)) {
        _selectedLanguage = 'English'; // fallback to default
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    AppTheme selectedTheme = themeProvider.selectedTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.padding),
        children: [
          Text(AppStrings.selectTheme, style: const TextStyle(fontSize: AppDimens.sectionTitleFontSize)),
          ListTile(
            title: Text(
              AppStrings.lightTheme,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white // White in dark mode
                    : Colors.white, // Black in light mode
              ),
            ),
            leading: Radio<AppTheme>(
              value: AppTheme.light,
              groupValue: selectedTheme,
              onChanged: (AppTheme? value) {
                if (value != null) {
                  themeProvider.toggleTheme();
                  _showMessage(AppStrings.lightThemeSelected);
                }
              },
            ),
          ),
          ListTile(
            title: Text(
              AppStrings.darkTheme,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white // White in dark mode
                    : Colors.black, // Black in light mode
              ),
            ),
            leading: Radio<AppTheme>(
              value: AppTheme.dark,
              groupValue: selectedTheme,
              onChanged: (AppTheme? value) {
                if (value != null) {
                  themeProvider.toggleTheme();
                  _showMessage(AppStrings.darkThemeSelected);
                }
              },
            ),
          ),

          // Switch tiles for settings like notifications and reminders
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

          // DropdownButton for language selection
          ListTile(
            title: Text(
              'Select Language',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge!.color,
              ),
            ),
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              dropdownColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black // Black background for dropdown in dark mode
                  : Theme.of(context).cardColor, // Default color in light mode
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white // White text in dark mode
                    : Colors.black, // Black text in light mode
              ),
              iconEnabledColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white // White button in dark mode
                  : Colors.black, // Default (black) button in light mode
              items: _languages.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white // White text in dark mode
                          : Colors.black, // Black text in light mode
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

          const SizedBox(height: AppDimens.spaceBetweenEntries),
          ElevatedButton(
            onPressed: _saveSettings,
            style: ElevatedButton.styleFrom(
              foregroundColor: AppColors.textColor,
              backgroundColor: AppColors.buttonColor,
            ),
            child: const Text(
              AppStrings.saveSettings,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: AppDimens.spaceBetweenEntries),
          ElevatedButton(
            onPressed: _logOut,
            style: ElevatedButton.styleFrom(
              foregroundColor: AppColors.textColor,
              backgroundColor: Colors.red, // Log out button should stand out
            ),
            child: const Text(
              'Log Out',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.cardRadius)),
      elevation: AppDimens.cardElevation,
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textColor)),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.switchActiveColor,
      ),
    );
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('shareData', _shareData);
    await prefs.setBool('receiveNotifications', _receiveNotifications);
    await prefs.setBool('receiveChallengeNotifications', _receiveChallengeNotifications);
    await prefs.setBool('dailyReminder', _dailyReminder);
    await prefs.setString('selectedLanguage', _selectedLanguage);

    final message = '${AppStrings.settingsSaved}:\n'
        '${AppStrings.shareData}: $_shareData\n'
        '${AppStrings.receiveNotifications}: $_receiveNotifications\n'
        'Receive Challenge Notifications: $_receiveChallengeNotifications\n'
        'Daily Reminder: $_dailyReminder\n'
        'Selected Language: $_selectedLanguage';
    _showMessage(message);
  }

  Future<void> _logOut() async {
    try {
      await FirebaseAuth.instance.signOut();

      // Ensure Navigator operations happen after the sign-out
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage(title: 'Login', setLocale: (locale) {})), // Redirect to login page
      );
    } catch (e) {
      _showMessage('Error during log out: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
