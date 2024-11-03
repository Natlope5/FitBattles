import 'package:cloud_firestore/cloud_firestore.dart';

class BadgeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> checkAndAwardBadges(String userId) async {
    final userStats = await _firestore.collection('userStats').doc(userId).get();
    final completedChallenges = userStats.data()?['completedChallenges'] ?? 0;
    final workoutDays = userStats.data()?['workoutDays'] ?? 0;
    final stepsCount = userStats.data()?['dailySteps'] ?? 0;
    final nutritionTracked = userStats.data()?['nutritionTrackedDays'] ?? 0;
    final strengthMilestone = userStats.data()?['strengthMilestone'] ?? 0;
    final friendsReferred = userStats.data()?['friendsReferred'] ?? 0;

    // Award badges based on user statistics
    if (completedChallenges >= 1) {
      await _awardBadge(userId, "Core Crusher");
    }
    if (workoutDays >= 12) {
      await _awardBadge(userId, "Consistent Trainer");
    }
    if (userStats.data()?['goalsAchieved'] ?? false) {
      await _awardBadge(userId, "Goal Setter");
    }
    if (userStats.data()?['healthyHabitDays'] >= 30) {
      await _awardBadge(userId, "Healthy Habit Builder");
    }
    if (userStats.data()?['communityWorkoutLed'] ?? false) {
      await _awardBadge(userId, "Community Leader");
    }
    if (nutritionTracked >= 30) {
      await _awardBadge(userId, "Nutrition Enthusiast");
    }
    if (stepsCount >= 10000) {
      await _awardBadge(userId, "10K Steps a Day");
    }
    if (completedChallenges >= 7) {
      await _awardBadge(userId, "Cardio King/Queen");
    }
    if (strengthMilestone >= 100) {
      await _awardBadge(userId, "Strength Specialist");
    }
    if (friendsReferred >= 1) {
      await _awardBadge(userId, "Fit Friend");
    }
  }

  Future<void> _awardBadge(String userId, String badgeName) async {
    final badgesRef = _firestore.collection('users').doc(userId).collection('badges');
    final badgeDoc = await badgesRef.doc(badgeName).get();

    if (!badgeDoc.exists) {
      await badgesRef.doc(badgeName).set({
        'name': badgeName,
        'earnedDate': Timestamp.now(),
      });
    }
  }

  Future<List<Map<String, String>>> fetchBadges(String userId) async {
    final badgesRef = _firestore.collection('users').doc(userId).collection('badges');
    final querySnapshot = await badgesRef.get();

    return querySnapshot.docs.map((doc) {
      return {
        'name': doc['name'] as String, // Ensure this is a string
        'earnedDate': (doc['earnedDate'] as Timestamp).toDate().toString(), // Convert to string
      };
    }).toList();
  }
}
