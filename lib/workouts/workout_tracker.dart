import 'package:flutter/material.dart';
import '../location/location_tracker.dart'; // Importing the LocationTracker class for tracking distance

// Stateful widget for tracking workout activities
class WorkoutTracker extends StatefulWidget {
  const WorkoutTracker({super.key}); // Constructor for the WorkoutTracker widget

  @override
  WorkoutTrackerState createState() => WorkoutTrackerState(); // Creating the state for the widget
}

// State class for managing the state of the WorkoutTracker
class WorkoutTrackerState extends State<WorkoutTracker> {
  final LocationTracker _locationTracker = LocationTracker(); // Instance of LocationTracker to manage location updates
  double totalDistance = 0.0; // Variable to store the total distance traveled

  @override
  void initState() {
    super.initState(); // Calling the superclass's initState
    // Initialize location tracking and update totalDistance when distance is tracked
    _locationTracker.initLocation((distance) {
      setState(() {
        totalDistance += distance; // Increment totalDistance by the newly tracked distance
      });
      // Logging the distance traveled using the logger from LocationTracker
      _locationTracker.logger.i("Distance traveled: $distance meters");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Tracker')), // App bar with title
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centering children in the column
          children: [
            // Displaying the total distance traveled, formatted to 2 decimal places
            Text('Total Distance: ${totalDistance.toStringAsFixed(2)} meters'),
            const SizedBox(height: 20), // Spacer between distance text and button
            ElevatedButton(
              onPressed: () {
                // Logic to stop tracking can go here (not yet implemented)
              },
              child: const Text('Stop Tracking'), // Button to stop tracking
            ),
          ],
        ),
      ),
    );
  }
}
