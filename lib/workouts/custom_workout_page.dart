import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class CustomWorkoutPlanPage extends StatefulWidget {
  const CustomWorkoutPlanPage({super.key});

  @override
  CustomWorkoutPlanPageState createState() => CustomWorkoutPlanPageState();
}

class CustomWorkoutPlanPageState extends State<CustomWorkoutPlanPage>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> _exercises = [];
  final List<String> _daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  String? _selectedDay;
  final TextEditingController _exerciseNameController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  bool _showAddExercise = false;
  final logger = Logger();
  List<String> logMessages = [];

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _loadExercises(); // Load exercises when the page is first opened

    // Initialize the notification plugin
    var initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  void dispose() {
    _exerciseNameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  // Function to load exercises from SharedPreferences
  Future<void> _loadExercises() async {
    final prefs = await SharedPreferences.getInstance();
    final String? exercisesString = prefs.getString('exercises');
    if (exercisesString != null) {
      List<dynamic> exercisesList = jsonDecode(exercisesString);
      setState(() {
        _exercises.clear();
        _exercises.addAll(exercisesList.map((e) => Map<String, dynamic>.from(e)));
      });
    }
  }

  // Function to save exercises to SharedPreferences
  Future<void> _saveExercises() async {
    final prefs = await SharedPreferences.getInstance();
    String exercisesString = jsonEncode(_exercises);
    prefs.setString('exercises', exercisesString);
  }

  // Function to show a notification
  Future<void> _showNotification(String title, String body) async {
    var androidDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.high,
      priority: Priority.high,
    );
    var notificationDetails = NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }

  // Function to add exercises
  void _addExercise() {
    if (_exerciseNameController.text.isEmpty ||
        _setsController.text.isEmpty ||
        _repsController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _selectedDay == null) {
      logger.w("All fields, including day selection, must be filled");
      setState(() {
        logMessages.add("All fields, including day selection, must be filled");
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      _exercises.add({
        'name': _exerciseNameController.text,
        'sets': int.tryParse(_setsController.text) ?? 0,
        'reps': int.tryParse(_repsController.text) ?? 0,
        'weight': double.tryParse(_weightController.text) ?? 0.0,
        'day': _selectedDay,
      });
      _showAddExercise = true; // Show success message after adding
      logMessages.add("Exercise added successfully");
    });

    _saveExercises();
    logger.i("Exercise added: ${_exerciseNameController.text}");

    // Call _showNotification to notify the user
    _showNotification("Exercise Added", "You have added a new exercise: ${_exerciseNameController.text}");

    // Clear text fields after adding an exercise
    _exerciseNameController.clear();
    _setsController.clear();
    _repsController.clear();
    _weightController.clear();
    _selectedDay = null;
  }

  // Function to delete exercise
  void _deleteExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
    });
    _saveExercises(); // Save the updated list after deletion
  }

  // Function to share the workout plan
  void _shareWorkoutPlan() {
    final StringBuffer shareContent = StringBuffer("My Workout Plan:\n\n");
    for (var exercise in _exercises) {
      shareContent.writeln(
          "${exercise['day']}: ${exercise['name']} - ${exercise['sets']} sets x ${exercise['reps']} reps @ ${exercise['weight']} kg");
    }

    Share.share(shareContent.toString());
  }

  @override
  Widget build(BuildContext context) {
    // Check for current theme brightness
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Custom Workout Plan"),
        backgroundColor: const Color(0xFF5D6C8A),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareWorkoutPlan,
            tooltip: 'Share Workout Plan',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedDay,
              hint: const Text("Select a day"),
              items: _daysOfWeek.map((String day) {
                return DropdownMenuItem<String>(value: day, child: Text(day));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDay = value;
                });
              },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _exerciseNameController,
              decoration: const InputDecoration(
                labelText: "Exercise Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _setsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Sets",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _repsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Reps",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Weight (kg)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addExercise,
              child: const Text("Add Exercise"),
            ),
            const SizedBox(height: 20),
            const Text(
              "Log Messages",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8.0),
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: logMessages.map((msg) {
                    return Text(
                      msg,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_showAddExercise)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  color: Colors.green,
                  padding: const EdgeInsets.all(8.0),
                  child: const Text(
                    'Exercise added successfully!',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            // Display added exercises
            ..._exercises.map((exercise) {
              return Card(
                elevation: 2.0,
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  title: Text(exercise['name']),
                  subtitle: Text(
                      "${exercise['day']}: ${exercise['sets']} sets x ${exercise['reps']} reps @ ${exercise['weight']} kg"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _deleteExercise(_exercises.indexOf(exercise));
                    },
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
