import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitbattles/services/firebase/badge_service.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  RewardsPageState createState() => RewardsPageState();
}

class RewardsPageState extends State<RewardsPage> {
  final BadgeService badgeService = BadgeService();
  late Future<int> userPoints;
  late Future<List<Map<String, String>>> badges;
  bool _isLoading = true; // Add a loading state

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Load points and badges, and check for badge eligibility
  Future<void> _loadData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await badgeService.awardPointsAndCheckBadges(currentUser.uid, 0, 'challengeCompleted'); // Check for badge eligibility
      setState(() {
        userPoints = badgeService.fetchUserPoints(currentUser.uid);
        badges = badgeService.fetchBadges(currentUser.uid);
      });
    } else {
      userPoints = Future.value(0);
      badges = Future.value([]);
    }
    setState(() {
      _isLoading = false; // Set loading to false once data is fetched
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Badges & Rewards'),
        backgroundColor: const Color(0xFF5D6C8A),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading spinner while loading
          : Padding(
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

                  final badgeList = snapshot.data ?? [];
                  return ListView.builder(
                    itemCount: badgeList.length,
                    itemBuilder: (context, index) {
                      final badge = badgeList[index];
                      final formattedDate = DateFormat('dd MMM yyyy').format(DateTime.parse(badge['date'] ?? ''));

                      return ListTile(
                        leading: const Icon(Icons.emoji_events, color: Colors.amber), // Badge icon
                        title: Text(badge['name'] ?? 'Unknown Badge'),
                        subtitle: Text(formattedDate), // Formatted date
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