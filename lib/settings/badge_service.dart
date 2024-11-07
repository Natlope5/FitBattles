import 'package:cloud_firestore/cloud_firestore.dart';

class BadgeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch badges from Firestore
  Future<List<Map<String, String>>> fetchBadges(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('badges')
          .where('userId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isEmpty) {
        return [];
      }

      return snapshot.docs.map((doc) {
        final badgeData = doc.data();
        return {
          'name': badgeData['name']?.toString() ?? 'Unnamed Badge',
          'dateEarned': (badgeData['dateEarned'] as Timestamp?)?.toDate().toString() ?? 'N/A',
        };
      }).toList();
    } catch (e) {
      throw Exception('Error fetching badges: $e');
    }
  }

  // Fetch current points from Firestore
  // Fetch current points from Firestore
  Future<int> fetchUserPoints(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      // Make sure the document exists and has data before attempting to access the points field
      if (doc.exists && doc.data() != null) {
        final points = doc.data()?['points'];
        if (points is double) {
          return points.toInt(); // Convert double to int
        }
        return points ?? 0; // In case points is an int, just return it
      } else {
        return 0; // Return 0 if no data is found for the user
      }
    } catch (e) {
      throw Exception('Error fetching user points: $e');
    }
  }


  // Update points in Firestore
  Future<void> updatePoints(String userId, int points) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      await userRef.update({'points': points});
    } catch (e) {
      throw Exception('Error updating points: $e');
    }
  }

  // Earn a badge (this can still be used as part of earning criteria)
  Future<void> earnBadge(String userId, String badgeName) async {
    try {
      final badgeRef = _firestore.collection('badges').doc(); // New document for a new badge
      final currentDate = Timestamp.now(); // Current date/time to store when the badge is earned

      await badgeRef.set({
        'userId': userId,
        'name': badgeName,
        'dateEarned': currentDate,
      });
    } catch (e) {
      throw Exception('Error saving badge: $e');
    }
  }

  // Logic to handle points for burning calories
  Future<void> awardPointsForCaloriesBurned(String userId, int caloriesBurned) async {
    // Example: Earn 1 point for every 100 calories burned
    final pointsEarned = caloriesBurned ~/ 100;
    if (pointsEarned > 0) {
      final currentPoints = await fetchUserPoints(userId);
      final newTotalPoints = currentPoints + pointsEarned;
      await updatePoints(userId, newTotalPoints);
    }
  }

  // Logic to handle points for winning challenges
  Future<void> awardPointsForChallengeWin(String userId, String challengeName) async {
    // Example: Earn 50 points for winning a challenge
    final pointsEarned = 50; // Fixed points for winning a challenge
    final currentPoints = await fetchUserPoints(userId);
    final newTotalPoints = currentPoints + pointsEarned;
    await updatePoints(userId, newTotalPoints);

    // Optionally, you could also earn a badge for winning a challenge:
    await earnBadge(userId, 'Challenge Winner: $challengeName');
  }
}
