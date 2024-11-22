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
  Map<String, bool> _notificationSettings = {};

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    User? user = _auth.currentUser;
    if (user != null) {
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
        setState(() {
          _notificationSettings = {
            'messageNotifications': true,
            'friendRequestNotifications': true,
            'challengeNotifications': true,
          };
        });
      }
    }
  }

  Future<void> _saveNotificationSettings() async {
    User? user = _auth.currentUser;
    if (user != null) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notification Settings"),
      ),
      body: ListView(
        children: [
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
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveNotificationSettings,
            child: const Text("Save Changes"),
          ),
        ],
      ),
    );
  }
}