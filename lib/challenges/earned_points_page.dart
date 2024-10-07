import 'package:flutter/material.dart'; // Importing Flutter material package for UI components

// This widget represents a page that displays the user's earned points and related statistics.
class EarnedPointsPage extends StatelessWidget {
  final int points; // Points earned by the user
  final int streakDays; // Number of days in the user's streak
  final int totalChallengesCompleted; // Total challenges completed
  final int pointsEarnedToday; // Points earned today
  final int bestDayPoints; // Best day points

  // Constructor for the EarnedPointsPage, requiring points, streakDays, and additional statistics as parameters.
  const EarnedPointsPage({
    super.key,
    required this.points,
    required this.streakDays,
    required this.totalChallengesCompleted,
    required this.pointsEarnedToday,
    required this.bestDayPoints,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate the progress as a fraction of the goal (1000 points)
    double progress = points / 1000;

    // Determine awards based on challenges completed
    List<String> awards = _determineAwards(totalChallengesCompleted);

    // Determine the user's rank based on points
    String rank = _determineRank(points);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Earned Points'), // Title of the page
        backgroundColor: const Color(0xFF5D6C8A), // Custom color for the AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding around the main content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          // Center-align the column contents
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
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 20), // Space between elements

            // Progress bar to visualize the points earned towards the goal
            ClipRRect(
              borderRadius: BorderRadius.circular(10), // Rounded corners for the progress bar
              child: LinearProgressIndicator(
                value: progress, // Progress based on points earned / 1000
                minHeight: 10, // Minimum height of the progress bar
                backgroundColor: Colors.grey[300], // Background color of the progress bar
                color: const Color(0xFF85C83E), // Progress color
              ),
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
                'Keep going! You’re doing great!',
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

            // Display the user's rank
            Text(
              'Your Rank: $rank',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Display awarded trophies
            if (awards.isNotEmpty) ...[
              const Text(
                'Awards:',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...awards.map((award) => Text(
                award,
                style: const TextStyle(fontSize: 18),
              )),
              const SizedBox(height: 20),
            ],

            // Call to build the statistics section with streak information
            _buildStatsSection(),

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
  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start
      children: [
        const Text(
          'Statistics',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10), // Space between elements

        // Displaying total challenges completed
        Text(
          'Total Challenges Completed: $totalChallengesCompleted',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 5), // Space between elements

        // Displaying points earned today
        Text(
          'Points Earned Today: $pointsEarnedToday',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 5), // Space between elements

        // Displaying the best day for points earned
        Text(
          'Best Day: $bestDayPoints points',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 20), // Space between elements

        // Display current streak information with dynamic color based on streakDays
        Text(
          'Current Streak: $streakDays days',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: streakDays > 0 ? Colors.orange : Colors.grey, // Color changes based on the streak
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

  // Function to determine awards based on challenges completed
  List<String> _determineAwards(int challengesCompleted) {
    List<String> awards = [];

    if (challengesCompleted >= 5) {
      awards.add('🏆 Bronze Trophy: Completed 5 Challenges');
    }
    if (challengesCompleted >= 10) {
      awards.add('🏆 Silver Trophy: Completed 10 Challenges');
    }
    if (challengesCompleted >= 20) {
      awards.add('🏆 Gold Trophy: Completed 20 Challenges');
    }
    if (challengesCompleted >= 50) {
      awards.add('🏆 Platinum Trophy: Completed 50 Challenges');
    }

    return awards;
  }

  // Function to determine the rank based on points earned
  String _determineRank(int points) {
    if (points < 100) {
      return 'Novice';
    } else if (points < 500) {
      return 'Intermediate';
    } else if (points < 1000) {
      return 'Advanced';
    } else {
      return 'Master';
    }
  }
}
