import 'package:fitbattles/settings/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Leaderboard refreshed'),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('points', descending: true)
            .limit(10)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error loading leaderboard'),
            );
          }
          // Map each document in the snapshot to a list of player data with null checks
          final leaderboardData = snapshot.data?.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            return {
              'name': data['name'] ?? 'Unknown',
              'points': data['points'] ?? 0,
              'streakDays': data['streakDays'] ?? 0,
              'imageUrl': data['imageUrl'] ?? 'assets/default_avatar.png',
            };
          }).toList() ?? [];

          return buildLeaderboardList(context, leaderboardData);
        },
      ),
    );
  }

  Widget buildLeaderboardList(BuildContext context, List<Map<String, dynamic>> leaderboardData) {
    return leaderboardData.isNotEmpty
        ? AnimationLimiter(
      child: ListView.builder(
        itemCount: leaderboardData.length,
        itemBuilder: (context, index) {
          final player = leaderboardData[index];
          String imageUrl = player['imageUrl'] ?? 'assets/default_avatar.png';

          // Define trophy colors based on rank
          Color trophyColor;
          if (index == 0) {
            trophyColor = Colors.amber;
          } else if (index == 1) {
            trophyColor = Colors.grey;
          } else if (index == 2) {
            trophyColor = Colors.brown;
          } else {
            trophyColor = Colors.transparent;
          }

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 600),
            child: SlideAnimation(
              horizontalOffset: -200.0,
              child: FadeInAnimation(
                child: Card(
                  margin: const EdgeInsets.all(AppDimens.cardMargin),
                  child: ListTile(
                    leading: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          backgroundImage: imageUrl.startsWith('http')
                              ? NetworkImage(imageUrl)
                              : AssetImage(imageUrl) as ImageProvider,
                          radius: AppDimens.avatarRadius,
                        ),
                        if (index < 3)
                          Positioned(
                            bottom: 0,
                            child: Icon(Icons.emoji_events, color: trophyColor),
                          ),
                      ],
                    ),
                    title: Text('#${index + 1} ${player['name']}'),
                    subtitle: Text('Streak: ${player['streakDays']} days'),
                    trailing: Text(
                      player['points'].toString(),
                      style: const TextStyle(fontSize: AppDimens.scoreFontSize),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    )
        : const Center(
      child: Text(
        'No leaderboard data available',
        style: TextStyle(fontSize: AppDimens.noDataFontSize),
      ),
    );
  }
}