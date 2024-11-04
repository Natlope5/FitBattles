import 'package:fitbattles/settings/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore package
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart'; // Import animation package
import 'package:fitbattles/l10n/app_localizations.dart';

// This widget represents a page that displays the leaderboard.
class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Access localized strings
    final localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.leaderboardTitle), // Title from strings
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh), // Refresh icon
            onPressed: () {
              // Show SnackBar using localized string
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(localizations.leaderboardRefreshed),
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
            return Center(
              child: Text(localizations.errorLoadingLeaderboard), // Error message
            );
          }

          final leaderboardData = snapshot.data?.docs ?? []; // Retrieve leaderboard data

          return leaderboardData.isNotEmpty
              ? AnimationLimiter( // Wrap the ListView in AnimationLimiter
            child: ListView.builder(
              itemCount: leaderboardData.length,
              itemBuilder: (context, index) {
                final player = leaderboardData[index];

                // Use a default image if imageUrl is null or empty
                String imageUrl = player['imageUrl'] ?? '';
                if (imageUrl.isEmpty) {
                  imageUrl = 'assets/default_avatar.png'; // Set default image
                }

                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 500), // Animation duration
                  child: FadeInAnimation(
                    child: Card( // Card for better visual representation
                      margin: const EdgeInsets.all(AppDimens.cardMargin), // Use dimension for margin
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: imageUrl.startsWith('http')
                              ? NetworkImage(imageUrl) // Use network image if URL is valid
                              : AssetImage(imageUrl) as ImageProvider, // Fallback to asset image
                          radius: AppDimens.avatarRadius, // Use dimension for radius
                        ),
                        title: Text(player['name'] ?? 'Unknown'), // Display player's name, fallback if null
                        subtitle: Text(
                          '${localizations.streak}: ${player['streakDays'] ?? 0} ${localizations.days}', // Show streak info using localized string
                        ),
                        trailing: Text(
                          player['score']?.toString() ?? '0', // Display player's score, fallback to 0
                          style: const TextStyle(fontSize: AppDimens.scoreFontSize), // Use dimension for score font size
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
              : Center( // Center widget for no data scenario
            child: Text(
              localizations.noLeaderboardData, // No data message
              style: const TextStyle(fontSize: AppDimens.noDataFontSize), // Use dimension for no data font size
            ),
          );
        },
      ),
    );
  }
}
