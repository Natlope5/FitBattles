import 'package:flutter/material.dart'; // Importing Flutter material package for UI components
import 'package:firebase_auth/firebase_auth.dart'; // Importing Firebase Auth for user authentication
import 'package:logger/logger.dart'; // Importing logger for logging purposes
import 'package:fitbattles/pages/home_page.dart'; // Importing HomePage for navigation after successful signup
import 'package:shared_preferences/shared_preferences.dart'; // Importing SharedPreferences package for managing sessions

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
      return; // Exit method if validation fails
    }

    setState(() {
      _isLoading = true; // Set loading state to true
    });

    try {
      // Attempt to create a new user using Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user email after successful signup
      await _saveUserEmail(userCredential.user!.email!);

      // Show success message upon successful signup
      _showSuccessMessage(userCredential.user!.email!);

      // Navigate to HomePage after successful signup
      _navigateToHomePage(userCredential.user!.uid, userCredential.user!.email!);
    } on FirebaseAuthException catch (e) {
      logger.e("Error code: ${e.code}, Message: ${e.message}"); // Log Firebase error
      _showErrorDialog(_getErrorMessage(e)); // Show error dialog with appropriate message
    } catch (e) {
      logger.e("Unexpected error: $e"); // Log unexpected errors
      _showErrorDialog('An unexpected error occurred: $e'); // Show generic error dialog
    } finally {
      setState(() {
        _isLoading = false; // Reset loading state
      });
    }
  }

  // Method to save user email in SharedPreferences
  Future<void> _saveUserEmail(String email) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email); // Store user email
  }

  // Method to show success message
  void _showSuccessMessage(String email) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Successfully registered as $email')),
    );
  }

  // Method to navigate to the home page
  void _navigateToHomePage(String uid, String email) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage(uid: uid, email: email, id: '',)), // Navigate to HomePage with user data
    );
  }

  // Method to get error messages based on Firebase error codes
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'The email is already in use. Please use another email.'; // Email already in use
      case 'weak-password':
        return 'The password provided is too weak.'; // Weak password
      default:
        return 'An error occurred. Please try again.'; // Default error message
    }
  }

  // Method to show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFEFEFEF), // Background color of dialog
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(0xFFE62D2D), width: 2.0), // Border color and width
            borderRadius: BorderRadius.circular(20.0), // Rounded corners
          ),
          title: const Text('Error', style: TextStyle(color: Colors.black)), // Title of the dialog
          content: Text(message, style: const TextStyle(color: Colors.black)), // Error message content
          actions: <Widget>[
            TextButton(
              child: const Text('OK', style: TextStyle(color: Colors.black)), // Button text
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  // Build method to render the signup page UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5D6C8A), // App bar color
        title: const Text('Sign Up'), // Title of the app bar
      ),
      body: Container(
        color: const Color(0xFF5D6C8A), // Background color for the signup page
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
                SizedBox(
                  width: 200.0, // Set width for the button
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () {
                      String email = _emailController.text; // Get email from input field
                      String password = _passwordController.text; // Get password from input field
                      createUser(email, password); // Call createUser method
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black, // Text color for button
                      backgroundColor: const Color(0xFF85C83E), // Background color for button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0), // Rounded corners for the button
                      ),
                    ),
                    child: _isLoading // Show loading indicator if loading
                        ? const CircularProgressIndicator() // Circular loading indicator
                        : const Text('Sign Up'), // Button text
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Center the row contents
                  children: <Widget>[
                    const Text("Already have an account? "), // Text prompt
                    GestureDetector(
                      onTap: () {
                        // Navigate to login page (not implemented here)
                      },
                      child: const Text(
                        'Log In',
                        style: TextStyle(
                          fontWeight: FontWeight.bold, // Bold text for link
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
