import 'package:flutter/material.dart'; // Importing the Flutter Material package for UI components

// This widget represents a page for strength workouts.
class StrengthWorkoutPage extends StatelessWidget {
  const StrengthWorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Strength Workout'), // Title of the AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Adding padding for better layout
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Centering content vertically
          children: [
            const Icon(
              Icons.fitness_center, // Icon representing fitness
              size: 100, // Size of the icon
              color: Colors.blue, // Color of the icon
            ),
            const SizedBox(height: 20), // Spacer for better layout
            const Text(
              'Strength Workout Challenges', // Updated title for context
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // Bold font for emphasis
            ),
            const SizedBox(height: 20), // Spacer
            const Text(
              'Here are some sample workouts:', // Additional text for context
              style: TextStyle(fontSize: 18), // Smaller font for the context
            ),
            const SizedBox(height: 10), // Spacer
            Expanded(
              child: ListView(
                children: const [
                  ListTile(
                    title: Text('1. Push Ups'),
                    subtitle: Text('3 sets of 10 reps'), // Details of the workout
                  ),
                  ListTile(
                    title: Text('2. Squats'),
                    subtitle: Text('3 sets of 15 reps'),
                  ),
                  ListTile(
                    title: Text('3. Sit ups'),
                    subtitle: Text('3 sets of 8 reps'),
                  ),
                  ListTile(
                    title: Text('4. Bench Press'),
                    subtitle: Text('3 sets of 10 reps'),
                  ),
                  ListTile(
                    title: Text('5. Lunges'),
                    subtitle: Text('3 sets of 12 reps per leg'), // Added a new challenge
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10), // Spacer
            ElevatedButton(
              onPressed: () {
                // Placeholder for starting a workout
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Workout started!'), // Feedback for starting the workout
                  ),
                );
              },
              child: const Text('Start Workout'), // Button to start a workout
            ),
          ],
        ),
      ),
    );
  }
}

