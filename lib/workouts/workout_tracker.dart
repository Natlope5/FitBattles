import 'package:flutter/material.dart';
import '../l10n/location_tracker.dart'; // Importing the LocationTracker class for tracking distance

// Stateful widget for tracking workout activities
class WorkoutTracker extends StatefulWidget {
  const WorkoutTracker({super.key});

  @override
  WorkoutTrackerState createState() => WorkoutTrackerState();
}

// State class for managing the state of the WorkoutTracker
class WorkoutTrackerState extends State<WorkoutTracker> {
  final LocationTracker _locationTracker = LocationTracker(); // Instance of LocationTracker to manage localization updates
  double totalDistance = 0.0; // Variable to store the total distance traveled
  bool isTracking = true; // Variable to control the state of tracking

  @override
  void initState() {
    super.initState();
    // Initialize localization tracking and update totalDistance when distance is tracked
    _locationTracker.initLocation(
          (distance) {
        if (isTracking) {
          setState(() {
            totalDistance += distance; // Increment totalDistance by the newly tracked distance
          });
          // Logging the distance traveled using the logger from LocationTracker
          _locationTracker.logger.i("Distance traveled: $distance meters");
        }
      },
          (error) {
        // Handle error, such as permission denial
        _showErrorDialog(error);
      },
          () {
        // Handle tracking start
        _locationTracker.logger.i("Tracking started.");
      } as String,
          () {
        // Handle tracking pause
        _locationTracker.logger.i("Tracking paused.");
      } as String,
    );
  }

  @override
  void dispose() {
    // Stop localization tracking when the widget is disposed
    _locationTracker.cancelLocationTracking();
    super.dispose();
  }

  // Method to show an error dialog if tracking fails
  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Tracker')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Displaying the total distance traveled, formatted to 2 decimal places
            Text('Total Distance: ${totalDistance.toStringAsFixed(2)} meters'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Logic to stop tracking
                setState(() {
                  isTracking = false; // Stop tracking
                });
                _locationTracker.logger.i("Tracking stopped.");
              },
              child: const Text('Stop Tracking'),
            ),
          ],
        ),
      ),
    );
  }
}

