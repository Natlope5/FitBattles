import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore package
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart'; // Import animation package

// This widget represents a page that displays the leaderboard.
class LeaderboardPage extends StatelessWidget {
  // Constructor for the LeaderboardPage
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'), // Title of the AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh), // Refresh icon
            onPressed: () {
              // Placeholder for refresh action
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Leaderboard refreshed!'),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('score', descending: true) // Order by score
            .limit(10) // Limit to top 10 players
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading leaderboard.'));
          }
          final leaderboardData = snapshot.data?.docs ?? []; // Retrieve leaderboard data

          return leaderboardData.isNotEmpty // Check if there's data to display
              ? AnimationLimiter( // Wrap the ListView in AnimationLimiter
            child: ListView.builder(
              itemCount: leaderboardData.length,
              itemBuilder: (context, index) {
                final player = leaderboardData[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 500), // Animation duration
                  child: FadeInAnimation(
                    child: Card( // Card for better visual representation
                      margin: const EdgeInsets.all(8.0), // Margin around each card
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(player['imageUrl'] ?? ''), // Display user's image
                          radius: 30, // Radius of the avatar
                        ),
                        title: Text(player['name']), // Display player's name
                        subtitle: Text('Streak: ${player['streakDays']} days'), // Show streak info
                        trailing: Text(
                          player['score'].toString(), // Display player's score
                          style: const TextStyle(fontSize: 18), // Score styling
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
              : const Center( // Center widget for no data scenario
            child: Text(
              'No leaderboard data available.', // Message when no data
              style: TextStyle(fontSize: 24), // Style of the text
            ),
          );
        },
      ),
    );
  }
}
