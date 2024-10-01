import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      String uid = userCredential.user!.uid;

      // Store the UID in shared preferences to keep the user logged in
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('uid', uid);
    } catch (e) {
      // Handle login error
    }
  }

  Future<void> checkSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');

    if (uid != null) {
      // User is still logged in, proceed to the home page
    } else {
      // No session found, redirect to login page
    }
  }

  Future<void> logoutUser() async {
    await _auth.signOut();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid');
  }
}
