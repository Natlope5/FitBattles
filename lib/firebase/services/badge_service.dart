import 'package:cloud_firestore/cloud_firestore.dart';
import '../../main.dart';

class BadgeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch user points from Firestore
  Future<int> fetchUserPoints(String userId) async {
    final docSnapshot = await _firestore.collection('users').doc(userId).get();
    if (docSnapshot.exists && docSnapshot.data() != null) {
      return (docSnapshot.data()!['points'] as num?)?.toInt() ?? 0;
    }
    return 0;
  }

  // Fetch user badges from Firestore
  Future<List<Map<String, String>>> fetchBadges(String userId) async {
    final docSnapshot = await _firestore.collection('users').doc(userId).get();
    if (docSnapshot.exists && docSnapshot.data() != null) {
      List<dynamic> badges = docSnapshot.data()!['badges'] ?? [];
      return badges.map((badge) => Map<String, String>.from(badge)).toList();
    }
    return [];
  }

  // Count completed challenges for a user
  Future<int> countCompletedChallenges(String userId) async {
    final querySnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('challenges')
        .where('challengeCompleted', isEqualTo: true)
        .get();
    return querySnapshot.docs.length;
  }

  // Award points and check for badge eligibility
  Future<void> awardPointsAndCheckBadges(String userId, int pointsToAdd, String taskType) async {
    final userRef = _firestore.collection('users').doc(userId);

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);
        if (snapshot.exists && snapshot.data() != null) {
          int currentPoints = (snapshot.data()!['points'] as num?)?.toInt() ?? 0;

          // Initialize badges as an empty array if it doesn't exist
          List<dynamic> currentBadges = snapshot.data()!['badges'] ?? [];
          if (currentBadges.isEmpty) {
            transaction.update(userRef, {'badges': []});
          }

          // Add points
          currentPoints += pointsToAdd;
          transaction.update(userRef, {'points': currentPoints});

          // Badge criteria with check function for completed challenges
          final badgeCriteria = {
            'challengeCompleted': {
              'threshold': 1,
              'badgeName': 'Challenge Master',
              'checkFunction': () => countCompletedChallenges(userId),
            },
          };

          // Check if badge criteria is met
          if (badgeCriteria.containsKey(taskType) &&
              !currentBadges.any((badge) => badge['name'] == badgeCriteria[taskType]!['badgeName'])) {
            final checkFunction = badgeCriteria[taskType]!['checkFunction'] as Future<int> Function()?;
            if (checkFunction != null) {
              final completedCount = await checkFunction();
              if (completedCount >= (badgeCriteria[taskType]!['threshold'] as int)) {
                // Add new badge to the badges array in Firebase
                final newBadge = {
                  'name': badgeCriteria[taskType]!['badgeName'] as String,
                  'date': DateTime.now().toIso8601String(),
                };
                currentBadges.add(newBadge);
                transaction.update(userRef, {'badges': currentBadges});
              }
            }
          }
        }
      });

      logger.i('Points awarded and badge check completed.');
    } catch (e) {
      logger.i('Error awarding points and checking badges: $e');
    }
  }
}