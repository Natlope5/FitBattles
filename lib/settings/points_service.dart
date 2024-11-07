import 'package:cloud_firestore/cloud_firestore.dart';

class PointsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream to get real-time user stats updates
  Stream<Map<String, dynamic>> getUserStatsStream(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) => snapshot.data() as Map<String, dynamic>);
  }

  // New method to calculate total points from workouts
  Future<int> calculateTotalPoints(String userId) async {
    int totalPoints = 0;

    final workoutsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .get();

    for (var doc in workoutsSnapshot.docs) {
      int points = (doc.data()['points'] ?? 0).toInt();
      totalPoints += points;
    }

    return totalPoints;
  }

  // Fetch points won for a user
  Future<int> getPointsWon(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      // Cast data to Map<String, dynamic>
      return (userDoc.data() as Map<String, dynamic>)['points'] ?? 0; // Default to 0 if no data
    } catch (e) {
      // Handle errors (you might want to log this or throw a specific exception)
      return 0;
    }
  }

  // Fetch user's statistics
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      // Cast data to Map<String, dynamic>
      final data = userDoc.data() as Map<String, dynamic>; // Cast the document data
      return {
        'totalChallengesCompleted': data["totalChallengesCompleted"] ?? 0,
        'pointsEarnedToday': data["pointsEarnedToday"] ?? 0,
        'bestDayPoints': data['bestDayPoints'] ?? 0,
        'streakDays': data['streakDays'] ?? 0,
      };
    } catch (e) {
      // Handle errors
      return {
        'totalChallengesCompleted': 0,
        'pointsEarnedToday': 0,
        'bestDayPoints': 0,
        'streakDays': 0,
      };
    }
  }
}
