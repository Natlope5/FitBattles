import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase authentication package
import 'package:shared_preferences/shared_preferences.dart'; // Import package for shared preferences to store user data
import 'package:logger/logger.dart'; // Import logger for logging errors and information

// AuthService class handles authentication-related operations
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance; // FirebaseAuth instance for authentication
  final Logger logger = Logger(); // Logger instance for logging

  // Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    try {
      // Attempt to sign in the user using Firebase
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      await _saveUserSession(userCredential.user); // Save user session after successful sign-in
      return userCredential.user; // Return the signed-in user
    } catch (e) {
      logger.e('Sign in failed: $e'); // Log error if sign-in fails
      return null; // Return null to indicate failure
    }
  }

  // Register a new user
  Future<User?> register(String email, String password) async {
    try {
      // Attempt to create a new user with Firebase
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await _saveUserSession(userCredential.user); // Save user session after successful registration
      return userCredential.user; // Return the registered user
    } catch (e) {
      logger.e('Registration failed: $e'); // Log error if registration fails
      return null; // Return null to indicate failure
    }
  }

  // Sign out user and clear session
  Future<void> signOut() async {
    await _auth.signOut(); // Sign out from Firebase
    await _clearUserSession(); // Clear user session data from SharedPreferences
  }

  // Save session to SharedPreferences
  Future<void> _saveUserSession(User? user) async {
    if (user != null) { // Only save if user is not null
      SharedPreferences prefs = await SharedPreferences.getInstance(); // Get SharedPreferences instance
      await prefs.setString('userEmail', user.email ?? ''); // Save user's email
      await prefs.setString('userId', user.uid); // Save user's unique ID
    }
  }

  // Clear session from SharedPreferences
  Future<void> _clearUserSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance(); // Get SharedPreferences instance
    await prefs.remove('userEmail'); // Remove user's email
    await prefs.remove('userId'); // Remove user's unique ID
  }

  // Check if user is logged in
  Future<bool> isUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance(); // Get SharedPreferences instance
    String? userId = prefs.getString('userId'); // Retrieve user's ID
    return userId != null; // Return true if user ID exists, indicating the user is logged in
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser; // Return the currently authenticated user
  }
}
