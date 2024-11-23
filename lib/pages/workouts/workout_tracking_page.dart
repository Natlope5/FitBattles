import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:fitbattles/pages/workouts/workout_tips_page.dart';

class WorkoutTrackingPage extends StatefulWidget {
  const WorkoutTrackingPage({super.key});

  @override
  WorkoutTrackingPageState createState() => WorkoutTrackingPageState();
}

class WorkoutTrackingPageState extends State<WorkoutTrackingPage> {
  bool isWorkingOut = false;
  Duration workoutDuration = Duration.zero;
  final TextEditingController _durationController = TextEditingController(); // Controller for manually inputting workout duration
  final TextEditingController _calorieController = TextEditingController(); // Controller for calorie input
  final _formKey = GlobalKey<FormState>(); // Key for form validation

  String selectedWorkoutType = 'Weightlifting'; // Default workout type
  String selectedIntensity = 'Moderate'; // Default workout intensity
  double userWeight = 70.0; // Example weight in kg, replace with actual user data

  // Logger for tracking events
  final Logger logger = Logger();

  // Local notifications instance
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Dropdown options for workout types
  final List<String> workoutTypes = [
    'Running',
    'Weightlifting',
    'Cycling',
    'Swimming',
    'Yoga',
    'Walking',
  ];

  // Dropdown options for workout intensity
  final List<String> workoutIntensities = [
    'Light',
    'Moderate',
    'Vigorous',
  ];

  bool notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    // Initialize local notifications plugin
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Function to estimate calories burned based on workout type, duration, intensity, and weight
  double estimateCaloriesBurned(String workoutType, String intensity,
      double durationInHours, double weightInKg) {
    Map<String, double> metValues = {
      'Running': 11.0,
      'Weightlifting': 6.0,
      'Cycling': 8.0,
      'Swimming': 7.0,
      'Yoga': 3.0,
      'Walking': 3.8,
    };

    double intensityMultiplier = 1.0;
    switch (intensity) {
      case 'Light':
        intensityMultiplier = 0.75;
        break;
      case 'Moderate':
        intensityMultiplier = 1.0;
        break;
      case 'Vigorous':
        intensityMultiplier = 1.25;
        break;
    }

    double met = metValues[workoutType] ?? 1.0;
    double caloriesBurned = met * weightInKg * durationInHours *
        intensityMultiplier;
    return caloriesBurned;
  }

  // Function to calculate points from calories
  int calculatePoints(double calories) {
    return (calories / 10).round(); // 1 point per 10 calories burned
  }

  // Function to show SnackBar safely
  void showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  // Function to save workout data to Firestore
  Future<void> _saveWorkoutData() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      double caloriesBurned = double.parse(_calorieController.text);
      int points = calculatePoints(caloriesBurned);

      Map<String, dynamic> workoutData = {
        'workoutType': selectedWorkoutType,
        'intensity': selectedIntensity,
        'duration': int.parse(_durationController.text),
        'calories': caloriesBurned,
        'points': points,
        'timestamp': Timestamp.now(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('workouts')
          .add(workoutData);

      showSnackBar('Workout data saved successfully!');
      logger.i('Workout data saved: $workoutData');

      // Save data in shared preferences for persistence
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('lastCalories', caloriesBurned);
      await prefs.setInt('lastPoints', points);

      // Trigger notifications only if enabled
      if (notificationsEnabled) {
        _showNotification('Workout Data Saved', 'You earned $points points!');
        _triggerRestNotification();
      }

      _durationController.clear();
      _calorieController.clear();
    } catch (e) {
      showSnackBar('Error saving workout data: $e');
      logger.e('Error saving workout data: $e');
    }
  }


