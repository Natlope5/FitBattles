import 'package:fitbattles/firebase/firebase_auth.dart';
import 'package:fitbattles/main.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore
import 'package:shared_preferences/shared_preferences.dart'; // For shared preferences
import '../settings/app_colors.dart'; // Custom app colors
import 'package:fitbattles/models/privacy_model.dart'; // Import PrivacyModel

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
  const SettingsPage({super.key, required String heading});

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
  VisibilityOption _selectedVisibility = VisibilityOption.friendsOnly; // Default visibility setting
  VisibilityOption _selectedPrivacyVisibility = VisibilityOption.friendsOnly; // Default privacy setting

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

    // Load user visibility and privacy settings from Firestore
    final userId = _firebaseAuthService.getCurrentUser()?.uid;
    if (userId != null) {
      final privacyModel = PrivacyModel(id: userId); // Initialize PrivacyModel
      String visibilitySetting = await privacyModel.getPrivacySetting();
      setState(() {
        _selectedVisibility = VisibilityOption.values.firstWhere(
              (e) => e.toString().split('.').last == visibilitySetting,
          orElse: () => VisibilityOption.friendsOnly,
        );
        _selectedPrivacyVisibility = _selectedVisibility; // Initialize privacy setting with visibility setting
      });
    }
  }

  Future<void> _updateSetting(VisibilityOption option, String settingType) async {
    setState(() {
      if (settingType == 'visibility') {
        _selectedVisibility = option;
      } else {
        _selectedPrivacyVisibility = option;
      }
    });

    final userId = _firebaseAuthService.getCurrentUser()?.uid;
    if (userId != null) {
      try {
        if (settingType == 'visibility') {
          await FirebaseFirestore.instance.collection('users').doc(userId).update({
            'visibilitySetting': option.toString().split('.').last,
          });
          _showMessage('Visibility setting updated to ${option.toString().split('.').last}');
        } else {
          final privacyModel = PrivacyModel(id: userId); // Initialize PrivacyModel
          await privacyModel.updatePrivacySetting(option.toString().split('.').last);
          _showMessage('Privacy setting updated to ${option.toString().split('.').last}');
        }
      } catch (error) {
        _showMessage('Error updating $settingType: $error');
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
        body: SingleChildScrollView( // Wrap Column with SingleChildScrollView
          child: Padding(
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
                Text('Privacy Settings:'),
                _buildPrivacyVisibilityOption(VisibilityOption.public, 'Public'),
                _buildPrivacyVisibilityOption(VisibilityOption.friendsOnly, 'Friends Only'),
                _buildPrivacyVisibilityOption(VisibilityOption.private, 'Private'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Set the button color
                    foregroundColor: Colors.black, // Set the text color
                  ),
                  child: const Text('Logout'),
                ),
              ],
            ),
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


  // Build privacy visibility option widget
  Widget _buildPrivacyVisibilityOption(VisibilityOption option, String label) {
    return RadioListTile<VisibilityOption>(
      title: Text(label),
      value: option,
      groupValue: _selectedPrivacyVisibility,
      onChanged: (VisibilityOption? value) {
        if (value != null) {
          _updateSetting(value, 'privacy'); // Update privacy setting
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

    // After signing out, navigate to the login page
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/login',
          (Route<dynamic> route) => false, // This removes all routes except the login
    );
  }

  // Save all settings method
  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('shareData', _shareData);
    await prefs.setBool('receiveNotifications', _receiveNotifications);
    await prefs.setBool('receiveChallengeNotifications', _receiveChallengeNotifications);
    await prefs.setBool('dailyReminder', _dailyReminder);
    await prefs.setString('selectedLanguage', _selectedLanguage);

    _showMessage('Settings saved!');
  }

  // Save individual setting to Firestore
  Future<void> _saveSettingToFirestore(String settingType, dynamic value) async {
    final userId = _firebaseAuthService.getCurrentUser()?.uid;
    if (userId != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        settingType: value,
      });
    }
  }
}
