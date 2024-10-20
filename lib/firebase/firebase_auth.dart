import 'package:firebase_auth/firebase_auth.dart'; // Firebase authentication package
import 'package:shared_preferences/shared_preferences.dart'; // For storing user session
import 'package:logger/logger.dart'; // For logging
import 'package:permission_handler/permission_handler.dart'; // For handling permissions

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase authentication instance
  final Logger _logger = Logger(); // Logger instance

  /// Request camera and microphone permissions
  Future<void> requestCameraAndMicrophonePermissions() async {
    try {
      PermissionStatus cameraStatus = await Permission.camera.status;
      PermissionStatus microphoneStatus = await Permission.microphone.status;

      if (cameraStatus.isDenied) {
        cameraStatus = await Permission.camera.request();
      }
      if (microphoneStatus.isDenied) {
        microphoneStatus = await Permission.microphone.request();
      }

      if (cameraStatus.isGranted && microphoneStatus.isGranted) {
        _logger.i('Camera and microphone permissions granted.');
      } else {
        _logger.e('Camera and microphone permissions are required.');
      }
    } catch (e) {
      _logger.e('Error requesting permissions: $e');
    }
  }

  /// Sign in using email and password
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _saveUserSession(userCredential.user);
      _logger.i('User signed in: ${userCredential.user?.email}');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      _logger.e('Firebase sign-in error: ${e.message}');
      return null;
    } catch (e) {
      _logger.e('General sign-in error: $e');
      return null;
    }
  }

  /// Register a new user with email and password
  Future<User?> register(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _saveUserSession(userCredential.user);
      _logger.i('User registered: ${userCredential.user?.email}');

      if (!userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
        _logger.i('Verification email sent to ${userCredential.user!.email}');
      }
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      _logger.e('Firebase registration error: ${e.message}');
      return null;
    } catch (e) {
      _logger.e('General registration error: $e');
      return null;
    }
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _logger.i('Password reset email sent to $email');
    } catch (e) {
      _logger.e('Error sending password reset email: $e');
    }
  }

  /// Sign out the current user and clear session
  Future<void> signOut() async {
    try {
      await _clearUserSession();
      await _auth.signOut();
      _logger.i('User signed out.');
    } catch (e) {
      _logger.e('Error during sign-out: $e');
    }
  }

  /// Save the user session in shared preferences
  Future<void> _saveUserSession(User? user) async {
    if (user != null) {
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', user.email ?? '');
        await prefs.setString('user_id', user.uid);

        // Set session expiration to 1 hour from current time
        await prefs.setInt('session_expiration', DateTime.now().add(Duration(hours: 1)).millisecondsSinceEpoch);
        _logger.i('User session saved.');
      } catch (e) {
        _logger.e('Error saving user session: $e');
      }
    }
  }

  /// Clear the saved user session
  Future<void> _clearUserSession() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_email');
      await prefs.remove('user_id');
      await prefs.remove('session_expiration');
      _logger.i('User session cleared.');
    } catch (e) {
      _logger.e('Error clearing user session: $e');
    }
  }

  /// Check if the user is logged in by checking the saved session
  Future<bool> isUserLoggedIn() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');

      // Check if session has expired
      int? sessionExpiration = prefs.getInt('session_expiration');
      if (sessionExpiration != null && DateTime.now().millisecondsSinceEpoch > sessionExpiration) {
        await signOut(); // Automatically sign out if session expired
        return false;
      }

      return userId != null;
    } catch (e) {
      _logger.e('Error checking login status: $e');
      return false;
    }
  }

  /// Get the currently signed-in user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Get the currently signed-in user's ID
  String? getCurrentUserId() {
    User? user = _auth.currentUser;
    return user?.uid; // Return the user's ID or null if no user is signed in
  }

  /// Check if the current user's email is verified
  Future<bool> isEmailVerified() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        return user.emailVerified;
      }
      return false;
    } catch (e) {
      _logger.e('Error checking email verification: $e');
      return false;
    }
  }
}
