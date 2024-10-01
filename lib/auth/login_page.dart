import 'package:fitbattles/screens/home_page.dart'; // Importing the home page to navigate after login
import 'package:flutter/material.dart'; // Importing Flutter material package for UI components
import 'package:firebase_core/firebase_core.dart'; // Importing Firebase core for initialization
import 'package:firebase_auth/firebase_auth.dart'; // Importing Firebase Auth for user authentication
import 'package:logger/logger.dart'; // Importing Logger for error logging

// Main function to initialize Firebase and run the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensuring widgets are initialized before Firebase initialization
  await Firebase.initializeApp(); // Initializing Firebase
  runApp(const MyApp()); // Running the main app widget
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
          seedColor: const Color(0xFF5D6C8A), // Defining the color scheme for the app
        ),
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.black, // Setting body text color
          displayColor: Colors.black, // Setting display text color
        ),
      ),
      home: const MyLoginPage(title: 'FitBattles Login'), // Setting the login page as the home widget
    );
  }
}

// Login page widget
class MyLoginPage extends StatefulWidget {
  const MyLoginPage({super.key, required this.title}); // Constructor with title parameter
  final String title; // Title of the login page

  @override
  State<MyLoginPage> createState() => _MyLoginPageState(); // State management for the login page
}

// State class for login page
class _MyLoginPageState extends State<MyLoginPage> {
  final TextEditingController _emailController = TextEditingController(); // Controller for email input
  final TextEditingController _passwordController = TextEditingController(); // Controller for password input
  final Logger logger = Logger(); // Logger instance for logging errors

  // Method to authenticate user
  Future<void> authenticateUser(String email, String password) async {
    try {
      // Attempt to sign in using Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Retrieve user ID and email upon successful authentication
      String uid = userCredential.user!.uid; // User ID
      String userEmail = userCredential.user!.email!; // User email

      if (!mounted) return; // Ensure widget is still mounted

      // Show success message upon successful login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully logged in as $userEmail')),
      );

      _navigateToHomePage(uid, userEmail); // Navigate to home page
    } on FirebaseAuthException catch (e) {
      if (!mounted) return; // Ensure widget is still mounted
      logger.e("Error code: ${e.code}, Message: ${e.message}"); // Log Firebase error
      _showErrorDialog(_getErrorMessage(e)); // Show error dialog with appropriate message
    } catch (e) {
      if (!mounted) return; // Ensure widget is still mounted
      logger.e("Unexpected error: $e"); // Log unexpected errors
      _showErrorDialog('An unexpected error occurred: $e'); // Show generic error dialog
    }
  }

  // Method to navigate to the home page
  void _navigateToHomePage(String uid, String email) {
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

  // Method to show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFEFEFEF), // Set background color of dialog
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

  // Build method to render the login page UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5D6C8A), // App bar color
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
                  'assets/logo2.png',
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
                    onPressed: () {
                      String email = _emailController.text; // Get email from input field
                      String password = _passwordController.text; // Get password from input field
                      authenticateUser(email, password); // Call authenticate user method
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
