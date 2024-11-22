import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, bool> _notificationSettings = {
    'receiveNotifications': true,
    'messageNotifications': true,
    'friendRequestNotifications': true,
    'challengeNotifications': true,
  };
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('settings')
            .doc('notifications')
            .get();

        if (doc.exists) {
          setState(() {
            _notificationSettings = Map<String, bool>.from(doc.data() ?? {});
          });
        } else {
          // Create default settings if they don't exist
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('settings')
              .doc('notifications')
              .set(_notificationSettings);
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load settings: $e")),
        );
      }
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> _saveNotificationSettings() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('settings')
            .doc('notifications')
            .set(_notificationSettings);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Notification settings updated!")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save settings: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text("Notification Settings")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notification Settings"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Master switch for receiving notifications
          SwitchListTile(
            title: const Text("Receive Notifications"),
            value: _notificationSettings['receiveNotifications'] ?? true,
            onChanged: (value) {
              setState(() {
                _notificationSettings['receiveNotifications'] = value;
              });
            },
          ),
          if (_notificationSettings['receiveNotifications'] ?? true) ...[
            SwitchListTile(
              title: const Text("Message Notifications"),
              value: _notificationSettings['messageNotifications'] ?? true,
              onChanged: (value) {
                setState(() {
                  _notificationSettings['messageNotifications'] = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text("Friend Request Notifications"),
              value: _notificationSettings['friendRequestNotifications'] ?? true,
              onChanged: (value) {
                setState(() {
                  _notificationSettings['friendRequestNotifications'] = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text("Challenge Notifications"),
              value: _notificationSettings['challengeNotifications'] ?? true,
              onChanged: (value) {
                setState(() {
                  _notificationSettings['challengeNotifications'] = value;
                });
              },
            ),
          ],
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: _saveNotificationSettings,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text("Save Changes"),
            ),
          ),
        ],
      ),
    );
  }
}
