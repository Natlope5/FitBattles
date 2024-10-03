import 'package:flutter/material.dart'; // Importing Flutter material package
import 'package:firebase_auth/firebase_auth.dart'; // Importing Firebase Auth for user authentication
import 'package:logger/logger.dart'; // Importing Logger for error logging
import 'package:fitbattles/screens/home_page.dart'; // Importing the home page to navigate after login
import 'package:fitbattles/auth/signup_page.dart'; // Import your SignUp page here
import 'package:fitbattles/auth/session_manager.dart'; // Import your SessionManager

// Login page widget
class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title}); // Constructor with title parameter
  final String title; // Title of the login page

  @override
  State<LoginPage> createState() => _LoginPageState(); // State management for the login page
}

// State class for login page
class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController(); // Controller for email input
  final TextEditingController _passwordController = TextEditingController(); // Controller for password input
  final Logger logger = Logger(); // Logger instance for logging errors
  String? errorMessage; // Variable to hold error messages
  final SessionManager _sessionManager = SessionManager(); // Instance of SessionManager

  // Method to authenticate user
  Future<void> authenticateUser(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      errorMessage = 'Email and password cannot be empty.'; // Set error message for empty fields
      setState(() {}); // Trigger UI update
      return;
    }

    try {
      // Attempt to sign in using Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Retrieve user ID and email upon successful authentication
      String uid = userCredential.user!.uid; // User ID
      String userEmail = userCredential.user!.email!; // User email

      // Store the user email in shared preferences using SessionManager
      await _sessionManager.saveUserEmail(userEmail); // Call to SessionManager to handle session

      // Clear error message and navigate to home page
      errorMessage = null;
      _navigateToHomePage(uid, userEmail);
    } on FirebaseAuthException catch (e) {
      logger.e("Error code: ${e.code}, Message: ${e.message}"); // Log Firebase error
      errorMessage = _getErrorMessage(e); // Set error message
      setState(() {}); // Trigger UI update
    } catch (e) {
      logger.e("Unexpected error: $e"); // Log unexpected errors
      errorMessage = 'An unexpected error occurred: $e'; // Set generic error message
      setState(() {}); // Trigger UI update
    }
  }

  // Method to navigate to the home page
  void _navigateToHomePage(String uid, String email) {
    if (!mounted) return; // Ensure widget is still mounted
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage(uid: uid, email: email)), // Navigate to home page with user data
    );
  }

  // Method to get error messages based on Firebase error codes
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.'; // Error for no user found
      case 'wrong-password':
        return 'Wrong password provided for that user.'; // Error for wrong password
      default:
        return 'An error occurred. Please try again.'; // Default error message
    }
  }

  // Build method to render the login page UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5D6C8A), // App bar color
        title: Text(widget.title), // Title of the app bar
      ),
      body: Container(
        color: const Color(0xFF5D6C8A), // Background color for the login page
        child: Center(
          child: SingleChildScrollView( // Enable scrolling for the content
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 0),
                Image.asset( // Logo image for the app
                  'assets/images/logo2.png',
                  height: 250,
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20), // Padding for input fields
                  child: TextField(
                    controller: _emailController, // Controller for email input
                    decoration: InputDecoration(
                      labelText: 'Email', // Label for email input
                      fillColor: Colors.white, // Background color of input field
                      filled: true, // Fill background color
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0), // Rounded corners for the input field
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20), // Padding for input fields
                  child: TextField(
                    controller: _passwordController, // Controller for password input
                    obscureText: true, // Hide password input
                    decoration: InputDecoration(
                      labelText: 'Password', // Label for password input
                      fillColor: Colors.white, // Background color of input field
                      filled: true, // Fill background color
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0), // Rounded corners for the input field
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Call authenticateUser without using context
                    authenticateUser(_emailController.text, _passwordController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF85C83E), // Button background color
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20), // Button padding
                  ),
                  child: const Text('Fitbattles'), // Button text
                ),
                const SizedBox(height: 20),
                // Display error message if any
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red), // Error message style
                    ),
                  ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    // Navigate to signup page without using context
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignupPage()),
                    );
                  },
                  child: const Text(
                    'Don\'t have an account? Sign Up',
                    style: TextStyle(color: Colors.black), // Text style for signup link
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
