import 'package:cloud_firestore/cloud_firestore.dart';

import '../main.dart';

class BadgeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch user points from Firestore
  Future<int> fetchUserPoints(String userId) async {
    final docSnapshot = await _firestore.collection('users').doc(userId).get();
    if (docSnapshot.exists && docSnapshot.data() != null) {
      // Ensure the 'points' field is a number and handle type safety
      return (docSnapshot.data()!['points'] as num?)?.toInt() ?? 0;
    }
    return 0;
  }

  // Fetch user badges from Firestore
  Future<List<Map<String, String>>> fetchBadges(String userId) async {
    final docSnapshot = await _firestore.collection('users').doc(userId).get();
    if (docSnapshot.exists && docSnapshot.data() != null) {
      List<dynamic> badges = docSnapshot.data()!['badges'] ?? [];
      // Ensure badges list contains only maps and handle type casting safely
      return badges.map((badge) => Map<String, String>.from(badge)).toList();
    }
    return [];
  }

  // Award points and check for badge eligibility
  Future<void> awardPointsAndCheckBadges(String userId, int pointsToAdd, String taskType) async {
    final userRef = _firestore.collection('users').doc(userId);

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);
        if (snapshot.exists && snapshot.data() != null) {
          int currentPoints = (snapshot.data()!['points'] as num?)?.toInt() ?? 0;
          List<dynamic> currentBadges = snapshot.data()!['badges'] ?? [];

          // Add points
          currentPoints += pointsToAdd;
          transaction.update(userRef, {'points': currentPoints});

          // Badge criteria
          final badgeCriteria = {
            'challengeCompleted': {'threshold': 50, 'badgeName': 'Challenge Master'},
            'communityChallengeCompleted': {'threshold': 100, 'badgeName': 'Community Hero'},
            'goalAchieved': {'threshold': 200, 'badgeName': 'Goal Achiever'}
          };

          // Check for badge eligibility safely
          if (badgeCriteria[taskType] != null &&
              !currentBadges.any((badge) => badge['name'] == badgeCriteria[taskType]!['badgeName']) &&
              currentPoints >= (badgeCriteria[taskType]!['threshold'] as int)) {
            currentBadges.add({
              'name': badgeCriteria[taskType]!['badgeName'] as String,
              'date': DateTime.now().toIso8601String(),
            });
            transaction.update(userRef, {'badges': currentBadges});
          }
        }
      });

      // Print logs for debugging purposes; use proper logging in production
      logger.i('Points awarded and badge check completed.');
    } catch (e) {
      // Print logs for debugging purposes; use proper logging in production
      logger.i('Error awarding points and checking badges: $e');
    }
  }
}
