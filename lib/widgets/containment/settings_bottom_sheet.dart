import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitbattles/settings/ui/theme_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class SettingsBottomSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Make background transparent for backdrop effect
      builder: (BuildContext context) {
        return const SettingsContent();
      },
    );
  }
}

class SettingsContent extends StatefulWidget {
  const SettingsContent({super.key});

  @override
  SettingsContentState createState() => SettingsContentState();
}

class SettingsContentState extends State<SettingsContent> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  File? _image;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightFeetController = TextEditingController();
  final TextEditingController _heightInchesController = TextEditingController();

  String _privacy = 'public';
  String _avatarUrl = '';
  bool _darkMode = false;
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

    final profileRef = _firestore.collection('users').doc(uid).collection('settings').doc('profile');
    final appRef = _firestore.collection('users').doc(uid).collection('settings').doc('app');
    final notificationsRef = _firestore.collection('users').doc(uid).collection('settings').doc('notifications');

    final profileDoc = await profileRef.get();
    final appDoc = await appRef.get();
    final notificationsDoc = await notificationsRef.get();

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

    Map<String, dynamic> appData = {
      'darkMode': userData['darkMode'] ?? (appDoc.exists ? appDoc['darkMode'] : false),
    };

    await appRef.set(appData);

    Map<String, dynamic> notificationData = {
      'receiveNotifications': userData['receive_notifications'] ?? (notificationsDoc.exists ? notificationsDoc['receiveNotifications'] : true),
    };

    await notificationsRef.set(notificationData);

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
      final profileRef = _firestore.collection('users').doc(user.uid).collection('settings').doc('profile');
      final appRef = _firestore.collection('users').doc(user.uid).collection('settings').doc('app');
      final notificationsRef = _firestore.collection('users').doc(user.uid).collection('settings').doc('notifications');

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
        Map<String, dynamic> profileData = profileDoc.data() as Map<String, dynamic>;
        setState(() {
          nameController.text = profileData['name'] ?? '';
          _emailController.text = profileData['email'] ?? '';
          _ageController.text = (profileData['age'] ?? 0).toString();
          _weightController.text = (profileData['weight'] ?? 0.0).toString();
          int totalHeightInInches = profileData['heightInches'] ?? 0;
          _heightFeetController.text = (totalHeightInInches ~/ 12).toString();
          _heightInchesController.text = (totalHeightInInches % 12).toString();
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
        Map<String, dynamic> notificationsData = notificationsDoc.data() as Map<String, dynamic>;
        setState(() {
          _receiveNotifications = notificationsData['receiveNotifications'] ?? true;
        });
      }
    }
  }

  Future<String> _saveSettings() async {
    User? user = _auth.currentUser;
    if (user != null && _formKey.currentState!.validate()) {
      try {
        int totalHeightInInches = (int.parse(_heightFeetController.text) * 12) + int.parse(_heightInchesController.text);

        final profileRef = _firestore.collection('users').doc(user.uid).collection('settings').doc('profile');
        await profileRef.set({
          'name': nameController.text,
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
        final storageRef = FirebaseStorage.instance.ref().child('avatars/${DateTime.now().millisecondsSinceEpoch}.png');
        await storageRef.putFile(_image!);
        String imageUrl = await storageRef.getDownloadURL();

        setState(() {
          _avatarUrl = imageUrl;
        });

        User? user = _auth.currentUser;
        if (user != null) {
          final profileRef = _firestore.collection('users').doc(user.uid).collection('settings').doc('profile');
          await profileRef.update({'avatar': _avatarUrl});
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Avatar updated successfully')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image: ${e.toString()}')));
      }
    }
  }

  static Future<void> showLogoutDialog(BuildContext context, FirebaseAuth auth) async {
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
      await auth.signOut();
      if (Navigator.canPop(context)) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final textStyle = TextStyle(
      color: isDark ? Colors.white : Colors.black,
    );

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
    );

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        // Match the styling with gradient if not dark mode
        decoration: !isDark
            ? const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE7E9EF), Color(0xFF2C96CF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        )
            : BoxDecoration(
          color: Colors.black.withOpacity(0.6),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 24.0,
              right: 24.0,
              top: 16.0,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Top drag handle
                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black26,
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),

                  // Dark Mode Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Settings', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Text('Dark Mode', style: textStyle),
                          Switch(
                            value: _darkMode,
                            onChanged: (val) {
                              setState(() {
                                _darkMode = val;
                                themeProvider.toggleTheme();
                                // Make sure your ThemeProvider can handle this change.
                              });
                            },
                            activeColor: const Color(0xFF85C83E),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: inputDecoration.copyWith(labelText: 'Name'),
                          style: textStyle,
                          validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: inputDecoration.copyWith(labelText: 'Email'),
                          style: textStyle,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _ageController,
                          decoration: inputDecoration.copyWith(labelText: 'Age'),
                          keyboardType: TextInputType.number,
                          style: textStyle,
                          validator: (value) => value!.isEmpty ? 'Please enter your age' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _weightController,
                          decoration: inputDecoration.copyWith(labelText: 'Weight (lbs)'),
                          keyboardType: TextInputType.number,
                          style: textStyle,
                          validator: (value) => value!.isEmpty ? 'Please enter your weight' : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _heightFeetController,
                                decoration: inputDecoration.copyWith(labelText: 'Height (feet)'),
                                keyboardType: TextInputType.number,
                                style: textStyle,
                                validator: (value) => value!.isEmpty ? 'Please enter feet' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _heightInchesController,
                                decoration: inputDecoration.copyWith(labelText: 'Height (inches)'),
                                keyboardType: TextInputType.number,
                                style: textStyle,
                                validator: (value) => value!.isEmpty ? 'Please enter inches' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _privacy,
                          decoration: inputDecoration.copyWith(labelText: 'Privacy'),
                          style: textStyle,
                          dropdownColor: isDark ? Colors.grey[900] : Colors.white,
                          items: ['public', 'friends', 'private']
                              .map((privacy) => DropdownMenuItem<String>(
                            value: privacy,
                            child: Text(privacy, style: textStyle),
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
                              const SnackBar(content: Text('Settings updated successfully!')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF85C83E),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Save Settings'),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _message,
                          style: const TextStyle(color: Colors.green),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 30,
                            backgroundImage: _avatarUrl.isNotEmpty
                                ? NetworkImage(_avatarUrl)
                                : (_image != null ? FileImage(_image!) : const AssetImage('assets/images/placeholder_avatar.png') as ImageProvider),
                            child: Container(
                              alignment: Alignment.bottomRight,
                              child: const CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.camera_alt, size: 16, color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      showLogoutDialog(context, FirebaseAuth.instance);
                    },
                    child: const Text("Logout"),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}