import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../settings/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  bool _shareData = false;
  bool _receiveNotifications = true;

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
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    AppTheme selectedTheme = themeProvider.selectedTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('Select Theme', style: TextStyle(fontSize: 18)),
          ListTile(
            title: const Text('Light Theme'),
            leading: Radio<AppTheme>(
              value: AppTheme.light,
              groupValue: selectedTheme,
              onChanged: (AppTheme? value) {
                if (value != null) {
                  themeProvider.toggleTheme(); // Just call toggleTheme
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Light Theme selected')),
                  );
                }
              },
            ),
          ),
          ListTile(
            title: const Text('Dark Theme'),
            leading: Radio<AppTheme>(
              value: AppTheme.dark,
              groupValue: selectedTheme,
              onChanged: (AppTheme? value) {
                if (value != null) {
                  themeProvider.toggleTheme(); // Just call toggleTheme
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Dark Theme selected')),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 20),
          const Text('Privacy Settings', style: TextStyle(fontSize: 18)),
          _buildSwitchTile(
            title: 'Share Data',
            subtitle: 'Allow sharing your data with third parties.',
            value: _shareData,
            onChanged: (bool value) {
              setState(() {
                _shareData = value;
              });
            },
          ),
          _buildSwitchTile(
            title: 'Receive Notifications',
            subtitle: 'Enable notifications for updates and offers.',
            value: _receiveNotifications,
            onChanged: (bool value) {
              setState(() {
                _receiveNotifications = value;
              });
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveSettings,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: const Color(0xFF85C83E),
            ),
            child: const Text('Save Settings', style: TextStyle(fontWeight: FontWeight.bold)),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.black54)),
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF85C83E),
      ),
    );
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('shareData', _shareData);
    await prefs.setBool('receiveNotifications', _receiveNotifications);

    final message = 'Settings saved:\nShare Data: $_shareData\nReceive Notifications: $_receiveNotifications';
    _showMessage(message);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
