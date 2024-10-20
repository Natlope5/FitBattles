import 'package:flutter/material.dart'; // Importing Flutter material package for UI components
import 'package:firebase_auth/firebase_auth.dart'; // Importing Firebase Auth for user authentication
import 'package:logger/logger.dart'; // Importing logger for logging purposes
import 'package:cloud_firestore/cloud_firestore.dart'; // Importing Cloud Firestore for storing user data
import 'package:firebase_storage/firebase_storage.dart'; // Importing Firebase Storage for uploading profile images
import 'package:image_picker/image_picker.dart'; // Importing Image Picker for selecting images
import 'dart:io'; // Importing Dart IO for File handling
import 'package:shared_preferences/shared_preferences.dart'; // Importing SharedPreferences package for managing sessions
import 'package:fitbattles/screens/home_page.dart'; // Importing HomePage for navigation after successful signup

// Stateful widget for the Signup and Profile Page
class SignupProfilePage extends StatefulWidget {
  const SignupProfilePage({super.key, required String heading}); // Constructor

  @override
  State<SignupProfilePage> createState() => _SignupProfilePageState(); // Creating the state for SignupProfilePage
}

class _SignupProfilePageState extends State<SignupProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance
  final Logger logger = Logger(); // Logger instance for logging errors

  // Controllers for form fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  File? _image; // Variable to store the selected image
  final ImagePicker _picker = ImagePicker(); // ImagePicker instance
  bool _isLoading = false; // Track loading state for the signup process
  bool _shareLocation = false; // Checkbox for sharing location
  bool _receiveNotifications = false; // Checkbox for receiving notifications

  // Method to pick an image
  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      } else {
        _showSnackBar('No image selected.');
      }
    } catch (e) {
      _showSnackBar('Failed to pick image: $e');
    }
  }

  // Method to register a new user and upload profile image
  Future<void> _registerAndUploadData() async {
    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _heightController.text.isEmpty) {
      _showSnackBar('Please fill all fields.');
      return;
    }

    if (_image == null) {
      _showSnackBar('Please select a profile image.');
      return;
    }

    setState(() {
      _isLoading = true; // Set loading state to true
    });

    try {
      User? user = await _registerUser(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _image!,
      );

      if (user != null) {
        String userId = user.uid;
        String? imageUrl = user.photoURL ?? ''; // Ensure a non-null value for imageUrl

        // Save profile data to Firestore
        await _createUserProfile(userId, imageUrl);

        // Save user email in SharedPreferences
        await _saveUserEmail(user.email!);

        _showSnackBar('Account created successfully! Navigating to Home.');

        // Navigate to HomePage after delay
        await Future.delayed(const Duration(seconds: 2));
        _navigateToHomePage(user.uid, user.email!);
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false; // Reset loading state
      });
    }
  }

  // Method to register user and upload profile image
  Future<User?> _registerUser(String email, String password, File profileImage) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        // Upload profile image to Firebase Storage and get URL
        String? photoUrl = await _uploadProfileImage(profileImage);

        // Update Firebase user profile with display name and photo URL
        await user.updateProfile(
          displayName: _usernameController.text.trim(), // Use username as display name
          photoURL: photoUrl, // Set the uploaded image URL
        );
        await user.reload();
      }
      return user;
    } on FirebaseAuthException catch (e) {
      _showSnackBar('Error: ${e.message}');
      return null;
    } catch (e) {
      _showSnackBar('General error: $e');
      return null;
    }
  }

  // Upload the image to Firebase Storage and return the download URL
  Future<String?> _uploadProfileImage(File profileImage) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance.ref().child('user_profiles/$fileName');

      await storageRef.putFile(profileImage);
      String downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      _showSnackBar('Image upload failed: $e');
      return null;
    }
  }

  // Method to create the user profile in Firestore
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
    await prefs.setString('user_email', email); // Store user email
  }

  // Method to show a snackbar for messages
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // Method to navigate to the home page
  void _navigateToHomePage(String uid, String email) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage(uid: uid, email: email, id: '',)), // Navigate to HomePage with user data
    );
  }

  @override
  void dispose() {
    // Dispose controllers to free up resources
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  // Build method to render the signup and profile page UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up and Create Profile'), // Title of the app bar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'), // Label for username input
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'), // Label for email input
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'), // Label for password input
              obscureText: true,
            ),
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: 'Age'), // Label for age input
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _weightController,
              decoration: const InputDecoration(labelText: 'Weight (lbs)'), // Label for weight input
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _heightController,
              decoration: const InputDecoration(labelText: 'Height (cm)'), // Label for height input
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image'), // Button to pick an image
            ),
            if (_image != null) Image.file(_image!, height: 150), // Display selected image
            CheckboxListTile(
              title: const Text('Share Location'), // Checkbox for sharing location
              value: _shareLocation,
              onChanged: (value) {
                setState(() {
                  _shareLocation = value!; // Update state for share location
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Receive Notifications'), // Checkbox for receiving notifications
              value: _receiveNotifications,
              onChanged: (value) {
                setState(() {
                  _receiveNotifications = value!; // Update state for notifications
                });
              },
            ),
            const SizedBox(height: 20), // Space between elements
            if (_isLoading)
              const Center(child: CircularProgressIndicator()) // Show loading indicator if processing
            else
              ElevatedButton(
                onPressed: _registerAndUploadData, // Trigger the registration method
                child: const Text('Sign Up'), // Button for signup
              ),
          ],
        ),
      ),
    );
  }
}
