import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:fitbattles/screens/home_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController(); // Controller for email input
  final TextEditingController _passwordController = TextEditingController(); // Controller for password input
  final Logger logger = Logger(); // Logger instance for debugging

  // Method to create a new user account
  Future<void> createUser(String email, String password) async {
    try {
      // Attempt to create a user with the provided email and password
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Retrieve user ID and email from the created user
      String uid = userCredential.user!.uid;
      String userEmail = userCredential.user!.email!;

      if (!mounted) return; // Check if the widget is still mounted

      // Navigate to the HomePage after successful signup
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(uid: uid, email: userEmail)),
      );
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase authentication exceptions
      logger.e("Error code: ${e.code}", e); // Log the error code
      _showErrorDialog(_getErrorMessage(e)); // Show error dialog with message
    } catch (e) {
      // Handle any other unexpected exceptions
      logger.e("Unexpected error: $e"); // Log unexpected errors
      _showErrorDialog('An unexpected error occurred. Please try again.'); // Show error dialog with generic message
    }
  }

  // Generate user-friendly error messages based on Firebase error codes
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'The email address is already in use by another account.'; // Error message for email already in use
      case 'weak-password':
        return 'The password provided is too weak.'; // Error message for weak password
      case 'invalid-email':
        return 'The email address is not valid.'; // Error message for invalid email
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled. Enable them in the Firebase console.'; // Error for operation not allowed
      default:
        return 'An error occurred. Please try again.'; // Generic error message
    }
  }

  // Show an error dialog to the user
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFEFEFEF), // Dialog background color
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(0xFFE62D2D), width: 2.0), // Border style for the dialog
            borderRadius: BorderRadius.circular(8.0), // Rounded corners for the dialog
          ),
          title: const Text('Error', style: TextStyle(color: Colors.black)), // Dialog title
          content: Text(message, style: const TextStyle(color: Colors.black)), // Dialog content
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog on button press
              },
              child: const Text('OK', style: TextStyle(color: Colors.black)), // Button text
            ),
          ],
        );
      },
    );
  }

  // Build the signup UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5D6C8A), // App bar color
        title: const Text('Sign Up'), // Title of the app bar
      ),
      body: Container(
        color: const Color(0xFF5D6C8A), // Background color for the body
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Padding around the content
          child: Center(
            child: SingleChildScrollView( // Enable scrolling for the content
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/logo.png', // Logo image for the signup page
                    height: 150, // Height of the logo
                  ),
                  const SizedBox(height: 20), // Space below the logo
                  TextField(
                    controller: _emailController, // Email input field
                    decoration: const InputDecoration(
                      labelText: 'Email', // Label for email field
                      fillColor: Colors.white, // Fill color for the input field
                      filled: true,
                      border: OutlineInputBorder(), // Border style for the input field
                    ),
                  ),
                  const SizedBox(height: 16), // Space between email and password fields
                  TextField(
                    controller: _passwordController, // Password input field
                    obscureText: true, // Obscure text for password input
                    decoration: const InputDecoration(
                      labelText: 'Password', // Label for password field
                      fillColor: Colors.white, // Fill color for the input field
                      filled: true,
                      border: OutlineInputBorder(), // Border style for the input field
                    ),
                  ),
                  const SizedBox(height: 32), // Space before the sign-up button
                  ElevatedButton(
                    onPressed: () {
                      createUser(_emailController.text, _passwordController.text); // Call createUser on button press
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black, // Text color for the button
                      backgroundColor: const Color(0xFF85C83E), // Button background color
                    ),
                    child: const Text('Sign Up'), // Button text
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
