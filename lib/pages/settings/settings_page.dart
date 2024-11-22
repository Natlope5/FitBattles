import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:fitbattles/pages/settings/notifications_settings_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  File? _image;

  // Profile settings controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightFeetController = TextEditingController();
  final TextEditingController _heightInchesController = TextEditingController();

  String _privacy = 'public';
  String _avatarUrl = '';

  // App settings
  bool _darkMode = false;

  // Notification settings
  bool _receiveNotifications = true;

  String _message = '';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  Future<void> _migrateSettings(DocumentSnapshot userDoc, String uid) async {
    final Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

    // Fetch existing settings documents if they already exist
    final profileRef = _firestore.collection('users').doc(uid).collection('settings').doc('profile');
    final appRef = _firestore.collection('users').doc(uid).collection('settings').doc('app');
    final notificationsRef = _firestore.collection('users').doc(uid).collection('settings').doc('notifications');

    final profileDoc = await profileRef.get();
    final appDoc = await appRef.get();
    final notificationsDoc = await notificationsRef.get();

    // Prepare profile settings, preserving existing data
    Map<String, dynamic> profileData = {
      'name': userData['name'] ?? (profileDoc.exists ? profileDoc['name'] : ''),
      'email': userData['email'] ?? (profileDoc.exists ? profileDoc['email'] : ''),
      'age': userData['age'] ?? (profileDoc.exists ? profileDoc['age'] : 0),
      'weight': userData['weight'] ?? (profileDoc.exists ? profileDoc['weight'] : 0.0),
      'heightInches': userData['height_inches'] ?? (profileDoc.exists ? profileDoc['heightInches'] : 0),
      'privacy': userData['visibility'] ?? (profileDoc.exists ? profileDoc['privacy'] : 'public'),
      'avatar': userData['avatar'] ?? (profileDoc.exists ? profileDoc['avatar'] : ''),
    };

    await profileRef.set(profileData);

    // Prepare app settings, preserving existing data
    Map<String, dynamic> appData = {
      'darkMode': userData['darkMode'] ?? (appDoc.exists ? appDoc['darkMode'] : false),
    };

    await appRef.set(appData);

    // Prepare notification settings, preserving existing data
    Map<String, dynamic> notificationData = {
      'receiveNotifications': userData['receive_notifications'] ?? (notificationsDoc.exists ? notificationsDoc['receiveNotifications'] : true),
    };

    await notificationsRef.set(notificationData);

    // Clean up the original fields from the user document
    await _firestore.collection('users').doc(uid).update({
      'email': FieldValue.delete(),
      'age': FieldValue.delete(),
      'weight': FieldValue.delete(),
      'height_inches': FieldValue.delete(),
      'visibility': FieldValue.delete(),
      'avatar': FieldValue.delete(),
      'receive_notifications': FieldValue.delete(),
    });
  }

  Future<void> _loadUserSettings() async {
    User? user = _auth.currentUser;
    if (user != null) {
      final profileRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('profile');
      final appRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('app');
      final notificationsRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('notifications');

      DocumentSnapshot profileDoc = await profileRef.get();
      DocumentSnapshot appDoc = await appRef.get();
      DocumentSnapshot notificationsDoc = await notificationsRef.get();

      if (!profileDoc.exists || !appDoc.exists || !notificationsDoc.exists) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          await _migrateSettings(userDoc, user.uid);
          profileDoc = await profileRef.get();
          appDoc = await appRef.get();
          notificationsDoc = await notificationsRef.get();
        }
      }

      if (profileDoc.exists) {
        Map<String, dynamic> profileData =
        profileDoc.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = profileData['name'] ?? '';
          _emailController.text = profileData['email'] ?? '';
          _ageController.text = (profileData['age'] ?? 0).toString();
          _weightController.text = (profileData['weight'] ?? 0.0).toString();
          int totalHeightInInches = profileData['heightInches'] ?? 0;
          _heightFeetController.text = (totalHeightInInches ~/ 12).toString();
          _heightInchesController.text =
              (totalHeightInInches % 12).toString();
          _privacy = profileData['privacy'] ?? 'public';
          _avatarUrl = profileData['avatar'] ?? '';
        });
      }

      if (appDoc.exists) {
        Map<String, dynamic> appData = appDoc.data() as Map<String, dynamic>;
        setState(() {
          _darkMode = appData['darkMode'] ?? false;
        });
      }

      if (notificationsDoc.exists) {
        Map<String, dynamic> notificationsData =
        notificationsDoc.data() as Map<String, dynamic>;
        setState(() {
          _receiveNotifications =
              notificationsData['receiveNotifications'] ?? true;
        });
      }
    }
  }

  Future<String> _saveSettings() async {
    User? user = _auth.currentUser;
    if (user != null && _formKey.currentState!.validate()) {
      try {
        int totalHeightInInches = (int.parse(_heightFeetController.text) * 12) +
            int.parse(_heightInchesController.text);

        final profileRef = _firestore.collection('users').doc(user.uid).collection('settings').doc('profile');
        await profileRef.set({
          'name': _nameController.text,
          'email': _emailController.text,
          'age': int.parse(_ageController.text),
          'weight': double.parse(_weightController.text),
          'heightInches': totalHeightInInches,
          'privacy': _privacy,
          'avatar': _avatarUrl,
        });

        final appRef = _firestore.collection('users').doc(user.uid).collection('settings').doc('app');
        await appRef.set({'darkMode': _darkMode});

        final notificationsRef = _firestore.collection('users').doc(user.uid).collection('settings').doc('notifications');
        await notificationsRef.set({'receiveNotifications': _receiveNotifications});

        setState(() {
          _message = 'Settings updated successfully!';
        });
        return _message;
      } catch (e) {
        setState(() {
          _message = 'Failed to update settings: ${e.toString()}';
        });
        return _message;
      }
    }
    setState(() {
      _message = 'Failed to update settings: Form validation error';
    });
    return _message;
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_image != null) {
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('avatars/${DateTime.now().millisecondsSinceEpoch}.png');
        await storageRef.putFile(_image!);

        String imageUrl = await storageRef.getDownloadURL();

        setState(() {
          _avatarUrl = imageUrl;
        });

        User? user = _auth.currentUser;
        if (user != null) {
          final profileRef = _firestore
              .collection('users')
              .doc(user.uid)
              .collection('settings')
              .doc('profile');
          await profileRef.update({'avatar': _avatarUrl});
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Avatar updated successfully')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image: ${e.toString()}')));
      }
    }
  }

  Future<void> _showLogoutDialog() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
    if (shouldLogout == true) {
      await _auth.signOut();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) =>
                    value!.isEmpty ? 'Please enter your name' : null,
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  TextFormField(
                    controller: _ageController,
                    decoration: const InputDecoration(labelText: 'Age'),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                    value!.isEmpty ? 'Please enter your age' : null,
                  ),
                  TextFormField(
                    controller: _weightController,
                    decoration:
                    const InputDecoration(labelText: 'Weight (lbs)'),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                    value!.isEmpty ? 'Please enter your weight' : null,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _heightFeetController,
                          decoration:
                          const InputDecoration(labelText: 'Height (feet)'),
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                          value!.isEmpty ? 'Please enter feet' : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _heightInchesController,
                          decoration: const InputDecoration(
                              labelText: 'Height (inches)'),
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                          value!.isEmpty ? 'Please enter inches' : null,
                        ),
                      ),
                    ],
                  ),
                  DropdownButtonFormField<String>(
                    value: _privacy,
                    decoration: const InputDecoration(labelText: 'Privacy'),
                    items: ['public', 'friends', 'private']
                        .map((privacy) => DropdownMenuItem<String>(
                      value: privacy,
                      child: Text(privacy),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _privacy = value ?? 'public';
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await _saveSettings();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Settings updated successfully!')),
                      );
                    },
                    child: const Text('Save Settings'),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _message,
                    style: const TextStyle(color: Colors.green),
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: _pickImage,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: _showLogoutDialog,
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}