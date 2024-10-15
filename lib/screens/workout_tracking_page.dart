import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  double estimateCaloriesBurned(String workoutType, String intensity, double durationInHours, double weightInKg) {
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
        intensityMultiplier = 1.0; // Keep MET value as is for moderate intensity
        break;
      case 'Vigorous':
        intensityMultiplier = 1.25; // Increase MET value for vigorous intensity
        break;
    }

    // Get the MET value for the selected workout type
    double met = metValues[workoutType] ?? 1.0; // Default MET value

    // Calculate calories burned using the formula: Calories = MET * weight (in kg) * duration (in hours) * intensityMultiplier
    double caloriesBurned = met * weightInKg * durationInHours * intensityMultiplier;

    return caloriesBurned;
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
                      FilteringTextInputFormatter.digitsOnly, // Restrict input to digits
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
                        double durationInHours = int.parse(_durationController.text) / 60.0;

                        // Estimate calories burned based on workout type, intensity, duration, and weight
                        double estimatedCalories = estimateCaloriesBurned(selectedWorkoutType, selectedIntensity, durationInHours, userWeight);

                        // Show estimated calories to the user
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Estimated calories burned: ${estimatedCalories.toStringAsFixed(2)}')),
                        );

                        // Auto-fill the calorie input field with the estimated value
                        _calorieController.text = estimatedCalories.toStringAsFixed(2);
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
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly, // Restrict input to digits
                    ],
                    // Removed the validator since it's now optional
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}