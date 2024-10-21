import 'package:fitbattles/firebase/firebase_notifications_handler.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:fitbattles/settings/theme_provider.dart';

class AddGoalPage extends StatefulWidget {
  const AddGoalPage({super.key});

  @override
  AddGoalPageState createState() => AddGoalPageState();
}

class AddGoalPageState extends State<AddGoalPage> {
  final TextEditingController _goalNameController = TextEditingController();
  final TextEditingController _goalAmountController = TextEditingController();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Define the NotificationsHandler but don't initialize it here.
  late NotificationsHandler notificationsHandler;

  @override
  void initState() {
    super.initState();
    // Use post-frame callback to initialize the notificationsHandler.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notificationsHandler = Provider.of<NotificationsHandler>(context, listen: false);
    });
  }

  Future<void> _saveGoal() async {
    final String goalName = _goalNameController.text.trim();
    final double? goalAmount = double.tryParse(_goalAmountController.text.trim());

    if (goalName.isNotEmpty && goalAmount != null) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> goalHistory = prefs.getStringList('currentGoals') ?? [];

      final newGoal = {
        'name': goalName,
        'amount': goalAmount,
        'currentProgress': 0.0,
        'isCompleted': false,
      };

      try {
        // Save goal to Firestore
        DocumentReference docRef = await _firestore.collection('goals').add(newGoal);
        newGoal['id'] = docRef.id;
        goalHistory.add(jsonEncode(newGoal));

        await prefs.setStringList('currentGoals', goalHistory);

        // Schedule a notification
        notificationsHandler.scheduleGoalNotification(goalName);

        scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(content: Text('Goal added successfully!')),
        );
      } catch (error) {
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('Error adding goal: $error')),
        );
      }

      _goalNameController.clear();
      _goalAmountController.clear();
    } else {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Please enter valid goal name and amount.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add New Goal'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _goalNameController,
                decoration: const InputDecoration(labelText: 'Goal Name'),
              ),
              TextField(
                controller: _goalAmountController,
                decoration: const InputDecoration(labelText: 'Goal Amount'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveGoal,
                child: const Text('Save Goal'),
              ),
            ],
          ),
        ),
        backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
      ),
    );
  }
}

extension on NotificationsHandler {
  void scheduleGoalNotification(String goalName) {
    // Add the actual notification scheduling logic here.
  }
}
