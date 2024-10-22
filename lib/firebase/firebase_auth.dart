import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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
      } else if (cameraStatus.isDenied || microphoneStatus.isDenied) {
        _logger.w('Camera or microphone permission denied.');
        // You might want to prompt the user to go to settings and enable the permissions
      } else if (cameraStatus.isPermanentlyDenied || microphoneStatus.isPermanentlyDenied) {
        _logger.e('Camera or microphone permission permanently denied. Please enable from settings.');
        // Direct the user to the app settings
        await openAppSettings();
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

      // Improved error handling with onComplete checks for failed uploads
      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
      if (snapshot.state == TaskState.success) {
        String downloadUrl = await snapshot.ref.getDownloadURL();
        _logger.i('Profile image uploaded to Firebase Storage.');
        return downloadUrl;
      } else {
        _logger.e('Failed to upload image.');
        return null;
      }
    } catch (e) {
      _logger.e('Error uploading image: $e');
      return null;
    }
  }

  /// Update the user's profile with display name and photo URL
  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
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
  Future<void> startChallenge(String challengeId, String opponentId) async {
    try {
      String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) {
        _logger.e('User not signed in.');
        return;
      }

      // Save the challenge in Firestore
      await _firestore.collection('startedChallenges').add({
        'challengeId': challengeId,
        'userId': userId,
        'startDate': Timestamp.now(),
        'opponentId': opponentId,
      });

      // Notify the opponent
      bool notificationSent = await _notifyOpponent(opponentId, challengeId);
      if (notificationSent) {
        _logger.i('Challenge started and opponent notified: $challengeId for user: $userId');
      } else {
        _logger.e('Failed to notify opponent.');
      }
    } catch (e) {
      _logger.e('Error starting challenge: $e');
    }
  }

  /// Notify the opponent about the challenge
  Future<bool> _notifyOpponent(String opponentId, String challengeId) async {
    try {
      // Fetch opponent's device token or notification details from Firestore
      DocumentSnapshot opponentSnapshot = await _firestore.collection('users').doc(opponentId).get();
      if (opponentSnapshot.exists) {
        String? deviceToken = opponentSnapshot.get('deviceToken');
        if (deviceToken != null && deviceToken.isNotEmpty) {
          // Send a notification using FCM or any notification service
          await sendFCMNotification(deviceToken, challengeId);
          _logger.i('Opponent notified about the challenge.');
          return true;
        } else {
          _logger.e('Opponent device token not available.');
        }
      }
    } catch (e) {
      _logger.e('Error notifying opponent: $e');
    }
    return false;
  }

  /// Send Firebase Cloud Messaging (FCM) notification
  Future<void> sendFCMNotification(String deviceToken, String challengeId) async {
    // Replace with your actual FCM notification sending logic
    final url = 'https://fcm.googleapis.com/fcm/send';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=YOUR_SERVER_KEY',  // Replace with your FCM server key
    };
    final body = jsonEncode({
      'to': deviceToken,
      'notification': {
        'title': 'New Challenge!',
        'body': 'You have been challenged in challenge $challengeId.',
      },
      'data': {
        'challengeId': challengeId,
      },
    });

    final response = await http.post(Uri.parse(url), headers: headers, body: body);
    if (response.statusCode == 200) {
      _logger.i('FCM notification sent successfully.');
    } else {
      _logger.e('Failed to send FCM notification: ${response.body}');
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
      _logger.e('Error signing in: ${e.message}');
      return null;
    }
  }

  /// Register a new user and optionally send email verification
  Future<User?> register(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Optionally send an email verification after registration
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
        _logger.i('Verification email sent to ${userCredential.user!.email}');
      }

      await _saveUserSession(userCredential.user);
      _logger.i('User registered: ${userCredential.user?.email}');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      _logger.e('Error registering user: ${e.message}');
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
