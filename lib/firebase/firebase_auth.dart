import 'package:firebase_auth/firebase_auth.dart'; // Firebase authentication package
import 'package:shared_preferences/shared_preferences.dart'; // Package for shared preferences
import 'package:logger/logger.dart'; // Logger for logging
import 'package:permission_handler/permission_handler.dart'; // Permission handler package

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance; // FirebaseAuth instance
  final Logger logger = Logger(); // Logger instance for error and info logging

  /// Request camera and microphone permissions
  Future<void> requestCameraAndMicrophonePermissions() async {
    try {
      PermissionStatus cameraStatus = await Permission.camera.status;
      PermissionStatus microphoneStatus = await Permission.microphone.status;

      // Request camera and microphone permissions if denied
      if (cameraStatus.isDenied) cameraStatus = await Permission.camera.request();
      if (microphoneStatus.isDenied) microphoneStatus = await Permission.microphone.request();

      // Check if permissions are granted and log the result
      if (cameraStatus.isGranted && microphoneStatus.isGranted) {
        logger.i('Camera and microphone permissions granted.');
      } else {
        logger.w('Permissions for camera and microphone are required to use this feature.');
      }
    } catch (e) {
      logger.e('Error requesting permissions');
    }
  }

  /// Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);

      await _saveUserSession(userCredential.user);
      logger.i('User signed in: ${userCredential.user?.email}');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      logger.e('FirebaseAuthException during sign-in: ${e.message}');
      return null;
    } catch (e) {
      logger.e('General error during sign-in');
      return null;
    }
  }

  /// Register a new user with email and password
  Future<User?> register(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      await _saveUserSession(userCredential.user);
      logger.i('User registered: ${userCredential.user?.email}');

      // Send email verification if the user's email is unverified
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
        logger.i('Verification email sent to ${userCredential.user!.email}');
      }
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      logger.e('FirebaseAuthException during registration: ${e.message}');
      return null;
    } catch (e) {
      logger.e('General error during registration');
      return null;
    }
  }

  /// Reset the user's password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      logger.i('Password reset email sent to $email');
    } catch (e) {
      logger.e('Error during password reset');
    }
  }

  /// Sign out the user and clear session data
  Future<void> signOut() async {
    try {
      await _clearUserSession(); // Clear session data before signing out
      await _auth.signOut();
      logger.i('User signed out successfully.');
    } catch (e) {
      logger.e('Error during sign-out');
    }
  }

  /// Save user session data securely
  Future<void> _saveUserSession(User? user) async {
    if (user != null) {
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', user.email ?? '');
        await prefs.setString('user_id', user.uid);

        // Set a session expiration (default: 1 hour)
        await prefs.setInt('session_expiration', DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch);
        logger.i('User session saved.');
      } catch (e) {
        logger.e('Error saving user session');
      }
    }
  }

  /// Clear user session data
  Future<void> _clearUserSession() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_email');
      await prefs.remove('user_id');
      await prefs.remove('session_expiration');
      logger.i('User session cleared.');
    } catch (e) {
      logger.e('Error clearing user session');
    }
  }

  /// Check if user is logged in with a valid session
  Future<bool> isUserLoggedIn() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');

      // Check for session expiration
      int? sessionExpiration = prefs.getInt('session_expiration');
      if (sessionExpiration != null && DateTime.now().millisecondsSinceEpoch > sessionExpiration) {
        await signOut(); // Sign out if session expired
        return false;
      }
      return userId != null;
    } catch (e) {
      logger.e('Error checking login status');
      return false;
    }
  }

  /// Get current user from FirebaseAuth
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Check if the user's email is verified
  Future<bool> isEmailVerified() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.reload(); // Refresh the user for the latest email verification status
        return user.emailVerified;
      }
      return false;
    } catch (e) {
      logger.e('Error checking email verification');
      return false;
    }
  }
}
