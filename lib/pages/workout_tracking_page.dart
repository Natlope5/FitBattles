import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkoutTrackingPage extends StatefulWidget {
  const WorkoutTrackingPage({super.key});

  @override
  _WorkoutTrackingPageState createState() => _WorkoutTrackingPageState();
}

class _WorkoutTrackingPageState extends State<WorkoutTrackingPage> {
  bool isWorkingOut = false;
  Duration workoutDuration = Duration.zero;
  final TextEditingController _durationController = TextEditingController(); // Controller for manually inputting workout duration
  final TextEditingController _calorieController = TextEditingController(); // Controller for calorie input
  final _formKey = GlobalKey<FormState>(); // Key for form validation

  String selectedWorkoutType = 'Weightlifting'; // Default workout type
  String selectedIntensity = 'Moderate'; // Default workout intensity
  double userWeight = 70.0; // Example weight in kg, replace with actual user data

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

  // Function to estimate calories burned based on workout type, duration, intensity, and weight
  double estimateCaloriesBurned(String workoutType, String intensity,
      double durationInHours, double weightInKg) {
    // Define MET values for different activities and intensities
    Map<String, double> metValues = {
      'Running': 11.0,
      'Weightlifting': 6.0,
      'Cycling': 8.0,
      'Swimming': 7.0,
      'Yoga': 3.0,
      'Walking': 3.8,
    };

    double intensityMultiplier = 1.0;

    // Adjust MET value based on intensity
    switch (intensity) {
      case 'Light':
        intensityMultiplier = 0.75; // Reduce MET value for light intensity
        break;
      case 'Moderate':
        intensityMultiplier =
        1.0; // Keep MET value as is for moderate intensity
        break;
      case 'Vigorous':
        intensityMultiplier = 1.25; // Increase MET value for vigorous intensity
        break;
    }

    // Get the MET value for the selected workout type
    double met = metValues[workoutType] ?? 1.0; // Default MET value

    // Calculate calories burned using the formula: Calories = MET * weight (in kg) * duration (in hours) * intensityMultiplier
    double caloriesBurned = met * weightInKg * durationInHours *
        intensityMultiplier;

    return caloriesBurned;
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
      // Get the current user ID
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // Prepare data to save
      Map<String, dynamic> workoutData = {
        'workoutType': selectedWorkoutType,
        'intensity': selectedIntensity,
        'duration': int.parse(_durationController.text),
        'calories': double.parse(_calorieController.text),
        'timestamp': Timestamp.now(),
      };

      // Save data to Firestore under the user's workouts collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('workouts')
          .add(workoutData);

      // Show success message
      showSnackBar('Workout data saved successfully!');

      // Clear the input fields after saving
      _durationController.clear();
      _calorieController.clear();
    } catch (e) {
      // Handle errors
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
        child: SingleChildScrollView( // Use SingleChildScrollView to prevent overflow
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
                key: _formKey, // Assign form key
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
                        // Restrict input to digits
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

                    // Automatically suggest calories burned based on user inputs
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Get manually entered duration in hours
                          double durationInHours = int.parse(
                              _durationController.text) / 60.0;

                          // Estimate calories burned based on workout type, intensity, duration, and weight
                          double estimatedCalories = estimateCaloriesBurned(
                            selectedWorkoutType,
                            selectedIntensity,
                            durationInHours,
                            userWeight,
                          );

                          // Show estimated calories to the user
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(
                                'Estimated calories burned: ${estimatedCalories
                                    .toStringAsFixed(2)}')),
                          );

                          // Auto-fill the calorie input field with the estimated value
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

                    // Manual Calorie Input (Optional)
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
                            RegExp(r'^\d*\.?\d*')), // Allow decimals
                      ],
                      // Removed the validator since it's now optional
                    ),
                    const SizedBox(height: 20),

                    // Save Workout Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Ensure that the calorie field is not empty
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