import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitbattles/services/firebase/badge_service.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:lottie/lottie.dart'; // Import for Lottie animations

class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  RewardsPageState createState() => RewardsPageState();
}

class RewardsPageState extends State<RewardsPage> with TickerProviderStateMixin {
  final BadgeService badgeService = BadgeService();
  late Future<int> userPoints;
  late Future<List<Map<String, String>>> badges;
  bool _isLoading = true;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadData();

    // Animation setup
    _fadeController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
  }

  // Load points and badges, and check for badge eligibility
  Future<void> _loadData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await badgeService.awardPointsAndCheckBadges(currentUser.uid, 0, 'challengeCompleted');
      setState(() {
        userPoints = badgeService.fetchUserPoints(currentUser.uid);
        badges = badgeService.fetchBadges(currentUser.uid);
      });
    } else {
      userPoints = Future.value(0);
      badges = Future.value([]);
    }
    setState(() {
      _isLoading = false;
    });
    _fadeController.forward(); // Start fade-in animation
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // Function to simulate the next badge milestone
  String _nextBadgeMilestone(int currentPoints) {
    int pointsNeeded = (currentPoints ~/ 100 + 1) * 100; // Round up to next multiple of 100
    return "You need ${pointsNeeded - currentPoints} more points for the next badge!";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Badges & Rewards', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF8A2BE2), // Modern purple color
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF85C83E)),
        ),
      )
          : FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00C9B9), Color(0xFF8A2BE2)], // Updated gradient colors
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Badges & Points',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              FutureBuilder<int>( // User points
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

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Points: $points',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center( // Centering the Lottie animation
                        child: Lottie.asset( // Add Lottie animation here
                          'assets/animations/reward_animation.json', // Path to your Lottie file
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _nextBadgeMilestone(points),
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                        ),
                      ),
                    ],
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

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 15,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          color: Colors.deepPurple,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16.0),
                            leading: const Icon(Icons.emoji_events, color: Colors.amber, size: 40),
                            title: Text(
                              badge['name'] ?? 'Unknown Badge',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              formattedDate,
                              style: const TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              // Animate badge on tap
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('You tapped on ${badge['name']}'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
