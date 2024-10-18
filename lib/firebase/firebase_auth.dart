import 'package:firebase_auth/firebase_auth.dart'; // Firebase authentication package
import 'package:shared_preferences/shared_preferences.dart'; // Package for shared preferences to store user data
import 'package:logger/logger.dart'; // Logger for logging errors and information
import 'package:permission_handler/permission_handler.dart'; // Permission handler package

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance; // FirebaseAuth instance for authentication
  final Logger logger = Logger(); // Logger instance for logging

  /// Request camera and microphone permissions
  Future<void> requestCameraAndMicrophonePermissions() async {
    try {
      PermissionStatus cameraStatus = await Permission.camera.status;
      PermissionStatus microphoneStatus = await Permission.microphone.status;

      // Request camera permission if denied
      if (cameraStatus.isDenied) {
        cameraStatus = await Permission.camera.request();
      }

      // Request microphone permission if denied
      if (microphoneStatus.isDenied) {
        microphoneStatus = await Permission.microphone.request();
      }

      // Check if permissions were granted
      if (cameraStatus.isGranted && microphoneStatus.isGranted) {
        logger.i('Camera and microphone permissions granted.');
      } else {
        logger.e('Camera and microphone permissions are required to use this feature.');
      }
    } catch (e) {
      logger.e('Error requesting permissions: $e');
    }
  }

  /// Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password); // Firebase sign-in

      await _saveUserSession(userCredential.user); // Save session
      logger.i('User signed in: ${userCredential.user?.email}'); // Log success

      return userCredential.user; // Return the signed-in user
    } on FirebaseAuthException catch (e) {
      logger.e('FirebaseAuthException during sign-in: ${e.message}'); // Log Firebase-specific error
      return null;
    } catch (e) {
      logger.e('Error during sign-in: $e'); // Log general error
      return null;
    }
  }

  /// Register a new user
  Future<User?> register(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password); // Firebase registration

      await _saveUserSession(userCredential.user); // Save session
      logger.i('User registered: ${userCredential.user?.email}'); // Log success

      // Send email verification if the user is created
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
        logger.i('Verification email sent to ${userCredential.user!.email}');
      }

      return userCredential.user; // Return the registered user
    } on FirebaseAuthException catch (e) {
      logger.e('FirebaseAuthException during registration: ${e.message}'); // Log Firebase-specific error
      return null;
    } catch (e) {
      logger.e('Error during registration: $e'); // Log general error
      return null;
    }
  }

  /// Reset password for the user
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email); // Firebase password reset
      logger.i('Password reset email sent to $email');
    } catch (e) {
      logger.e('Error during password reset: $e'); // Log error
    }
  }

  /// Sign out user and clear session
  Future<void> signOut() async {
    try {
      await _clearUserSession(); // Clear session before signing out
      await _auth.signOut(); // Firebase sign-out
      logger.i('User signed out.');
    } catch (e) {
      logger.e('Error during sign-out: $e'); // Log error
    }
  }

  /// Save session to SharedPreferences
  Future<void> _saveUserSession(User? user) async {
    if (user != null) {
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', user.email ?? '');
        await prefs.setString('user_id', user.uid);

        // Save session expiration time (set to 1 hour by default)
        await prefs.setInt('session_expiration', DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch);
        logger.i('User session saved.');
      } catch (e) {
        logger.e('Error saving user session: $e'); // Log error
      }
    }
  }

  /// Clear session from SharedPreferences
  Future<void> _clearUserSession() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_email');
      await prefs.remove('user_id');
      await prefs.remove('session_expiration');
      logger.i('User session cleared.');
    } catch (e) {
      logger.e('Error clearing user session: $e'); // Log error
    }
  }

  /// Check if the user is logged in
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

      return userId != null; // Return true if user ID exists in session
    } catch (e) {
      logger.e('Error checking login status: $e'); // Log error
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
        await user.reload(); // Refresh the user to get the updated email verification status
        return user.emailVerified; // Return email verification status
      }
      return false; // Return false if user is null
    } catch (e) {
      logger.e('Error checking email verification: $e'); // Log error
      return false;
    }
  }
}
