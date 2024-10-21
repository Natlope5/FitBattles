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
        _logger.i('User profile updated: displayName: $displayName, photoURL: $photoUrl');
      } else {
        _logger.e('No user is currently signed in.');
      }
    } catch (e) {
      _logger.e('Error updating profile: $e');
    }
  }

  /// Start a challenge (save it to Firestore)
  Future<void> startChallenge(String challengeId) async {
    try {
      String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) {
        _logger.e('User not signed in.');
        return;
      }

      await _firestore.collection('startedChallenges').add({
        'challengeId': challengeId,
        'userId': userId,
        'startDate': Timestamp.now(),
      });

      _logger.i('Challenge started: $challengeId for user: $userId');
    } catch (e) {
      _logger.e('Error starting challenge: $e');
    }
  }

  /// Fetch all challenges started by the user
  Future<List<Map<String, dynamic>>> getStartedChallenges() async {
    try {
      String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) {
        _logger.e('User not signed in.');
        return [];
      }

      QuerySnapshot querySnapshot = await _firestore
          .collection('startedChallenges')
          .where('userId', isEqualTo: userId)
          .get();

      List<Map<String, dynamic>> challenges = querySnapshot.docs.map((doc) {
        return {
          'startedChallengeId': doc.id,
          'challengeId': doc['challengeId'],
          'startDate': doc['startDate'],
        };
      }).toList();

      _logger.i('Fetched ${challenges.length} started challenges for user: $userId');
      return challenges;
    } catch (e) {
      _logger.e('Error fetching started challenges: $e');
      return [];
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
      _logger.e('Error signing in: $e');
      return null;
    }
  }

  /// Register a new user
  Future<User?> register(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _saveUserSession(userCredential.user);
      _logger.i('User registered: ${userCredential.user?.email}');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      _logger.e('Error registering user: $e');
      return null;
    }
  }

  /// Sign out the user
  Future<void> signOut() async {
    await _auth.signOut();
    _logger.i('User signed out.');
  }

  /// Save user session details in shared preferences
  Future<void> _saveUserSession(User? user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (user != null) {
      await prefs.setString('userId', user.uid);
      await prefs.setString('userEmail', user.email ?? '');
    }
  }

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  /// Get the current user (additional method)
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Check if the user is logged in (additional method)
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }
}
