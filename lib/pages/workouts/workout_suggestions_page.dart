import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class WorkoutSuggestionsPage extends StatefulWidget {
  const WorkoutSuggestionsPage({super.key});

  @override
  WorkoutSuggestionsPageState createState() => WorkoutSuggestionsPageState();
}

class WorkoutSuggestionsPageState extends State<WorkoutSuggestionsPage> {
  final List<Map<String, dynamic>> _exercises = [];
  final TextEditingController _exerciseNameController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final logger = Logger();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Workout Suggestions
  final Map<String, List<String>> workoutSuggestions = {
    'Full-Body Workout': [
      'Push-ups: 3 sets of 12 reps',
      'Squats: 3 sets of 15 reps',
      'Plank: 3 sets of 30 seconds',
      'Lunges: 3 sets of 12 reps per leg',
      'Mountain Climbers: 3 sets of 20 seconds'
    ],
    'Yoga for Beginners': [
      'Child’s Pose: 1 minute',
      'Cat-Cow Pose: 1 minute',
      'Downward Dog: 1 minute',
      'Warrior Pose: 1 minute per side',
      'Tree Pose: 30 seconds per side'
    ],
    'HIIT Cardio': [
      'Jumping Jacks: 3 sets of 30 seconds',
      'High Knees: 3 sets of 30 seconds',
      'Burpees: 3 sets of 10 reps',
      'Mountain Climbers: 3 sets of 30 seconds',
      'Plank Jacks: 3 sets of 20 seconds'
    ],
    'Core Strength': [
      'Crunches: 3 sets of 15 reps',
      'Russian Twists: 3 sets of 20 reps',
      'Leg Raises: 3 sets of 12 reps',
      'Bicycle Crunches: 3 sets of 20 reps',
      'Plank: 3 sets of 30 seconds'
    ],
    'Leg Day Routine': [
      'Squats: 3 sets of 15 reps',
      'Deadlifts: 3 sets of 12 reps',
      'Lunges: 3 sets of 12 reps per leg',
      'Step-ups: 3 sets of 15 reps per leg',
      'Calf Raises: 3 sets of 20 reps'
    ],
  };

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

  // Function to show workout details
  void _showWorkoutDetails(String workoutName, List<String> exercises) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                workoutName,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...exercises.map((exercise) => ListTile(
                title: Text(exercise),
              )),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Custom Workout Plan"),
        backgroundColor: const Color(0xFF5D6C8A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              "Workout Suggestions",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...workoutSuggestions.entries.map((entry) {
              return Card(
                elevation: 2.0,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text(entry.key),
                  subtitle: const Text("Tap to view details"),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () => _showWorkoutDetails(entry.key, entry.value),
                ),
              );
            }),
            const SizedBox(height: 20),
            // Display added exercises
            ..._exercises.map((exercise) {
              return Card(
                elevation: 2.0,
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  title: Text(exercise['name']),
                  subtitle: Text(
                      "${exercise['day']}: ${exercise['sets']} sets x ${exercise['reps']} reps @ ${exercise['weight']} kg"),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}