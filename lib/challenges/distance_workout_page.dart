import 'package:flutter/material.dart';

class DistanceWorkoutPage extends StatefulWidget {
  const DistanceWorkoutPage({super.key});

  @override
  DistanceWorkoutPageState createState() => DistanceWorkoutPageState();
}

class DistanceWorkoutPageState extends State<DistanceWorkoutPage> {
  final TextEditingController _distanceController = TextEditingController();
  double _loggedDistance = 0.0;
  final double _preloadedDistance = 5.0; // Preloaded workout distance (in km)

  @override
  void dispose() {
    _distanceController.dispose();
    super.dispose();
  }

  void _logDistance() {
    // Parse user-entered distance and add to logged distance
    setState(() {
      _loggedDistance += double.tryParse(_distanceController.text) ?? 0.0;
      _distanceController.clear(); // Clear the input field after logging
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Distance Workout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Distance Workout Page',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),

            // Preloaded workout section
            Text(
              'Preloaded Workout: $_preloadedDistance km',
              style: const TextStyle(fontSize: 18, color: Colors.blue),
            ),
            const SizedBox(height: 20),

            // Input field for custom distance
            TextField(
              controller: _distanceController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter Distance (in km)',
                hintText: 'e.g. 5',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            // Button to log the distance
            ElevatedButton(
              onPressed: _logDistance,
              child: const Text('Log Distance'),
            ),
            const SizedBox(height: 20),

            // Display total logged distance
            Text(
              'Total Logged Distance: $_loggedDistance km',
              style: const TextStyle(fontSize: 18, color: Colors.green),
            ),
            const SizedBox(height: 20),

            // Motivational message
            const Text(
              'Keep pushing your limits! Every meter counts.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
