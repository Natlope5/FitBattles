import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';

class AddGoalPage extends StatefulWidget {
  const AddGoalPage({super.key});

  @override
  AddGoalPageState createState() => AddGoalPageState();
}

class AddGoalPageState extends State<AddGoalPage> {
  final TextEditingController _goalNameController = TextEditingController();
  final TextEditingController _goalAmountController = TextEditingController();
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'goal_channel', // Channel ID
      'Goal Notifications', // Channel Name
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    // Correct method signature with named arguments for notification details
    await _notificationsPlugin.show(
      0, // Notification ID (Positional)
      title, // Title (Positional)
      body, // Body (Positional)
      platformChannelSpecifics, // Notification details (Named argument)
      payload: 'Some data', // Optional payload (Named argument)
    );
  }

  Future<void> _saveGoal() async {
    final String goalName = _goalNameController.text;
    final double? goalAmount = double.tryParse(_goalAmountController.text);

    if (goalName.isNotEmpty && goalAmount != null) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> goalHistory = prefs.getStringList('currentGoals') ?? [];

      final newGoal = {
        'name': goalName,
        'amount': goalAmount,
        'currentProgress': 0.0,
        'isCompleted': false,
      };

      goalHistory.add(jsonEncode(newGoal));
      await prefs.setStringList('currentGoals', goalHistory);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Goal added successfully!')),
        );
      }

      _goalNameController.clear();
      _goalAmountController.clear();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please enter a valid goal name and amount.')),
        );
      }
    }
  }

  Future<void> _updateProgressAndCheckCompletion(String goalName, double progress) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> goalHistory = prefs.getStringList('currentGoals') ?? [];

    List<Map<String, dynamic>> updatedGoals = goalHistory.map((goal) {
      Map<String, dynamic> decodedGoal = jsonDecode(goal);
      if (decodedGoal['name'] == goalName && !decodedGoal['isCompleted']) {
        decodedGoal['currentProgress'] += progress;

        if (decodedGoal['currentProgress'] >= decodedGoal['amount']) {
          decodedGoal['isCompleted'] = true;
          _showNotification(
              'Goal Achieved!', 'You have completed the goal: $goalName');
        }
      }
      return decodedGoal;
    }).toList();

    List<String> encodedGoals = updatedGoals.map((goal) => jsonEncode(goal)).toList();
    await prefs.setStringList('currentGoals', encodedGoals);

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Goal')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Goal Name:', style: TextStyle(fontSize: 16)),
            TextField(controller: _goalNameController),
            const SizedBox(height: 16),
            const Text('Goal Amount:', style: TextStyle(fontSize: 16)),
            TextField(
              controller: _goalAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Enter a number'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveGoal,
              child: const Text('Save Goal'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // Update progress for a specific goal (example: increase by 10 units)
                final String goalName = _goalNameController.text;
                if (goalName.isNotEmpty) {
                  await _updateProgressAndCheckCompletion(goalName, 10.0);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(
                        'Please enter a goal name to update progress.')),
                  );
                }
              },
              child: const Text('Update Progress'),
            ),
          ],
        ),
      ),
    );
  }
}
