import 'package:firebase_auth/firebase_auth.dart'; // Importing Firebase Auth for user authentication
import 'package:shared_preferences/shared_preferences.dart'; // Importing Shared Preferences for local storage

// Class to manage user sessions
class SessionManager {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instance of FirebaseAuth for authentication operations

  // Method to log in the user
  Future<void> loginUser(String email, String password) async {
    try {
      // Attempt to sign in with email and password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      String uid = userCredential.user!.uid; // Get the unique ID of the logged-in user

      // Store the UID in shared preferences to keep the user logged in
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('uid', uid); // Save UID in shared preferences
    } catch (e) {
      // Handle login error (consider logging the error or showing a message to the user)
    }
  }

  // Method to check the user's session status
  Future<void> checkSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance(); // Get instance of shared preferences
    String? uid = prefs.getString('uid'); // Retrieve UID from shared preferences

    if (uid != null) {
      // User is still logged in, proceed to the home page
    } else {
      // No session found, redirect to login page
    }
  }

  // Method to log out the user
  Future<void> logoutUser() async {
    await _auth.signOut(); // Sign out from Firebase

    SharedPreferences prefs = await SharedPreferences.getInstance(); // Get instance of shared preferences
    await prefs.remove('uid'); // Remove UID from shared preferences to clear session
  }
}
