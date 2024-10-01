import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger logger = Logger();

  // Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      await _saveUserSession(userCredential.user);
      return userCredential.user;
    } catch (e) {
      logger.e('Sign in failed: $e');
      return null;
    }
  }

  // Register a new user
  Future<User?> register(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await _saveUserSession(userCredential.user);
      return userCredential.user;
    } catch (e) {
      logger.e('Registration failed: $e');
      return null;
    }
  }

  // Sign out user and clear session
  Future<void> signOut() async {
    await _auth.signOut();
    await _clearUserSession();
  }

  // Save session to SharedPreferences
  Future<void> _saveUserSession(User? user) async {
    if (user != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userEmail', user.email ?? '');
      await prefs.setString('userId', user.uid);
    }
  }

  // Clear session from SharedPreferences
  Future<void> _clearUserSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userEmail');
    await prefs.remove('userId');
  }

  // Check if user is logged in
  Future<bool> isUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    return userId != null;
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
