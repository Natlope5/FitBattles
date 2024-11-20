import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required String heading});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  File? _image;

  String _avatarUrl = '';
  String _name = '';
  String _email = '';
  int _age = 0;
  double _weight = 0.0;
  String _heightFeet = '0';
  String _heightInches = '0';
  String _visibility = 'public';

  String _message = '';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  Future<void> _loadUserSettings() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        if (mounted) {
          setState(() {
            _name = userDoc['name'] ?? '';
            _email = userDoc['email'] ?? '';
            _age = userDoc['age'] ?? 0;
            _weight = userDoc['weight'] ?? 0.0;
            int totalHeightInInches = userDoc['height_inches'] ?? 0;
            _heightFeet = (totalHeightInInches ~/ 12).toString();
            _heightInches = (totalHeightInInches % 12).toString();
            _visibility = userDoc['visibility'] ?? 'public';
            _avatarUrl = userDoc['avatar'] ?? '';
          });
        }
      }
    }
  }

  Future<String> _saveSettings() async {
    User? user = _auth.currentUser;
    if (user != null && _formKey.currentState!.validate()) {
      try {
        int totalHeightInInches = (int.parse(_heightFeet) * 12) + int.parse(_heightInches);

        DocumentReference userDoc = _firestore.collection('users').doc(user.uid);
        bool docExists = (await userDoc.get()).exists;

        if (docExists) {
          await userDoc.update({
            'name': _name,
            'email': _email,
            'age': _age,
            'weight': _weight,
            'height_inches': totalHeightInInches,
            'visibility': _visibility,
            'avatar': _avatarUrl,
          });
        } else {
          await userDoc.set({
            'name': _name,
            'email': _email,
            'age': _age,
            'weight': _weight,
            'height_inches': totalHeightInInches,
            'visibility': _visibility,
            'avatar': _avatarUrl,
          });
        }

        await _loadUserSettings();
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

        if (mounted) {
          setState(() {
            _avatarUrl = imageUrl;
          });
        }

        User? user = _auth.currentUser;
        if (user != null) {
          await _firestore.collection('users').doc(user.uid).update({
            'avatar': _avatarUrl,
          });
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Avatar updated successfully')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to upload image: ${e.toString()}')));
        }
      }
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
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
                    initialValue: _name,
                    decoration: InputDecoration(labelText: 'Name'),
                    onChanged: (value) => setState(() => _name = value),
                    validator: (value) =>
                    value!.isEmpty ? 'Please enter your name' : null,
                  ),
                  TextFormField(
                    initialValue: _email,
                    decoration: InputDecoration(labelText: 'Email'),
                    onChanged: (value) => setState(() => _email = value),
                  ),
                  TextFormField(
                    initialValue: _age.toString(),
                    decoration: InputDecoration(labelText: 'Age'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) =>
                        setState(() => _age = int.tryParse(value) ?? 0),
                    validator: (value) =>
                    value!.isEmpty ? 'Please enter your age' : null,
                  ),
                  TextFormField(
                    initialValue: _weight.toString(),
                    decoration: InputDecoration(labelText: 'Weight (lbs)'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) =>
                        setState(() => _weight = double.tryParse(value) ?? 0.0),
                    validator: (value) =>
                    value!.isEmpty ? 'Please enter your weight' : null,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: _heightFeet,
                          decoration: InputDecoration(labelText: 'Height (feet)'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => setState(() => _heightFeet = value),
                          validator: (value) =>
                          value!.isEmpty ? 'Please enter feet' : null,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          initialValue: _heightInches,
                          decoration: InputDecoration(labelText: 'Height (inches)'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => setState(() => _heightInches = value),
                          validator: (value) =>
                          value!.isEmpty ? 'Please enter inches' : null,
                        ),
                      ),
                    ],
                  ),
                  DropdownButtonFormField<String>(
                    value: _visibility,
                    decoration: InputDecoration(labelText: 'Visibility'),
                    items: ['public', 'private']
                        .map((visibility) => DropdownMenuItem<String>(
                      value: visibility,
                      child: Text(visibility),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _visibility = value ?? 'public';
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveSettings,
                    child: Text('Save Settings'),
                  ),
                  SizedBox(height: 20),
                  Text(
                    _message,
                    style: TextStyle(color: Colors.green),
                  ),
                  IconButton(
                    icon: Icon(Icons.camera_alt),
                    onPressed: _pickImage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
