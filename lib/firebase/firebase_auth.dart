import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  /// Request camera and microphone permissions
  Future<void> requestCameraAndMicrophonePermissions() async {
    try {
      PermissionStatus cameraStatus = await Permission.camera.request();
      PermissionStatus microphoneStatus = await Permission.microphone.request();

      if (cameraStatus.isGranted && microphoneStatus.isGranted) {
        _logger.i('Camera and microphone permissions granted.');
      } else {
        _logger.e('Camera and microphone permissions are required.');
      }
    } catch (e) {
      _logger.e('Error requesting permissions: $e');
    }
  }

  /// Upload image to Firebase Storage and get download URL
  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) {
        _logger.e('User not signed in.');
        return null;
      }

      Reference storageRef = _storage.ref().child('profile_images/$userId.jpg');
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      _logger.i('Profile image uploaded to Firebase Storage.');
      return downloadUrl;
    } catch (e) {
      _logger.e('Error uploading image: $e');
      return null;
    }
  }

  /// Update the user's profile with display name and photo URL
  Future<void> updateProfile(String? displayName, String? photoUrl) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updateProfile(displayName: displayName, photoURL: photoUrl);
        await user.reload();
        _logger.i(
            'User profile updated: displayName: $displayName, photoURL: $photoUrl');
      } else {
        _logger.e('No user is currently signed in.');
      }
    } catch (e) {
      _logger.e('Error updating profile: $e');
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

  /// Load user profile from Firestore
  Future<void> loadUserProfile(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await _firestore.collection('users').doc(
          userId).get();

      if (userSnapshot.exists) {
        Map<String, dynamic>? data = userSnapshot.data() as Map<String,
            dynamic>?;

        // Check if 'photoURL' exists
        String? photoURL = data?['photoURL'];
        String displayName = data?['displayName'] ?? 'No display name';

        _logger.i('User Profile: $displayName, Photo URL: $photoURL');
      } else {
        _logger.e('User profile not found.');
      }
    } catch (e) {
      _logger.e('Error loading user profile: $e');
    }
  }

  /// Register a new user with email, password, and optional profile image
  Future<User?> register(String email, String password,
      {File? profileImage}) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        String? photoUrl;
        if (profileImage != null) {
          photoUrl = await uploadProfileImage(profileImage);
        }

        await updateProfile(email.split('@')[0], photoUrl);
        await _saveUserSession(user);

        _logger.i('User registered: ${user.email}');
        if (!user.emailVerified) {
          await user.sendEmailVerification();
          _logger.i('Verification email sent to ${user.email}');
        }
      }
      return user;
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

        await prefs.setInt('session_expiration', DateTime
            .now()
            .add(Duration(hours: 1))
            .millisecondsSinceEpoch);
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

      int? sessionExpiration = prefs.getInt('session_expiration');
      if (sessionExpiration != null && DateTime
          .now()
          .millisecondsSinceEpoch > sessionExpiration) {
        await signOut();
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
    return _auth.currentUser?.uid;
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
