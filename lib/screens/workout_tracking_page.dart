import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance

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
            Text(
              _formatDuration(workoutDuration),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
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
            Form(
              key: _formKey,
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
                      FilteringTextInputFormatter.digitsOnly,
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
                  ElevatedButton(
                    onPressed: _logWorkout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text('Log Workout'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Calories Burned: 100',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            const Text(
              'Intensity: Moderate',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logWorkout() async {
    if (_formKey.currentState!.validate()) {
      final int calories = int.parse(_calorieController.text);

      // Save workout data to Firestore
      await _firestore.collection('workouts').add({
        'calories': calories,
        'duration': workoutDuration.inSeconds,
        'timestamp': Timestamp.now(),
        'workoutType': 'Strength',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Workout logged: $calories calories')),
      );

      // Clear input and reset state
      _calorieController.clear();
      setState(() {
        workoutDuration = Duration.zero;
        isWorkingOut = false;
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
