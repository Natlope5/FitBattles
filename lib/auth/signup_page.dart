import 'package:flutter/material.dart'; // Importing Flutter material package for UI components
import 'package:firebase_auth/firebase_auth.dart'; // Importing Firebase Auth for user authentication
import 'package:logger/logger.dart'; // Importing logger for logging purposes
import 'package:fitbattles/screens/home_page.dart'; // Importing HomePage for navigation after successful signup

// Stateful widget for the Signup page
class SignupPage extends StatefulWidget {
  const SignupPage({super.key}); // Constructor

  @override
  State<SignupPage> createState() => _SignupPageState(); // Creating the state for SignupPage
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController(); // Controller for email input
  final TextEditingController _passwordController = TextEditingController(); // Controller for password input
  final Logger logger = Logger(); // Logger instance for logging errors
  bool _isLoading = false; // Track loading state for the signup process

  // Method to create a new user
  Future<void> createUser(String email, String password) async {
    // Check if email or password is empty
    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog('Please fill in all fields.'); // Show error if fields are empty
      return; // Exit the method early
    }

    setState(() {
      _isLoading = true; // Set loading state to true
    });

    try {
      // Attempt to create a user with email and password
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid; // Get the unique ID of the created user
      String userEmail = userCredential.user!.email!; // Get the email of the created user

      if (!mounted) return; // Check if the widget is still mounted

      // Navigate to HomePage after successful signup
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(uid: uid, email: userEmail)),
      );
    } on FirebaseAuthException catch (e) {
      logger.e("Error code: ${e.code}", e); // Log the error
      _showErrorDialog(_getErrorMessage(e)); // Show appropriate error message
    } catch (e) {
      logger.e("Unexpected error: $e"); // Log any unexpected errors
      _showErrorDialog('An unexpected error occurred. Please try again.'); // Show generic error message
    } finally {
      setState(() {
        _isLoading = false; // Reset loading state after operation
      });
    }
  }

  // Method to get a user-friendly error message based on Firebase exception
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'The email address is already in use by another account.'; // Specific error message
      case 'weak-password':
        return 'The password provided is too weak.'; // Specific error message
      case 'invalid-email':
        return 'The email address is not valid.'; // Specific error message
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled. Enable them in the Firebase console.'; // Specific error message
      default:
        return 'An error occurred. Please try again.'; // Generic error message
    }
  }

  // Method to show an error dialog with a message
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFEFEFEF),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(0xFFE62D2D), width: 2.0), // Border styling for the dialog
            borderRadius: BorderRadius.circular(8.0), // Rounded corners
          ),
          title: const Text('Error', style: TextStyle(color: Colors.black)), // Dialog title
          content: Text(message, style: const TextStyle(color: Colors.black)), // Dialog content
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK', style: TextStyle(color: Colors.black)), // OK button
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5D6C8A), // App bar color
        title: const Text('Sign Up'), // App bar title
      ),
      body: Container(
        color: const Color(0xFF5D6C8A), // Background color
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Padding around the content
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Center the column vertically
                children: <Widget>[
                  Image.asset(
                    'assets/image/logo.png', // Logo image
                    height: 150, // Height of the logo
                  ),
                  const SizedBox(height: 20), // Space between elements
                  TextField(
                    controller: _emailController, // Controller for email input
                    decoration: const InputDecoration(
                      labelText: 'Email', // Label for email input
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(), // Outline border for input
                    ),
                  ),
                  const SizedBox(height: 16), // Space between elements
                  TextField(
                    controller: _passwordController, // Controller for password input
                    obscureText: true, // Obscure text for password
                    decoration: const InputDecoration(
                      labelText: 'Password', // Label for password input
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(), // Outline border for input
                    ),
                  ),
                  const SizedBox(height: 32), // Space between elements
                  _isLoading // Show loading indicator if true
                      ? const CircularProgressIndicator() // Circular loading spinner
                      : ElevatedButton(
                    onPressed: () {
                      createUser(_emailController.text, _passwordController.text); // Call createUser method on press
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: const Color(0xFF85C83E), // Button color
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
