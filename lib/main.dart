import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitBattles',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5D6C8A),
        ),
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.black,
          displayColor: Colors.black,
        ),
      ),
      home: const MyLoginPage(title: 'Welcome to FitBattles'),
    );
  }
}

class MyLoginPage extends StatefulWidget {
  const MyLoginPage({super.key, required this.title});
  final String title;

  @override
  State<MyLoginPage> createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Logger logger = Logger();

  Future<void> authenticateUser(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      String uid = userCredential.user!.uid;
      String userEmail = userCredential.user!.email!;

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully logged in as $userEmail')),
      );

      _navigateToHomePage(uid, userEmail);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      // Log the error code using the logger package
      logger.e("Error code: ${e.code}", e);

      _showErrorDialog(_getErrorMessage(e));
    } catch (e) {
      if (!mounted) return;
      logger.e("Unexpected error: $e", e);
      _showErrorDialog('An unexpected error occurred: $e');
    }
  }

  void _navigateToHomePage(String uid, String email) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage(uid: uid, email: email)),
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFEFEFEF),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(0xFFE62D2D), width: 2.0),
            borderRadius: BorderRadius.circular(8.0),
          ),
          title: const Text('Error', style: TextStyle(color: Colors.black)),
          content: Text(message, style: const TextStyle(color: Colors.black)),
          actions: <Widget>[
            TextButton(
              child: const Text('OK', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5D6C8A),
        title: Text(widget.title),
      ),
      body: Container(
        color: const Color(0xFF5D6C8A),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 5),
                Image.asset(
                  'assets/logo.png',
                  height: 250,
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    String email = _emailController.text;
                    String password = _passwordController.text;
                    authenticateUser(email, password);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: const Color(0xFF85C83E),
                  ),
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final String uid;
  final String email;

  const HomePage({super.key, required this.uid, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5D6C8A),
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome to FitBattles!',
              style: TextStyle(fontSize: 24, color: Color(0xFF85C83E)),
            ),
            Text('User ID: $uid', style: const TextStyle(fontSize: 16)),
            Text('Email: $email', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
