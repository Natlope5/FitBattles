import 'package:fitbattles/pages/settings/user_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:fitbattles/pages/home_page.dart';
import 'package:fitbattles/services/firebase/session_manager.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title, required Null Function(dynamic locale) setLocale});
  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Logger logger = Logger();
  String? errorMessage;
  final SessionManager _sessionManager = SessionManager();
  //bool _rememberMe = false;

  Future<void> authenticateUser(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Email and password cannot be empty.';
      });
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;
      String userEmail = userCredential.user!.email!;

      await _sessionManager.saveUserEmail(userEmail);

      errorMessage = null;
      _navigateToHomePage(uid, userEmail);
    } on FirebaseAuthException catch (e) {
      logger.e("Error code: ${e.code}, Message: ${e.message}");
      setState(() {
        errorMessage = _getErrorMessage(e);
      });
    } catch (e) {
      logger.e("Unexpected error: $e");
      setState(() {
        errorMessage = 'An unexpected error occurred: $e';
      });
    }
  }

  void _navigateToHomePage(String id, String email) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage(id: id, email: email, uid: '')),
    );
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  Future<void> _resetPassword(String email) async {
    if (email.isEmpty) {
      setState(() {
        errorMessage = 'You must enter an email address to receive the reset link.';
      });
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      setState(() {
        errorMessage = 'Password reset email sent! Please check your inbox.';
      });
    } on FirebaseAuthException catch (e) {
      logger.e("Error code: ${e.code}, Message: ${e.message}");
      setState(() {
        errorMessage = _getErrorMessage(e);
      });
    } catch (e) {
      logger.e("Unexpected error: $e");
      setState(() {
        errorMessage = 'An unexpected error occurred: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData loginTheme = ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFF5D6C8A),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
        labelStyle: TextStyle(color: Colors.black),
      ),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
          )

      ),
    );

    return Theme(
      data: loginTheme,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/AbstractWallpaperBackground.jpeg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/images/logo2.png',
                    height: 300,
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        filled: true,
                        fillColor: Color(0xB0FFFFFF),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.blue, width: 2.0),
                        ),
                        prefixIcon: const Icon(Icons.email, color: Colors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        filled: true,
                        fillColor: Color(0xB0FFFFFF),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.blue, width: 2.0),
                        ),
                        prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => authenticateUser(
                        _emailController.text, _passwordController.text),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF84C63E), Color(0xFF91EF2E)],
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 12),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF272A2C),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => _resetPassword(_emailController.text),
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                          color: Colors.black,
                          decoration: TextDecoration.underline,
                          fontSize: 15),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserProfilePage(
                            heading: 'User Profile',
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Create Account',
                      style: TextStyle(
                          color: Colors.black,
                          decoration: TextDecoration.underline,
                          fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
