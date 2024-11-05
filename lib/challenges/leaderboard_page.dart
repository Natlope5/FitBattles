import 'package:fitbattles/settings/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fitbattles/l10n/app_localizations.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  final bool useSampleData = true; // Set to `true` to use sample data

  List<Map<String, dynamic>> get sampleLeaderboardData => [
    {
      'name': 'John Doe',
      'score': 1500,
      'streakDays': 50,
      'imageUrl': 'https://via.placeholder.com/150',
    },
    {
      'name': 'Jane Smith',
      'score': 1400,
      'streakDays': 45,
      'imageUrl': 'https://via.placeholder.com/150',
    },
    {
      'name': 'Bob Brown',
      'score': 1350,
      'streakDays': 30,
      'imageUrl': 'https://via.placeholder.com/150',
    },
    {
      'name': 'Alice Green',
      'score': 1200,
      'streakDays': 20,
      'imageUrl': 'https://via.placeholder.com/150',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.leaderboardTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(localizations.leaderboardRefreshed),
                ),
              );
            },
          ),
        ],
      ),
      body: useSampleData
          ? buildLeaderboardList(context, sampleLeaderboardData, localizations)
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('score', descending: true)
            .limit(10)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(localizations.errorLoadingLeaderboard),
            );
          }
          final leaderboardData = snapshot.data?.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList() ??
              [];

          return buildLeaderboardList(context, leaderboardData, localizations);
        },
      ),
    );
  }

  Widget buildLeaderboardList(BuildContext context, List<Map<String, dynamic>> leaderboardData, AppLocalizations localizations) {
    return leaderboardData.isNotEmpty
        ? AnimationLimiter(
      child: ListView.builder(
        itemCount: leaderboardData.length,
        itemBuilder: (context, index) {
          final player = leaderboardData[index];
          String imageUrl = player['imageUrl'] ?? 'assets/default_avatar.png';

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
              horizontalOffset: -200.0, // Slide in from the left
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
                    title: Text('#${index + 1} ${player['name'] ?? 'Unknown'}'),
                    subtitle: Text('${localizations.streak}: ${player['streakDays'] ?? 0} ${localizations.days}'),
                    trailing: Text(
                      player['score']?.toString() ?? '0',
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
        : Center(
      child: Text(
        localizations.noLeaderboardData,
        style: const TextStyle(fontSize: AppDimens.noDataFontSize),
      ),
    );
  }
}
