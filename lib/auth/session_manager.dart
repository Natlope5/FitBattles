import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences package

class SessionManager {
  // Method to save user email after login
  Future<void> saveUserEmail(String email) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email); // Store user email
  }

  // Method to get stored user email
  Future<String?> getUserEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email'); // Retrieve user email
  }

  // Method to check if user is logged in
  Future<bool> isUserLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString('user_email'); // Check if email is stored
    return userEmail != null; // Return true if user email exists
  }

  // Method to log out user and clear stored data
  Future<void> logoutUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email'); // Remove stored email
    // Optionally, you can clear other user-related data here
  }
}
