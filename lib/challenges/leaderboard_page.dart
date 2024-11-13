import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// This is the main page for displaying the leaderboard
class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  LeaderboardPageState createState() => LeaderboardPageState();
}

class LeaderboardPageState extends State<LeaderboardPage> {
  // List to hold the leaderboard data retrieved from Firestore
  final List<Map<String, dynamic>> _leaderboardData = [];

  // Initializes the page and listens for updates to the leaderboard
  @override
  void initState() {
    super.initState();
    _listenToLeaderboardChanges(); // Listen for real-time updates from Firestore
  }

  // Listens for real-time changes in the leaderboard data from Firestore
  void _listenToLeaderboardChanges() {
    FirebaseFirestore.instance
        .collection('users') // Refers to the 'users' collection in Firestore
        .orderBy('points', descending: true) // Orders users by points in descending order
        .snapshots() // Listens to real-time updates
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) { // Check if there are any documents in the snapshot
        final newLeaderboardData = snapshot.docs.map((doc) {
          final data = doc.data(); // Retrieves the document data
          return {
            'id': doc.id, // Document ID (used to update points later)
            'name': data['name'] ?? 'Unknown', // User's name, default to 'Unknown' if not available
            'points': data['points'] ?? 0, // User's points, default to 0 if not available
            'streakDays': data['streakDays'] ?? 0, // User's streak, default to 0 if not available
            'imageUrl': data['imageUrl'] ?? 'assets/default_avatar.png', // User's profile image URL, default to 'assets/default_avatar.png'
          };
        }).toList(); // Convert the documents to a list of maps

        // Update the state with the new leaderboard data
        setState(() {
          _leaderboardData.clear(); // Clear the old leaderboard data
          _leaderboardData.addAll(newLeaderboardData); // Add the new leaderboard data
        });
      }
    });
  }

  // Function to update the user's points in Firestore
  Future<void> _updateUserPoints(String userId, int pointsToAdd) async {
    final DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final DocumentSnapshot userSnapshot = await transaction.get(userRef);
        if (userSnapshot.exists) { // If the user exists
          final int currentPoints = userSnapshot['points'] ?? 0; // Get the current points, default to 0 if not available
          transaction.update(userRef, {'points': currentPoints + pointsToAdd}); // Update the points
        }
      });

      // Show success message if the points were updated successfully
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Points updated successfully')),
        );
      }
    } catch (e) {
      // Show error message if the points update failed
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update points: $e')),
        );
      }
    }
  }

  // Builds the UI for the leaderboard page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'), // Title for the app bar
        actions: [
          // Refresh button to reload leaderboard data
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _listenToLeaderboardChanges,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildLeaderboardList(context), // Displays the leaderboard list
          ),
        ],
      ),
    );
  }

  // Builds the list of leaderboard items
  Widget _buildLeaderboardList(BuildContext context) {
    return _leaderboardData.isNotEmpty // Checks if there is any leaderboard data
        ? ListView.builder(
      itemCount: _leaderboardData.length, // Number of items in the leaderboard
      itemBuilder: (context, index) {
        final player = _leaderboardData[index]; // Get the player data for the current index
        String imageUrl = player['imageUrl'] ?? 'assets/default_avatar.png'; // Get the player's image URL, default to the avatar if not available

        // Determine the trophy color based on the player's rank
        Color trophyColor;
        if (index == 0) {
          trophyColor = Colors.amber; // First place: Gold
        } else if (index == 1) {
          trophyColor = Colors.grey; // Second place: Silver
        } else if (index == 2) {
          trophyColor = Colors.brown; // Third place: Bronze
        } else {
          trophyColor = Colors.transparent; // No trophy for others
        }

        // Return the ListTile widget for each leaderboard item
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: imageUrl.startsWith('http')
                ? NetworkImage(imageUrl) // Use a network image if the URL starts with 'http'
                : AssetImage(imageUrl) as ImageProvider, // Use an asset image if it's a local file
          ),
          title: Text(player['name']), // Display the player's name
          subtitle: Text('Points: ${player['points']}'), // Display the player's points
          trailing: Icon(Icons.star, color: trophyColor), // Display the trophy icon
          onTap: () {
            _updateUserPoints(player['id'], 10); // Update the player's points when tapped
          },
        );
      },
    )
        : const Center(child: Text('No leaderboard data available.')); // Show a message if there is no leaderboard data
  }
}
