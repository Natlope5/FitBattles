import 'package:fitbattles/firebase/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore
import 'package:shared_preferences/shared_preferences.dart'; // For shared preferences
import '../settings/app_colors.dart'; // Custom app colors


extension StringCapitalization on String {
  String capitalize() {
    if (isEmpty) {
      return this;
    }
    return this[0].toUpperCase() + substring(1);
  }
}

enum VisibilityOption {
  public,
  friendsOnly,
  private,
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService(); // Firebase Auth Service instance

  bool _shareData = false;
  bool _receiveNotifications = true;
  bool _receiveChallengeNotifications = true;
  bool _dailyReminder = false;
  String _selectedLanguage = 'English';
  VisibilityOption _selectedVisibility = VisibilityOption.friendsOnly;

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
    // Load user settings from shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _shareData = prefs.getBool('shareData') ?? false;
      _receiveNotifications = prefs.getBool('receiveNotifications') ?? true;
      _receiveChallengeNotifications = prefs.getBool('receiveChallengeNotifications') ?? true;
      _dailyReminder = prefs.getBool('dailyReminder') ?? false;
      _selectedLanguage = prefs.getString('selectedLanguage') ?? 'English';
    });

    // Load user visibility setting from Firestore
    final userId = _firebaseAuthService.getCurrentUser()?.uid;
    if (userId != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        String visibilitySetting = userDoc.data()?['visibilitySetting'] ?? 'friendsOnly';
        setState(() {
          _selectedVisibility = VisibilityOption.values.firstWhere(
                (e) => e.toString().split('.').last == visibilitySetting,
            orElse: () => VisibilityOption.friendsOnly,
          );
        });
      }
    }
  }

  Future<void> _updateVisibility(VisibilityOption option) async {
    setState(() {
      _selectedVisibility = option;
    });

    final userId = _firebaseAuthService.getCurrentUser()?.uid;
    if (userId != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'visibilitySetting': option.toString().split('.').last,
        });
        _showMessage('Visibility setting updated to ${option.toString().split('.').last}');
      } catch (error) {
        _showMessage('Error updating visibility: $error');
      }
    } else {
      _showMessage('User is not logged in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveSettings,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildSwitchTile(
                title: 'Share Data',
                subtitle: 'Share data with friends',
                value: _shareData,
                onChanged: (value) {
                  setState(() {
                    _shareData = value;
                  });
                  _saveSettingToFirestore('shareData', value);
                },
              ),
              _buildSwitchTile(
                title: 'Receive Notifications',
                subtitle: 'Get notified about challenges',
                value: _receiveNotifications,
                onChanged: (value) {
                  setState(() {
                    _receiveNotifications = value;
                  });
                  _saveSettingToFirestore('receiveNotifications', value);
                },
              ),
              _buildSwitchTile(
                title: 'Receive Challenge Notifications',
                subtitle: 'Get notified about new challenges',
                value: _receiveChallengeNotifications,
                onChanged: (value) {
                  setState(() {
                    _receiveChallengeNotifications = value;
                  });
                  _saveSettingToFirestore('receiveChallengeNotifications', value);
                },
              ),
              _buildSwitchTile(
                title: 'Daily Reminder',
                subtitle: 'Get a daily reminder',
                value: _dailyReminder,
                onChanged: (value) {
                  setState(() {
                    _dailyReminder = value;
                  });
                  _saveSettingToFirestore('dailyReminder', value);
                },
              ),
              DropdownButton<String>(
                value: _selectedLanguage,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLanguage = newValue ?? 'English';
                  });
                  _saveSettingToFirestore('selectedLanguage', _selectedLanguage);
                },
                items: _languages.map<DropdownMenuItem<String>>((String language) {
                  return DropdownMenuItem<String>(
                    value: language,
                    child: Text(language),
                  );
                }).toList(),
              ),
              const Divider(),
              Text('Visibility Settings:'),
              _buildVisibilityOption(VisibilityOption.public, 'Public'),
              _buildVisibilityOption(VisibilityOption.friendsOnly, 'Friends Only'),
              _buildVisibilityOption(VisibilityOption.private, 'Private'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _logout,
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom switch tile widget for cleaner code
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      title: Text(title, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
      subtitle: Text(subtitle, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.switchActiveColor,
        inactiveTrackColor: AppColors.switchInactiveColor,
      ),
    );
  }

  // Build visibility option widget
  Widget _buildVisibilityOption(VisibilityOption option, String label) {
    return RadioListTile<VisibilityOption>(
      title: Text(label),
      value: option,
      groupValue: _selectedVisibility,
      onChanged: (VisibilityOption? value) {
        if (value != null) {
          _updateVisibility(value);
        }
      },
    );
  }

  // Show messages to the user
  void _showMessage(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
  }

  // Logout method
  Future<void> _logout() async {
    await _firebaseAuthService.signOut();
    // Your navigation method
  }

  // Save all settings method
  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('shareData', _shareData);
    await prefs.setBool('receiveNotifications', _receiveNotifications);
    await prefs.setBool('receiveChallengeNotifications', _receiveChallengeNotifications);
    await prefs.setBool('dailyReminder', _dailyReminder);
    await prefs.setString('selectedLanguage', _selectedLanguage);

    _showMessage('Settings saved locally.');
  }

  // Save setting to Firestore
  Future<void> _saveSettingToFirestore(String key, dynamic value) async {
    final userId = _firebaseAuthService.getCurrentUser()?.uid;
    if (userId != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).set({key: value}, SetOptions(merge: true));
        _showMessage('$key updated in Firestore.');
      } catch (error) {
        _showMessage('Error saving $key to Firestore: $error');
      }
    }
  }
}
