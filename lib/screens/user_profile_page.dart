import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key, required this.heading});

  final String heading;

  @override
  UserProfilePageState createState() => UserProfilePageState();
}

class UserProfilePageState extends State<UserProfilePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  File? _image;
  final ImagePicker _picker = ImagePicker();

  bool _shareLocation = false;
  bool _receiveNotifications = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadData() async {
    // Check if all fields are filled
    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _heightController.text.isEmpty) {
      _showSnackBar('Please fill all fields.');
      return;
    }

    try {
      // Create the user in Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: 'defaultPassword', // Replace with a real password or create a UI for password entry
      );

      String userId = userCredential.user?.uid ?? '';

      String imageUrl = await _uploadImageToFirebase(); // Upload image first

      await _createUserProfile(userId, imageUrl); // Pass image URL to the profile creation function
      _showSnackBar('Account created successfully! Now navigating to your home page...');

      // Add a delay to show the message before navigating
      await Future.delayed(Duration(seconds: 2)); // Adjust delay as needed

      // Navigate to home on success
      _navigateToHome();
    } catch (e) {
      _showSnackBar('Error creating account: ${e.toString()}');
    }
  }

  // Function to handle navigation to the home page
  void _navigateToHome() {
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  // Example of a function to create the user profile
  Future<void> _createUserProfile(String userId, String imageUrl) async {
    Map<String, dynamic> userProfile = {
      'username': _usernameController.text,
      'email': _emailController.text,
      'age': int.tryParse(_ageController.text),
      'weight': double.tryParse(_weightController.text),
      'height': double.tryParse(_heightController.text),
      'image_url': imageUrl, // Use the uploaded image URL
      'share_location': _shareLocation,
      'receive_notifications': _receiveNotifications,
    };

    // Save user profile data to Firestore
    await FirebaseFirestore.instance.collection('users').doc(userId).set(userProfile);
  }

  Future<String> _uploadImageToFirebase() async {
    if (_image == null) {
      return ''; // Return an empty string if no image is selected
    }

    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageRef = FirebaseStorage.instance.ref().child('user_profiles/$fileName');

    await storageRef.putFile(_image!);
    String downloadUrl = await storageRef.getDownloadURL();
    return downloadUrl;
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.heading),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _weightController,
              decoration: const InputDecoration(labelText: 'Weight (lbs)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _heightController,
              decoration: const InputDecoration(labelText: 'Height (cm)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image'),
            ),
            const SizedBox(height: 20),
            if (_image != null)
              Image.file(
                _image!,
                height: 150,
              ),
            const SizedBox(height: 20),
            CheckboxListTile(
              title: const Text('Share Location'),
              value: _shareLocation,
              onChanged: (bool? value) {
                setState(() {
                  _shareLocation = value ?? false;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Receive Goal Notifications'),
              value: _receiveNotifications,
              onChanged: (bool? value) {
                setState(() {
                  _receiveNotifications = value ?? false;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadData,
              child: const Text('Create Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
