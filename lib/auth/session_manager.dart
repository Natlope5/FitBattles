import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class SessionManager {
  final String _userEmailKey = "user_email"; // Key for email storage
  final Logger logger = Logger(); // Logger instance for error handling and info logging

  /// Save user email to SharedPreferences after successful login
  Future<void> saveUserEmail(String email) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userEmailKey, email); // Store user email locally
      logger.i("User email saved: $email");
    } catch (e) {
      logger.e("Error saving user email: $e");
    }
  }

  /// Fetch user email from SharedPreferences
  Future<String?> getUserEmail() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userEmailKey); // Retrieve user email from local storage
    } catch (e) {
      logger.e("Error retrieving user email: $e");
      return null;
    }
  }

  /// Firebase login method
  Future<User?> loginWithFirebase(String email, String password) async {
    try {
      // Use Firebase to sign in with email and password
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user email locally after successful login
      await saveUserEmail(email);
      logger.i("User logged in with email: $email");

      // Return the logged-in user
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Handle specific FirebaseAuthExceptions
      logger.e("FirebaseAuthException during login: ${e.message}");
      return null;
    } catch (e) {
      logger.e("Error logging in: $e");
      return null;
    }
  }

  /// Check if the user is logged in by checking FirebaseAuth and SharedPreferences
  Future<bool> isUserLoggedIn() async {
    try {
      // Check Firebase for current user
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return true; // User is logged in
      }

      // Optionally check SharedPreferences as fallback for session management
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? email = prefs.getString(_userEmailKey);
      return email != null;
    } catch (e) {
      logger.e("Error checking user login status: $e");
      return false;
    }
  }

  /// Firebase sign-out method
  Future<void> logoutUser() async {
    try {
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Clear locally stored email after signing out
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userEmailKey);

      logger.i("User logged out and email cleared from local storage");
    } catch (e) {
      logger.e("Error logging out: $e");
    }
  }

  /// Register new user in Firebase
  Future<User?> signUpWithFirebase(String email, String password) async {
    try {
      // Sign up a new user with email and password
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user email after successful signup
      await saveUserEmail(email);
      logger.i("User signed up with email: $email");

      // Return the new user
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Handle specific FirebaseAuthExceptions during sign up
      logger.e("FirebaseAuthException during signup: ${e.message}");
      return null;
    } catch (e) {
      logger.e("Error signing up: $e");
      return null;
    }
  }
}
