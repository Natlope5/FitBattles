import 'package:flutter/material.dart';
import '../location/location_tracker.dart';

class WorkoutTracker extends StatefulWidget {
  const WorkoutTracker({super.key});

  @override
  WorkoutTrackerState createState() => WorkoutTrackerState();
}

class WorkoutTrackerState extends State<WorkoutTracker> {
  final LocationTracker _locationTracker = LocationTracker();
  double totalDistance = 0.0;

  @override
  void initState() {
    super.initState();
    _locationTracker.initLocation((distance) {
      setState(() {
        totalDistance += distance; // Update total distance
      });
      _locationTracker.logger.i("Distance traveled: $distance meters");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Tracker')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Total Distance: ${totalDistance.toStringAsFixed(2)} meters'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Logic to stop tracking can go here
              },
              child: const Text('Stop Tracking'),
            ),
          ],
        ),
      ),
    );
  }
}
