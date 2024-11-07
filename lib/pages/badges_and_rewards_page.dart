import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitbattles/settings/badge_service.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  RewardsPageState createState() => RewardsPageState();
}

class RewardsPageState extends State<RewardsPage> {
  final BadgeService badgeService = BadgeService();
  late Future<int> userPoints;
  late Future<List<Map<String, String>>> badges;

  @override
  void initState() {
    super.initState();
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      userPoints = badgeService.fetchUserPoints(currentUser.uid);
      badges = badgeService.fetchBadges(currentUser.uid);
    } else {
      userPoints = Future.value(0); // Handle the case where the user is not logged in
      badges = Future.value([]); // Handle the case where no badges are earned
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Badges & Rewards'),
        backgroundColor: const Color(0xFF5D6C8A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Badges & Points',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            FutureBuilder<int>(
              future: userPoints,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  return const Center(child: Text('No points available.'));
                }

                final points = snapshot.data ?? 0;
                return Text(
                  'Points: $points',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Map<String, String>>>(
                future: badges,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No badges earned.'));
                  }

                  final badges = snapshot.data ?? [];
                  return ListView.builder(
                    itemCount: badges.length,
                    itemBuilder: (context, index) {
                      final badge = badges[index];
                      return ListTile(
                        title: Text(badge['name'] ?? 'Unknown Badge'),
                        subtitle: Text(badge['dateEarned'] ?? 'Date N/A'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
