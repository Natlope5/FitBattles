import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:fitbattles/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitbattles/auth/session_manager.dart';
import 'package:fitbattles/screens/home_page.dart';
import 'package:fitbattles/auth/signup_page.dart';
import 'package:fitbattles/l10n/custom_localization.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title, required this.setLocale});

  final String title;
  final Function(Locale) setLocale;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Logger logger = Logger();
  final SessionManager _sessionManager = SessionManager();

  String _selectedLanguage = 'English'; // Default language
  final Map<String, String> _languages = {
    'English': 'en',
    'Spanish': 'es',
    'French': 'fr',
    'German': 'de',
    'Chinese': 'zh',
  };
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

  // Load the selected language from shared preferences
  Future<void> _loadSelectedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('selectedLanguage');
    if (languageCode != null) {
      setState(() {
        _selectedLanguage = _languages.keys.firstWhere(
              (lang) => _languages[lang] == languageCode,
          orElse: () => 'English',
        );
      });
      widget.setLocale(Locale(languageCode)); // Set initial locale
    }
  }

  // Change the language and save it in shared preferences
  Future<void> _changeLanguage(String language, String languageCode) async {
    setState(() {
      _selectedLanguage = language;
      widget.setLocale(Locale(languageCode));
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', languageCode);
  }

  // Authenticate user
  Future<void> _loginUser(AppLocalizations appLocalizations) async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    final customLocalizations = CustomLocalizations.of(context);

    // Check for empty fields
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = customLocalizations?.emptyFieldsError;
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
      setState(() {
        errorMessage = null; // Clear any previous error messages
      });
      _navigateToHomePage(uid, userEmail);
    } on FirebaseAuthException catch (e) {
      logger.e("Error code: ${e.code}, Message: ${e.message}");
      setState(() {
        errorMessage = _getErrorMessage(e, customLocalizations); // Ensure error messages are localized
      });
    } catch (e) {
      logger.e("Unexpected error: $e");
      setState(() {
        errorMessage = customLocalizations?.unexpectedError;
      });
    }
  }

  // Navigate to the home page
  void _navigateToHomePage(String id, String email) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage(id: id, email: email, uid: id)), // Changed to uid
    );
  }

  // Get error messages based on Firebase error codes
  String _getErrorMessage(FirebaseAuthException e, CustomLocalizations? customLocalizations) {
    switch (e.code) {
      case 'user-not-found':
        return customLocalizations?.userNotFoundError ?? 'User not found';
      case 'wrong-password':
        return customLocalizations?.wrongPasswordError ?? 'Wrong password, please try again!';
      default:
        return customLocalizations?.defaultError ?? 'An unknown error occurred';
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final customLocalizations = CustomLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFF5D6C8A),
      ),
      body: Container(
        color: const Color(0xFF5D6C8A),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Logo
                  Image.asset('assets/images/logo2.png', height: 250),
                  const SizedBox(height: 20),

                  // Language dropdown
                  DropdownButton<String>(
                    value: _selectedLanguage,
                    items: _languages.keys.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        // Get language code from the map
                        String languageCode = _languages[newValue]!;
                        _changeLanguage(newValue, languageCode);
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // Email field
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: appLocalizations.emailLabel,
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),

                  // Password field
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: appLocalizations.passwordLabel,
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Login button
                  ElevatedButton(
                    onPressed: () => _loginUser(appLocalizations),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF85C83E),
                    ),
                    child: Text(appLocalizations.loginButton),
                  ),
                  const SizedBox(height: 20),

                  // Display error message if any
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Link to sign up page
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignupPage()),
                      );
                    },
                    child: Text(
                      customLocalizations?.signupPrompt ?? 'Don’t have an account? Sign up!',
                      style: const TextStyle(color: Colors.black),
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
