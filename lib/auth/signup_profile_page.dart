import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import '../screens/home_page.dart';

class SignupProfilePage extends StatefulWidget {
  const SignupProfilePage({super.key, required String heading});

  @override
  SignupProfilePageState createState() => SignupProfilePageState();
}

class SignupProfilePageState extends State<SignupProfilePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  bool _shareLocation = false;
  bool _receiveNotifications = false;
  File? _profileImage;

  // Method to pick an image from the gallery
  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      } else {
        _showSnackBar('No image selected.');
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e');
    }
  }

  // Method to show a snackbar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Method to create a user profile and store it in Firestore
  Future<void> _createUserProfile(String userId, String imageUrl) async {
    Map<String, dynamic> userProfile = {
      'username': _usernameController.text.trim(),
      'email': _emailController.text.trim(),
      'age': int.tryParse(_ageController.text),
      'weight': double.tryParse(_weightController.text),
      'height': double.tryParse(_heightController.text),
      'image_url': imageUrl,
      'share_location': _shareLocation,
      'receive_notifications': _receiveNotifications,
    };

    await FirebaseFirestore.instance.collection('users').doc(userId).set(userProfile);
  }

  // Method to save user email in SharedPreferences
  Future<void> _saveUserEmail(String email) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
  }

  // Method to navigate to HomePage after successful signup
  void _navigateToHomePage(String uid, String email) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(id: uid, email: email, bio: '', name: '', uid: '',),
      ),
    );
  }

  // Method to upload the profile image to Firebase Storage and return the URL
  Future<String?> _uploadProfileImage(String userId) async {
    if (_profileImage != null) {
      try {
        final storageRef = FirebaseStorage.instance.ref().child('profile_images/$userId');
        final uploadTask = await storageRef.putFile(_profileImage!);
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        return downloadUrl;
      } catch (e) {
        _showSnackBar('Failed to upload image: $e');
      }
    }
    return null;
  }

  // Method to handle signup and profile creation
  Future<void> _handleSignup() async {
    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showSnackBar('Please fill in all fields.');
      return;
    }

    try {
      // Create user with email and password
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        // Upload profile image and get its URL
        String? imageUrl = await _uploadProfileImage(user.uid);

        if (imageUrl != null) {
          // Create user profile in Firestore
          await _createUserProfile(user.uid, imageUrl);

          // Save email locally using SharedPreferences
          await _saveUserEmail(user.email!);

          // Navigate to home page
          _navigateToHomePage(user.uid, user.email!);
        } else {
          _showSnackBar('Profile image upload failed');
        }
      }
    } catch (e) {
      _showSnackBar('Signup failed: $e');
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Signup Profile')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                child: _profileImage == null
                    ? Icon(Icons.add_a_photo, size: 50)
                    : null,
              ),
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Age'),
            ),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Weight (kg)'),
            ),
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Height (cm)'),
            ),
            SwitchListTile(
              title: Text('Share Location'),
              value: _shareLocation,
              onChanged: (bool value) {
                setState(() {
                  _shareLocation = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Receive Notifications'),
              value: _receiveNotifications,
              onChanged: (bool value) {
                setState(() {
                  _receiveNotifications = value;
                });
              },
            ),
            ElevatedButton(
              onPressed: _handleSignup,
              child: Text('Signup'),
            ),
          ],
        ),
      ),
    );
  }
}
