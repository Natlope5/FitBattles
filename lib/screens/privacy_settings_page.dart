import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacySettingsPage extends StatefulWidget {
  final Function(String) onMessage; // Callback function to display messages

  const PrivacySettingsPage({super.key, required this.onMessage});

  @override
  PrivacySettingsPageState createState() => PrivacySettingsPageState();
}

class PrivacySettingsPageState extends State<PrivacySettingsPage> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Settings'),
        backgroundColor: const Color(0xFF5D6C8A), // Your app bar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Share Data'),
              subtitle: const Text('Allow sharing your data with third parties.'),
              value: _shareData,
              onChanged: (bool value) {
                setState(() {
                  _shareData = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Receive Notifications'),
              subtitle: const Text('Enable notifications for updates and offers.'),
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
                backgroundColor: const Color(0xFF85C83E), // Your button background color
              ),
              child: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('shareData', _shareData);
    await prefs.setBool('receiveNotifications', _receiveNotifications);

    final message = 'Settings saved:\nShare Data: $_shareData\nReceive Notifications: $_receiveNotifications';
    widget.onMessage(message); // Use the callback to show the message
  }
}
