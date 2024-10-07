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
  final TextEditingController _calorieController = TextEditingController(); // Controller for calorie input
  final _formKey = GlobalKey<FormState>(); // Key for form validation

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
              'Workout Type: Strength',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Timer Display
            Text(
              _formatDuration(workoutDuration),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Workout Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isWorkingOut = !isWorkingOut;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text(isWorkingOut ? 'Pause' : 'Start'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      workoutDuration = Duration.zero;
                      isWorkingOut = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Stop'),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Calorie Input Section
            Form(
              key: _formKey, // Assign form key
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Enter Calories Burned:',
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a calorie value';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Process calorie input
                        final int calories = int.parse(_calorieController.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Calories logged: $calories')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text('Log Calories'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Calories Burned (Placeholder)
            const Text(
              'Calories Burned: 100',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            // Workout Intensity (Placeholder)
            const Text(
              'Intensity: Moderate',
              style: TextStyle(fontSize: 20),
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
