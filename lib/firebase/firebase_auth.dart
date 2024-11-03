import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase authentication package
import 'package:shared_preferences/shared_preferences.dart'; // Package for shared preferences
import 'package:logger/logger.dart'; // Logger for logging
import 'package:permission_handler/permission_handler.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance; // FirebaseAuth instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance
  final Logger logger = Logger(); // Logger instance for error and info logging

  /// Sign in anonymously
  Future<void> signInAnonymously() async {
    try {
      await _auth.signInAnonymously();
      logger.i('User signed in anonymously.');
    } catch (e) {
      logger.e('Error signing in anonymously: $e');
    }
  }

  /// Register a new user with email and password
  Future<String> register(String email, String password, int age, String bio, double height, double weight, String name, String visibility) async {
    try {
      // Validate visibility
      if (!['public', 'friendsOnly', 'private'].contains(visibility)) {
        return 'Invalid visibility option.';
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await _saveUserSession(userCredential.user);

      // Pass user inputs to save user data
      await _saveUserDataToFirestore(
        userCredential.user,
        email,
        age,
        bio,
        height,
        weight,
        name,
        visibility,
      );

      logger.i('User registered: ${userCredential.user?.email}');

      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
        logger.i('Verification email sent to ${userCredential.user!.email}');
      }

      return 'Registration successful. Please check your email for verification.'; // Notify success
    } on FirebaseAuthException catch (e) {
      logger.e('FirebaseAuthException during registration: ${e.message}');
      return 'Registration failed: ${e.message}'; // Notify failure with specific error
    } catch (e) {
      logger.e('General error during registration: $e');
      return 'An error occurred during registration. Please try again.'; // General failure notification
    }
  }

  /// Save user data to Firestore
  Future<void> _saveUserDataToFirestore(User? user, String email, int age, String bio, double heightInCm, double weightInPounds, String name, String visibility) async {
    if (user != null) {
      try {
        // Convert height from cm to meters
        double heightInMeters = heightInCm / 100;

        // Convert weight from pounds to kilograms
        double weightInKg = weightInPounds * 0.453592;

        await _firestore.collection('users').doc(user.uid).set({
          'userId': user.uid,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'age': age,
          'bio': bio,
          'height': heightInMeters, // Store height in meters
          'weight': weightInKg, // Store weight in kilograms (if applicable)
          'name': name,
          'receive_notifications': true,
          'share_data': true,
          'visibility': visibility,
        });
        logger.i('User data saved to Firestore successfully.');
      } catch (e) {
        logger.e('Error saving user data to Firestore: $e');
      }
    }
  }

  /// Request camera and microphone permissions
  Future<void> requestCameraAndMicrophonePermissions() async {
    try {
      PermissionStatus cameraStatus = await Permission.camera.status;
      PermissionStatus microphoneStatus = await Permission.microphone.status;

      // Request permissions if denied
      if (cameraStatus.isDenied) cameraStatus = await Permission.camera.request();
      if (microphoneStatus.isDenied) microphoneStatus = await Permission.microphone.request();

      // Log the permission status
      if (cameraStatus.isGranted && microphoneStatus.isGranted) {
        logger.i('Camera and microphone permissions granted.');
      } else {
        logger.w('Permissions for camera and microphone are required to use this feature.');
      }
    } catch (e) {
      logger.e('Error requesting permissions: $e');
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
      logger.e('General error during sign-in: $e');
      return null;
    }
  }

  /// Save user session data securely
  Future<void> _saveUserSession(User? user) async {
    if (user != null) {
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', user.email ?? '');
        await prefs.setString('user_id', user.uid);
        await prefs.setInt('session_expiration', DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch);
        logger.i('User session saved.');
      } catch (e) {
        logger.e('Error saving user session: $e');
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
      logger.e('Error clearing user session: $e');
    }
  }

  /// Check if user is logged in with a valid session
  Future<bool> isUserLoggedIn() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');
      int? sessionExpiration = prefs.getInt('session_expiration');

      if (sessionExpiration != null && DateTime.now().millisecondsSinceEpoch > sessionExpiration) {
        await signOut(); // Sign out if session expired
        return false;
      }
      return userId != null;
    } catch (e) {
      logger.e('Error checking login status: $e');
      return false;
    }
  }

  /// Sign out the user and clear session data
  Future<void> signOut() async {
    try {
      await _auth.signOut(); // Firebase sign-out
      await _clearUserSession(); // Clear session data from SharedPreferences
      logger.i('User signed out successfully.');
    } catch (e) {
      logger.e('Error signing out: $e');
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
        await user.reload();
        return user.emailVerified;
      }
      return false;
    } catch (e) {
      logger.e('Error checking email verification: $e');
      return false;
    }
  }
}
