import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class WorkoutTrackingPage extends StatefulWidget {
  const WorkoutTrackingPage({super.key});

  @override
  WorkoutTrackingPageState createState() => WorkoutTrackingPageState();
}

class WorkoutTrackingPageState extends State<WorkoutTrackingPage> {
  bool isWorkingOut = false;
  Duration workoutDuration = Duration.zero;
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _calorieController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String selectedWorkoutType = 'Weightlifting';
  String selectedIntensity = 'Moderate';
  double userWeight = 70.0;

  final List<String> workoutTips = [
    "Try increasing your reps to boost strength.",
    "Add 5 minutes of cardio to improve stamina.",
    "Focus on form for better results and avoid injuries.",
    "Challenge yourself with a new HIIT workout!",
    "Incorporate rest days for muscle recovery."
  ];

  final List<String> workoutTypes = [
    'Running',
    'Weightlifting',
    'Cycling',
    'Swimming',
    'Yoga',
    'Walking',
  ];

  final List<String> workoutIntensities = [
    'Light',
    'Moderate',
    'Vigorous',
  ];

  String getRandomWorkoutTip() {
    final random = Random();
    return workoutTips[random.nextInt(workoutTips.length)];
  }

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
    double caloriesBurned = met * weightInKg * durationInHours * intensityMultiplier;
    return caloriesBurned;
  }

  int calculatePoints(double calories) {
    return (calories / 10).round(); // 1 point per 10 calories burned
  }

  void showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

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

      _durationController.clear();
      _calorieController.clear();
    } catch (e) {
      showSnackBar('Error saving workout data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Tracker'),
        backgroundColor: const Color(0xFF5D6C8A),
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
                items: workoutTypes.map<DropdownMenuItem<String>>((String value) {
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
                items: workoutIntensities.map<DropdownMenuItem<String>>((String value) {
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
                                'Estimated calories burned: ${estimatedCalories.toStringAsFixed(2)}')),
                          );

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
                        hintText: 'Calories',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*')),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Save Workout Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            if (_calorieController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text(
                                    'Please enter calories burned')),
                              );
                            } else {
                              _saveWorkoutData();
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 50,
                              vertical: 15),
                        ),
                        child: const Text('Save Workout', style: TextStyle(
                            fontSize: 18)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Today's Workout Tip Card
                    Card(
                      color: Colors.lightBlue[50],
                      child: ListTile(
                        title: const Text('Today\'s Workout Tip'),
                        subtitle: Text(getRandomWorkoutTip()),
                        leading: const Icon(Icons.fitness_center, color: Colors.blue),
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