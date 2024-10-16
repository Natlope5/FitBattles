import 'package:firebase_auth/firebase_auth.dart'; // Firebase authentication package
import 'package:shared_preferences/shared_preferences.dart'; // Package for shared preferences to store user data
import 'package:logger/logger.dart'; // Logger for logging errors and information
import 'package:permission_handler/permission_handler.dart'; // Permission handler package

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance; // FirebaseAuth instance for authentication
  final Logger logger = Logger(); // Logger instance for logging

  // Request camera and microphone permissions
  Future<void> requestCameraAndMicrophonePermissions() async {
    var cameraStatus = await Permission.camera.status;
    var microphoneStatus = await Permission.microphone.status;

    if (cameraStatus.isDenied) {
      cameraStatus = await Permission.camera.request();
    }

    if (microphoneStatus.isDenied) {
      microphoneStatus = await Permission.microphone.request();
    }

    if (cameraStatus.isGranted && microphoneStatus.isGranted) {
      logger.i('Camera and microphone permissions granted.');
    } else {
      logger.e('Camera and microphone permissions are required to use this feature.');
    }
  }

  // Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password); // Firebase sign-in

      await _saveUserSession(userCredential.user); // Save session
      logger.i('User signed in: ${userCredential.user?.email}'); // Log success

      return userCredential.user; // Return the signed-in user
    } catch (e) {
      logger.e('Sign in failed: $e'); // Log error
      return null; // Return null to indicate failure
    }
  }

  // Register a new user
  Future<User?> register(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password); // Firebase registration

      await _saveUserSession(userCredential.user); // Save session
      logger.i('User registered: ${userCredential.user?.email}'); // Log success

      // Send email verification if needed
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
        logger.i('Verification email sent to ${userCredential.user!.email}');
      }

      return userCredential.user; // Return the registered user
    } catch (e) {
      logger.e('Registration failed: $e'); // Log error
      return null; // Return null to indicate failure
    }
  }

  // Reset password for the user
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email); // Firebase password reset
      logger.i('Password reset email sent to $email');
    } catch (e) {
      logger.e('Password reset failed: $e'); // Log error
    }
  }

  // Sign out user and clear session
  Future<void> signOut() async {
    await _auth.signOut(); // Firebase sign-out
    await _clearUserSession(); // Clear session
    logger.i('User signed out.');
  }

  // Save session to SharedPreferences
  Future<void> _saveUserSession(User? user) async {
    if (user != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', user.email ?? '');
      await prefs.setString('user_id', user.uid);

      // Save session expiration time
      await prefs.setInt('session_expiration', DateTime.now().add(Duration(hours: 1)).millisecondsSinceEpoch);
      logger.i('User session saved.');
    }
  }

  // Clear session from SharedPreferences
  Future<void> _clearUserSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    await prefs.remove('user_id');
    await prefs.remove('session_expiration');
    logger.i('User session cleared.');
  }

  // Check if user is logged in
  Future<bool> isUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    // Check for session expiration
    int? sessionExpiration = prefs.getInt('session_expiration');
    if (sessionExpiration != null && DateTime.now().millisecondsSinceEpoch > sessionExpiration) {
      await signOut(); // Sign out if session expired
      return false;
    }

    return userId != null;
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Check if the user's email is verified
  Future<bool> isEmailVerified() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.reload(); // Refresh the user to get the updated email verification status
      return user.emailVerified;
    }
    return false;
  }
}
