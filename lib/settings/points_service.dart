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

    final workoutsSnapshot = await _firestore
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

  // Calculate points earned today
  Future<int> calculatePointsEarnedToday(String userId) async {
    int pointsToday = 0;
    DateTime now = DateTime.now();

    final workoutsSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .get();

    for (var doc in workoutsSnapshot.docs) {
      DateTime workoutDate = (doc.data()['timestamp'] as Timestamp).toDate();
      if (workoutDate.year == now.year &&
          workoutDate.month == now.month &&
          workoutDate.day == now.day) {
        int points = (doc.data()['points'] ?? 0).toInt();
        pointsToday += points;
      }
    }

    return pointsToday;
  }

  // Calculate best day points
  Future<int> calculateBestDayPoints(String userId) async {
    Map<String, int> pointsByDay = {};

    final workoutsSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .get();

    for (var doc in workoutsSnapshot.docs) {
      DateTime workoutDate = (doc.data()['timestamp'] as Timestamp).toDate();
      String dayKey = "${workoutDate.year}-${workoutDate.month}-${workoutDate.day}";

      int points = (doc.data()['points'] ?? 0).toInt();
      pointsByDay[dayKey] = (pointsByDay[dayKey] ?? 0) + points;
    }

    int bestDayPoints = pointsByDay.values.fold(0, (max, points) => points > max ? points : max);

    return bestDayPoints;
  }

  // Calculate streak days
  Future<int> calculateStreakDays(String userId) async {
    List<DateTime> workoutDates = [];

    final workoutsSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .orderBy('timestamp', descending: true)
        .get();

    for (var doc in workoutsSnapshot.docs) {
      DateTime workoutDate = (doc.data()['timestamp'] as Timestamp).toDate();
      workoutDates.add(workoutDate);
    }

    int streakDays = 0;
    DateTime? previousDate;

    for (var date in workoutDates) {
      if (previousDate == null) {
        streakDays = 1;
      } else {
        // Check if the date is exactly one day before the previous date
        if (previousDate.difference(date).inDays == 1) {
          streakDays += 1;
        } else {
          break; // Streak is broken
        }
      }
      previousDate = date;
    }

    return streakDays;
  }

  // Fetch user's statistics
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      int pointsEarnedToday = await calculatePointsEarnedToday(userId);
      int bestDayPoints = await calculateBestDayPoints(userId);
      int streakDays = await calculateStreakDays(userId);

      return {
        'totalChallengesCompleted': 0, // Placeholder, adjust as needed
        'pointsEarnedToday': pointsEarnedToday,
        'bestDayPoints': bestDayPoints,
        'streakDays': streakDays,
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