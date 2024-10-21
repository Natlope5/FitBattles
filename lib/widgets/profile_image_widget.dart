import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:fitbattles/settings/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../main.dart';

class ProfileImageWidget extends StatefulWidget {
  const ProfileImageWidget({super.key});

  @override
  ProfileImageWidgetState createState() => ProfileImageWidgetState();
}

class ProfileImageWidgetState extends State<ProfileImageWidget> {
  File? _image;
  String? photoURL;
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    final pickedFile = await _pickImage();
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isUploading = true;
      });

      final userId = FirebaseAuth.instance.currentUser?.uid; // Get the user ID
      if (userId == null) {
        logger.e("User not authenticated.");
        return; // Handle user not authenticated
      }

      try {
        String downloadURL = await _uploadToFirebase(_image!);
        await _saveImageURL(downloadURL, userId);

        setState(() {
          photoURL = downloadURL;
          _isUploading = false;
        });
      } catch (e) {
        setState(() {
          _isUploading = false;
        });
        logger.e("Error uploading image: $e");
      }
    }
  }

  Future<String> _uploadToFirebase(File image) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('profile_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

    final uploadTask = await storageRef.putFile(image);
    String downloadURL = await uploadTask.ref.getDownloadURL();
    return downloadURL;
  }

  Future<void> _saveImageURL(String downloadURL, String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'photoURL': downloadURL});
    } catch (e) {
      logger.e("Error saving image URL: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final userId = FirebaseAuth.instance.currentUser?.uid; // Get the user ID
    if (userId == null) {
      logger.e("User not authenticated.");
      return; // Handle user not authenticated
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      setState(() {
        photoURL = doc.data()?['photoURL'];
      });
    } catch (e) {
      logger.e("Error loading profile image: $e");
    }
  }

  Future<XFile?> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    return await picker.pickImage(source: ImageSource.gallery);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Column(
      children: [
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _pickAndUploadImage,
          child: CircleAvatar(
            radius: 40,
            backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.grey[300],
            backgroundImage: _image != null
                ? FileImage(_image!)
                : (photoURL != null ? NetworkImage(photoURL!) : AssetImage('assets/default_profile.png')),
            child: _isUploading
                ? CircularProgressIndicator()
                : (_image == null && photoURL == null ? Icon(Icons.add_a_photo, color: Colors.white, size: 30) : null),
          ),
        ),
      ],
    );
  }
}
