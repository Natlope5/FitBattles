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
  String _selectedLanguage = 'English';

  // Languages: Added more options including Chinese, Italian, and German
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

    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return ScaffoldMessenger(
      key: scaffoldMessengerKey, // Step 2: Use the GlobalKey here
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppStrings.settings,
            style: TextStyle(
              color: isDarkTheme ? Colors.white : Colors.black,
            ),
          ),
          backgroundColor: isDarkTheme ? Color(-15592942) : AppColors.appBarColor,
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppDimens.padding),
          children: [
            Text(
              AppStrings.selectTheme,
              style: TextStyle(
                fontSize: AppDimens.sectionTitleFontSize,
                color: isDarkTheme ? Colors.white : Colors.black,
              ),
            ),
            ListTile(
              title: Text(
                AppStrings.lightTheme,
                style: TextStyle(
                  color: isDarkTheme ? Colors.white : Colors.black,
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
                  color: isDarkTheme ? Colors.white : Colors.black,
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
                  color: isDarkTheme ? Colors.white : Colors.black,
                ),
              ),
              trailing: DropdownButton<String>(
                value: _selectedLanguage,
                dropdownColor: isDarkTheme ? Colors.black : Colors.white,
                style: TextStyle(
                  color: isDarkTheme ? Colors.white : Colors.black,
                ),
                iconEnabledColor: isDarkTheme ? Colors.white : Colors.black,
                items: _languages.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(
                        color: isDarkTheme ? Colors.white : Colors.black,
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
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF85C83E),
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

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.cardRadius)),
      elevation: AppDimens.cardElevation,
      color: isDarkTheme ? Color(-15592942) : Colors.white,
      child: SwitchListTile(
        title: Text(
          title,
          style: TextStyle(
            color: isDarkTheme ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDarkTheme ? Colors.white : Colors.black,
          ),
        ),
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
    await prefs.setBool(
        'receiveChallengeNotifications', _receiveChallengeNotifications);
    await prefs.setBool('dailyReminder', _dailyReminder);
    await prefs.setString('selectedLanguage', _selectedLanguage);

    _showMessage(AppStrings.settingsSaved);
  }

  Future<void> _logOut() async {
    await FirebaseAuth.instance.signOut();

    scaffoldMessengerKey.currentState?.showSnackBar(
      const SnackBar(content: Text('Logging out...')),
    );

    // Delay navigation to allow the user to see the message
    await Future.delayed(const Duration(seconds: 1));

    // Navigate to the LoginPage and clear the navigation stack
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