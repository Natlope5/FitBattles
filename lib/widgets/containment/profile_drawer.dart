import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitbattles/settings/ui/theme_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileDrawer extends StatefulWidget {
  const ProfileDrawer({super.key});

  @override
  State<ProfileDrawer> createState() => _ProfileDrawerState();
}

class _ProfileDrawerState extends State<ProfileDrawer> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  File? _image;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  int _selectedAge = 25;
  int _selectedWeight = 150;
  int _selectedHeightInInches = 66; // default 5'6"
  int _selectedPrivacyIndex = 0; // 'public' by default

  final List<String> _privacyOptions = ['public', 'friends', 'private'];

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
      'receiveNotifications':
      userData['receive_notifications'] ?? (notificationsDoc.exists ? notificationsDoc['receiveNotifications'] : true),
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
          _selectedAge = (profileData['age'] ?? 25) is int ? profileData['age'] : 25;

          int weight = (profileData['weight'] ?? 150).toDouble().round();
          if (weight < 100) weight = 100;
          if (weight > 300) weight = 300;
          weight = ((weight / 5).round()) * 5;
          _selectedWeight = weight;

          int totalHeightInInches = profileData['heightInches'] ?? (5 * 12 + 6);
          if (totalHeightInInches < 48) totalHeightInInches = 48;
          if (totalHeightInInches > 84) totalHeightInInches = 84;
          _selectedHeightInInches = totalHeightInInches;

          String privacy = profileData['privacy'] ?? 'public';
          _selectedPrivacyIndex = _privacyOptions.indexOf(privacy);
          if (_selectedPrivacyIndex == -1) _selectedPrivacyIndex = 0;

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
        final profileRef = _firestore.collection('users').doc(user.uid).collection('settings').doc('profile');
        await profileRef.set({
          'name': nameController.text,
          'email': _emailController.text,
          'age': _selectedAge,
          'weight': _selectedWeight.toDouble(),
          'heightInInches': _selectedHeightInInches,
          'privacy': _privacyOptions[_selectedPrivacyIndex],
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
      fillColor: isDark ? Colors.grey[800] : Colors.grey[300],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );

    final ageItems = List<DropdownMenuItem<int>>.generate(
      83,
          (index) => DropdownMenuItem(value: index + 18, child: Text('${index + 18}', style: textStyle)),
    );

    final weightItems = List<DropdownMenuItem<int>>.generate(
      41,
          (index) {
        int weightVal = 100 + (index * 5);
        return DropdownMenuItem(value: weightVal, child: Text('$weightVal lbs', style: textStyle));
      },
    );

    final heightItems = List<DropdownMenuItem<int>>.generate(
      84 - 48 + 1,
          (index) {
        int inches = 48 + index;
        int ft = inches ~/ 12;
        int inch = inches % 12;
        return DropdownMenuItem(value: inches, child: Text('${ft}ft ${inch}in', style: textStyle));
      },
    );

    final privacyItems = _privacyOptions
        .map((privacy) => DropdownMenuItem<String>(
      value: privacy,
      child: Text(privacy, style: textStyle),
    ))
        .toList();

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Drawer(
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          child: SafeArea(
            // We use a Column with Expanded so that we can have a footer at the bottom without overflow
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Section (Scrollable)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[300],
                                image: _avatarUrl.isNotEmpty || _image != null
                                    ? DecorationImage(
                                  image: _avatarUrl.isNotEmpty
                                      ? NetworkImage(_avatarUrl)
                                      : FileImage(_image!) as ImageProvider,
                                  fit: BoxFit.cover,
                                )
                                    : null,
                              ),
                              child: _avatarUrl.isEmpty && _image == null
                                  ? Image.asset('assets/images/placeholder_avatar.png', fit: BoxFit.cover)
                                  : Align(
                                alignment: Alignment.bottomRight,
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: isDark ? Colors.grey[200] : Colors.white,
                                  child: const Icon(Icons.camera_alt, size: 16, color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        Text('Profile', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Name', style: textStyle),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: nameController,
                                decoration: inputDecoration.copyWith(labelText: null),
                                style: textStyle,
                                validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                              ),
                              const SizedBox(height: 8),
                              Text('Email', style: textStyle),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _emailController,
                                decoration: inputDecoration.copyWith(labelText: null),
                                style: textStyle,
                              ),
                              const SizedBox(height: 16),
                              // 2x2 Grid for privacy, age, weight, height
                              GridView.count(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 0,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Privacy', style: textStyle),
                                      const SizedBox(height: 4),
                                      DropdownButtonFormField<String>(
                                        value: _privacyOptions[_selectedPrivacyIndex],
                                        decoration: inputDecoration.copyWith(labelText: null),
                                        style: textStyle,
                                        dropdownColor: isDark ? Colors.grey[900] : Colors.white,
                                        items: privacyItems,
                                        onChanged: (value) {
                                          if (value != null) {
                                            setState(() {
                                              _selectedPrivacyIndex = _privacyOptions.indexOf(value);
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Age', style: textStyle),
                                      const SizedBox(height: 4),
                                      DropdownButtonFormField<int>(
                                        value: _selectedAge,
                                        decoration: inputDecoration.copyWith(labelText: null),
                                        style: textStyle,
                                        items: ageItems,
                                        onChanged: (val) {
                                          if (val != null) {
                                            setState(() {
                                              _selectedAge = val;
                                            });
                                          }
                                        },
                                        validator: (value) => value == null ? 'Please select age' : null,
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Weight', style: textStyle),
                                      const SizedBox(height: 4),
                                      DropdownButtonFormField<int>(
                                        value: _selectedWeight,
                                        decoration: inputDecoration.copyWith(labelText: null),
                                        style: textStyle,
                                        items: weightItems,
                                        onChanged: (val) {
                                          if (val != null) {
                                            setState(() {
                                              _selectedWeight = val;
                                            });
                                          }
                                        },
                                        validator: (value) => value == null ? 'Please select weight' : null,
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Height', style: textStyle),
                                      const SizedBox(height: 4),
                                      DropdownButtonFormField<int>(
                                        value: _selectedHeightInInches,
                                        decoration: inputDecoration.copyWith(labelText: null),
                                        style: textStyle,
                                        items: heightItems,
                                        onChanged: (val) {
                                          if (val != null) {
                                            setState(() {
                                              _selectedHeightInInches = val;
                                            });
                                          }
                                        },
                                        validator: (value) => value == null ? 'Select height' : null,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (_message.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    _message,
                                    style: const TextStyle(color: Colors.green),
                                  ),
                                ),
                              Row(
                                children: [
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
                                  const Spacer(),
                                  ElevatedButton(
                                    onPressed: () async {
                                      String result = await _saveSettings();
                                      if (mounted && result.contains('successfully')) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Settings updated successfully!')),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: const Color(0xFF85C83E),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: const Text('Save'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Bottom Row (Non-scrollable)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed('/notificationsSettings');
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.notifications,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            const SizedBox(width: 8),
                            Text('Notifications', style: textStyle),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _darkMode ? Icons.nightlight_round : Icons.wb_sunny,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            _darkMode = !_darkMode;
                            Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
