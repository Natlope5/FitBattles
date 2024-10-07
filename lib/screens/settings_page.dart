// screens/settings_page.dart

import 'package:flutter/material.dart';
import 'package:fitbattles/settings/theme_preferences.dart';
import 'package:fitbattles/models/theme_model.dart';
import 'package:fitbattles/screens/privacy_settings_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  ThemeModel _selectedTheme = ThemeModel(AppTheme.light);
  final ThemePreferences _themePreferences = ThemePreferences();

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _selectedTheme = (await _themePreferences.loadTheme());
    setState(() {});
  }

  Future<void> _saveTheme(ThemeModel theme) async {
    await _themePreferences.saveTheme(theme);
    setState(() {
      _selectedTheme = theme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('Select Theme', style: TextStyle(fontSize: 18)),
          ListTile(
            title: const Text('Light Theme'),
            leading: Radio<AppTheme>(
              value: AppTheme.light,
              groupValue: _selectedTheme.theme,
              onChanged: (AppTheme? value) {
                if (value != null) {
                  _saveTheme(ThemeModel(value));
                }
              },
            ),
          ),
          ListTile(
            title: const Text('Dark Theme'),
            leading: Radio<AppTheme>(
              value: AppTheme.dark,
              groupValue: _selectedTheme.theme,
              onChanged: (AppTheme? value) {
                if (value != null) {
                  _saveTheme(ThemeModel(value));
                }
              },
            ),
          ),
          // Button to navigate to PrivacySettingsPage
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PrivacySettingsPage(
                    onMessage: (String message) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(message)),
                      );
                    },
                  ),
                ),
              );
            },
            child: const Text('Go to Privacy Settings'),
          ),
          // Add other settings here...
        ],
      ),
    );
  }
}
