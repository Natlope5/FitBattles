import 'package:fitbattles/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure all widgets are initialized
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp()); // Run the main app
}

// Main application widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitBattles', // App title
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5D6C8A), // Seed color for the theme
        ),
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.black, // Text color for body text
          displayColor: Colors.black, // Text color for display text
        ),
      ),
      home: const MyLoginPage(title: ''), // Set the home page to MyLoginPage
    );
  }
}

// Login page widget
class MyLoginPage extends StatefulWidget {
  const MyLoginPage({super.key, required this.title});
  final String title;

  @override
  State<MyLoginPage> createState() => _MyLoginPageState();
}

// State for MyLoginPage
class _MyLoginPageState extends State<MyLoginPage> {
  final TextEditingController _emailController = TextEditingController(); // Controller for email input
  final TextEditingController _passwordController = TextEditingController(); // Controller for password input
  final Logger logger = Logger(); // Logger for debugging

  // Function to authenticate the user
  Future<void> authenticateUser(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      ); // Sign in with email and password
      String uid = userCredential.user!.uid; // Get user ID
      String userEmail = userCredential.user!.email!; // Get user email

      if (!mounted) return; // Check if the widget is still mounted

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully logged in as $userEmail')),
      );

      // Navigate to home page with user details
      _navigateToHomePage(uid, userEmail);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return; // Check if the widget is still mounted

      // Log error details
      logger.e("Error code: ${e.code}, Message: ${e.message}");
      _showErrorDialog(_getErrorMessage(e)); // Show error dialog with specific message
    } catch (e) {
      if (!mounted) return; // Check if the widget is still mounted

      // Log unexpected error
      logger.e("Unexpected error: $e");
      _showErrorDialog('An unexpected error occurred: $e'); // Show general error dialog
    }
  }

  // Navigate to home page
  void _navigateToHomePage(String uid, String email) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage(uid: uid, email: email)), // Pass user details to HomePage
    );
  }

  // Get error message based on FirebaseAuthException
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.'; // User not found error message
      case 'wrong-password':
        return 'Wrong password provided for that user.'; // Wrong password error message
      default:
        return 'An error occurred. Please try again.'; // General error message
    }
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFEFEFEF),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(0xFFE62D2D), width: 2.0),
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: const Text('Error', style: TextStyle(color: Colors.black)),
          content: Text(message, style: const TextStyle(color: Colors.black)), // Display error message
          actions: <Widget>[
            TextButton(
              child: const Text('OK', style: TextStyle(color: Colors.black)), // OK button to dismiss dialog
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
              },
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
      ),
      body: Container(
        color: const Color(0xFF5D6C8A), // Background color for the body
        child: Center(
          child: SingleChildScrollView( // Enable scrolling for the login form
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 0), // Space above the title
                const SizedBox(height: 0), // Space below the title
                Image.asset(
                  'assets/logo2.png', // Logo image
                  height: 250, // Height of the logo
                ),
                const SizedBox(height: 20), // Space before input fields
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20), // Padding for the email input field
                  child: TextField(
                    controller: _emailController, // Assign email controller
                    decoration: InputDecoration(
                      labelText: 'Email', // Label for the email field
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0), // Rounded corners for the border
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Space between input fields
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20), // Padding for the password input field
                  child: TextField(
                    controller: _passwordController, // Assign password controller
                    obscureText: true, // Hide password input
                    decoration: InputDecoration(
                      labelText: 'Password', // Label for the password field
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0), // Rounded corners for the border
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Space before submit button
                SizedBox(
                  width: 200.0, // Width of the submit button
                  child: ElevatedButton(
                    onPressed: () {
                      String email = _emailController.text; // Get email from controller
                      String password = _passwordController.text; // Get password from controller
                      authenticateUser(email, password); // Attempt to authenticate user
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black, // Text color for button
                      backgroundColor: const Color(0xFF85C83E), // Background color for button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0), // Rounded corners for the button
                      ),
                    ),
                    child: const Text('Submit'), // Button text
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
