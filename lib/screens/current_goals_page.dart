import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:fitbattles/settings/theme_provider.dart';
import '../firebase/firebase_auth.dart';

class CurrentGoalsPage extends StatefulWidget {
  const CurrentGoalsPage({super.key});

  @override
  CurrentGoalsPageState createState() => CurrentGoalsPageState();
}

class CurrentGoalsPageState extends State<CurrentGoalsPage> {
  List<Map<String, dynamic>> _currentGoals = [];
  final FirebaseAuthService _authService = FirebaseAuthService(); // Initialize the service

  @override
  void initState() {
    super.initState();
    _checkUserAuthentication();
  }

  Future<void> _checkUserAuthentication() async {
    if (!await _authService.isUserLoggedIn()) {
      _navigateToLogin();
    } else {
      _loadCurrentGoals();
    }
  }

  void _navigateToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, '/addGoal'); // Change '/addGoal' to your login route
    });
  }

  Future<void> _loadCurrentGoals() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String>? savedGoals = prefs.getStringList('currentGoals');

      if (savedGoals != null) {
        // Check if the widget is still mounted before calling setState
        if (mounted) {
          setState(() {
            _currentGoals = savedGoals
                .map((goal) => jsonDecode(goal) as Map<String, dynamic>)
                .toList();
          });
        }
      }
    } catch (e) {
      // Handle error while loading goals
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading goals: $e')),
        );
      }
    }
  }




  Future<void> _updateProgress(int index, double progress) async {
    // Update progress only if the new progress is different
    if (progress != _currentGoals[index]['currentProgress']) {
      setState(() {
        _currentGoals[index]['currentProgress'] = progress;
        _currentGoals[index]['isCompleted'] = progress >= _currentGoals[index]['amount'];
      });

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> updatedGoals = _currentGoals.map((goal) => jsonEncode(goal)).toList();
      await prefs.setStringList('currentGoals', updatedGoals);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Current Goals')),
      body: _currentGoals.isEmpty
          ? const Center(child: Text('No goals set.'))
          : ListView.builder(
        itemCount: _currentGoals.length,
        itemBuilder: (context, index) {
          final goal = _currentGoals[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              title: Text(
                goal['name'],
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progress: ${goal['currentProgress']} / ${goal['amount']}',
                    style: TextStyle(
                      color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  Slider(
                    value: goal['currentProgress'],
                    min: 0,
                    max: goal['amount'],
                    activeColor: themeProvider.isDarkMode ? Colors.green : Colors.blue,
                    inactiveColor: themeProvider.isDarkMode ? Colors.grey : Colors.grey[300],
                    onChanged: (value) {
                      _updateProgress(index, value);
                    },
                  ),
                ],
              ),
              trailing: goal['isCompleted']
                  ? const Icon(Icons.check, color: Colors.green)
                  : const Icon(Icons.pending, color: Colors.orange),
            ),
          );
        },
      ),
    );
  }
}
