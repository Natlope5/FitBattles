import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class SessionManager {
  final String _userEmailKey = "user_email"; // Key for email storage
  final String _userIdKey = "user_id"; // Key for user ID storage
  final String _sessionExpirationKey = "session_expiration"; // Key for session expiration
  final Logger logger = Logger(); // Logger instance for error handling and info logging

  /// Save user email to SharedPreferences after successful login
  Future<void> saveUserEmail(String userEmail) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userEmailKey, userEmail); // Store user email locally
      logger.i("User email saved: $userEmail");
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

  /// Save user session data (email and ID) to SharedPreferences after successful login
  Future<void> saveUserSession(User? user) async {
    try {
      if (user != null) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await saveUserEmail(user.email ?? ''); // Store user email locally
        await prefs.setString(_userIdKey, user.uid); // Store user ID locally

        // Save session expiration time (7 days from login)
        await prefs.setInt(_sessionExpirationKey,
            DateTime.now().add(Duration(days: 7)).millisecondsSinceEpoch);

        logger.i("User session saved: ${user.email}");
      }
    } catch (e) {
      logger.e("Error saving user session: $e");
    }
  }

  /// Firebase login method
  Future<User?> loginWithFirebase(String email, String password) async {
    try {
      // Use Firebase to sign in with email and password
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user session after successful login
      await saveUserSession(userCredential.user);
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString(_userIdKey);

    // Check for session expiration
    int? sessionExpiration = prefs.getInt(_sessionExpirationKey);
    if (sessionExpiration != null &&
        DateTime.now().millisecondsSinceEpoch > sessionExpiration) {
      await logoutUser(); // Sign out if session expired
      return false;
    } else if (userId != null) {
      // Extend session expiration by another 7 days if session is still valid
      await prefs.setInt(_sessionExpirationKey,
          DateTime.now().add(Duration(days: 7)).millisecondsSinceEpoch);
      return true;
    }

    return false;
  }

  /// Firebase sign-out method
  Future<void> logoutUser() async {
    try {
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Clear locally stored user data after signing out
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userEmailKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_sessionExpirationKey);

      logger.i("User logged out and session cleared from local storage");
    } catch (e) {
      logger.e("Error logging out: $e");
    }
  }

  /// Register a new user in Firebase
  Future<User?> signUpWithFirebase(String email, String password) async {
    try {
      // Sign up a new user with email and password
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user session after successful signup
      await saveUserSession(userCredential.user);
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