  // Function to show a notification
  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'workout_channel_id', 'Workout Notifications',
      channelDescription: 'Notification channel for workout data',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, title, body, platformChannelSpecifics,
      payload: 'Workout Data Saved',
    );
  }

  // Function to trigger a rest and hydration notification after adding an exercise
  // Function to trigger a rest and hydration notification after adding an exercise
  Future<void> _triggerRestNotification() async {
    if (!notificationsEnabled) return; // Skip if notifications are disabled

    // Set a rest time (e.g., 5 seconds after adding the exercise)
    const restTime = Duration(seconds: 5);

    // Wait for the rest period and trigger the rest notification
    await Future.delayed(restTime, () async {
      await _showNotification(
        "Rest Reminder",
        "It's time to rest, recover, and hydrate! Drink some water for optimal performance.",
      );
    });
  }
// Function to toggle notifications on/off
  void _toggleNotifications() {
    setState(() {
      notificationsEnabled = !notificationsEnabled;
    });
    showSnackBar(notificationsEnabled
        ? "Notifications enabled."
        : "Notifications disabled.");
  }

  @override
  Widget build(BuildContext context) {
    final random = Random();
    final List<String> workoutTips = [
      "Try increasing your reps to boost strength.",
      "Add 5 minutes of cardio to improve stamina.",
      "Focus on form for better results and avoid injuries.",
      "Challenge yourself with a new HIIT workout!",
      "Incorporate rest days for muscle recovery."
    ];
    String selectedTip = workoutTips[random.nextInt(workoutTips.length)];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Tracker'),
        backgroundColor: const Color(0xFF5D6C8A),
        actions: [
          // Notification toggle button
          IconButton(
            icon: Icon(
              notificationsEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off,
            ),
            onPressed: _toggleNotifications,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Track Your Workout',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Workout Type Dropdown
              DropdownButtonFormField<String>(
                value: selectedWorkoutType,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedWorkoutType = newValue!;
                  });
                },
                items: workoutTypes.map<DropdownMenuItem<String>>((
                    String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Select Workout Type',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Workout Intensity Dropdown
              DropdownButtonFormField<String>(
                value: selectedIntensity,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedIntensity = newValue!;
                  });
                },
                items: workoutIntensities.map<DropdownMenuItem<String>>((
                    String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Select Workout Intensity',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Duration Input Section
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Enter Duration (Minutes):',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _durationController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Duration in minutes',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a duration';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Estimate Calories Button
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          double durationInHours = int.parse(
                              _durationController.text) / 60.0;
                          double estimatedCalories = estimateCaloriesBurned(
                            selectedWorkoutType,
                            selectedIntensity,
                            durationInHours,
                            userWeight,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(
                                  'Estimated calories burned: ${estimatedCalories
                                      .toStringAsFixed(2)}')));

                          _calorieController.text =
                              estimatedCalories.toStringAsFixed(2);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text('Estimate Calories'),
                    ),
                    const SizedBox(height: 20),

                    // Manual Calorie Input
                    const Text(
                      'Or enter calories manually (optional):',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _calorieController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Calories burned',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),

                    // Save Button
                    ElevatedButton(
                      onPressed: _saveWorkoutData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Save Workout'),
                    ),
                    Card(
                      color: Colors.lightBlue[50],
                      child: ListTile(
                        title: const Text('Today\'s Workout Tip'),
                        subtitle: Text(selectedTip),
                        leading: const Icon(Icons.fitness_center, color: Colors.blue),
                        trailing: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DetailPage(
                                title: 'Workout Tip Detail',
                                content: 'Here’s more information on today\'s workout tip.',
                              ),
                            ),
                          ),
                          child: const Icon(Icons.arrow_forward),
                        ),
                      ),
                    ),
                    Card(
                      color: Colors.orange[50],
                      child: ListTile(
                        title: const Text('Post-Workout Tip'),
                        subtitle: Text('Stay hydrated and stretch after workouts to improve recovery.'),
                        leading: const Icon(Icons.local_drink, color: Colors.orange),
                        trailing: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DetailPage(
                                title: 'Post-Workout Tips',
                                content: 'More recovery tips after your workout.',
                              ),
                            ),
                          ),
                          child: const Icon(Icons.arrow_forward),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}