import 'package:flutter/material.dart'; // Importing Flutter material package for UI components

// This widget represents a page that displays the user's earned points and related statistics.
class EarnedPointsPage extends StatelessWidget {
  final int points; // Points earned by the user
  final int streakDays; // Number of days in the user's streak

  // Constructor for the EarnedPointsPage, requiring points and streakDays as parameters.
  const EarnedPointsPage({super.key, required this.points, required this.streakDays});

  @override
  Widget build(BuildContext context) {
    // Calculate the progress as a fraction of the goal (1000 points)
    double progress = points / 1000;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Earned Points'), // Title of the page
        backgroundColor: const Color(0xFF5D6C8A), // Custom color for the AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding around the main content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Center-align the column contents
          children: [
            const SizedBox(height: 20), // Space between elements

            // Title displaying the user's earned points
            const Text(
              'Your Earned Points',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20), // Space between elements

            // Display the total points earned
            Text(
              '$points Points',
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.green),
            ),

            const SizedBox(height: 20), // Space between elements

            // Progress bar to visualize the points earned towards the goal
            LinearProgressIndicator(
              value: progress, // Progress based on points earned / 1000
              minHeight: 10, // Minimum height of the progress bar
              backgroundColor: Colors.grey[300], // Background color of the progress bar
              color: const Color(0xFF85C83E), // Progress color
            ),

            const SizedBox(height: 10), // Space between elements

            // Text displaying the percentage of the goal reached
            Text(
              '${(progress * 100).toStringAsFixed(1)}% of your goal reached',
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 20), // Space between elements

            // Motivational message or encouragement based on progress
            if (progress < 1) ...[ // If the goal is not yet reached
              const Text(
                'Keep going! You are almost there!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 20),
            ] else ...[ // If the goal has been reached
              const Text(
                'Congratulations! You reached your goal!',
                style: TextStyle(fontSize: 18, color: Colors.green),
              ),
              const SizedBox(height: 20),
            ],

            // Call to build the statistics section with streak information
            _buildStatsSection(streakDays),

            const SizedBox(height: 30), // Space between elements

            // Button to navigate back to the home screen
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Navigate back to the previous screen
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, // Text color of the button
                backgroundColor: const Color(0xFF5D6C8A), // Background color of the button
              ),
              child: const Text('Back to Home'), // Button text
            ),
          ],
        ),
      ),
    );
  }

  // Function to build the statistics section including streaks
  Widget _buildStatsSection(int streakDays) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start
      children: [
        const Text(
          'Statistics',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10), // Space between elements

        // Displaying total challenges completed
        const Text(
          'Total Challenges Completed: 5',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 5), // Space between elements

        // Displaying points earned today
        const Text(
          'Points Earned Today: 150',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 5), // Space between elements

        // Displaying the best day for points earned
        const Text(
          'Best Day: 200 points',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 20), // Space between elements

        // Display current streak information with dynamic color based on streakDays
        Text(
          'Current Streak: $streakDays days',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: streakDays > 0 ? Colors.orange : Colors.grey // Color changes based on the streak
          ),
        ),
        const SizedBox(height: 5), // Space between elements

        // Message to encourage maintaining the streak
        const Text(
          'Maintain your streak to earn bonus points each day!',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }
}
