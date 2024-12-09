import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  LeaderboardPageState createState() => LeaderboardPageState();
}

class LeaderboardPageState extends State<LeaderboardPage> {
  final List<Map<String, dynamic>> _leaderboardData = [];

  @override
  void initState() {
    super.initState();
    _listenToLeaderboardChanges();
  }

  void _listenToLeaderboardChanges() {
    FirebaseFirestore.instance
        .collection('users')
        .orderBy('points', descending: true)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final newLeaderboardData = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'] ?? 'Unknown',
            'points': data['points'] ?? 0,
            'streakDays': data['streakDays'] ?? 0,
            'imageUrl': data['imageUrl'] ?? 'assets/default_avatar.png',
          };
        }).toList();

        setState(() {
          _leaderboardData.clear();
          _leaderboardData.addAll(newLeaderboardData);
        });
      }
    });
  }

  Future<void> _updateUserPoints(String userId, int pointsToAdd) async {
    final DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final DocumentSnapshot userSnapshot = await transaction.get(userRef);
        if (userSnapshot.exists) {
          final int currentPoints = userSnapshot['points'] ?? 0;
          transaction.update(userRef, {'points': currentPoints + pointsToAdd});
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Points updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update points: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _listenToLeaderboardChanges,
          ),
        ],
      ),
      body: _buildLeaderboardList(context),
    );
  }

  Widget _buildLeaderboardList(BuildContext context) {
    return _leaderboardData.isNotEmpty
        ? AnimationLimiter(
      child: ListView.builder(
        itemCount: _leaderboardData.length,
        itemBuilder: (context, index) {
          final player = _leaderboardData[index];
          String imageUrl = player['imageUrl'];

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
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          backgroundImage: imageUrl.startsWith('http')
                              ? NetworkImage(imageUrl)
                              : AssetImage(imageUrl) as ImageProvider,
                          radius: 24.0,
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
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    onTap: () {
                      _updateUserPoints(player['id'], 10);
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    )
        : const Center(child: Text('No leaderboard data available.'));
  }
}