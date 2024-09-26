import 'package:flutter/material.dart'; // Importing the Flutter Material package for UI components

// This widget represents a page that displays the leaderboard.
class LeaderboardPage extends StatelessWidget {
  // Constructor for the LeaderboardPage
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Build method that describes the UI of the LeaderboardPage
    return Scaffold(
      // Scaffold provides a structure for the visual interface
      appBar: AppBar(
        title: const Text('Leaderboard'), // Title of the AppBar
      ),

      body: const Center( // Center widget to center-align its child within the body
        child: Text(
          'See the leaderboard here!', // Text to display on the page
          style: TextStyle(fontSize: 24), // Style of the text (font size)
        ),
      ),
    );
  }
}
