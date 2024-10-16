import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'logger.dart'; // Assuming you have a logger in place for error tracking

class UserDataRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Helper function to fetch the user document
  Future<Map<String, dynamic>?> _getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          return userDoc.data() as Map<String, dynamic>;
        }
      } catch (e) {
        logger.e('Error fetching user data: $e');
      }
    }
    return null;
  }

  // Fetch Points Won
  Future<int> getPointsWon() async {
    Map<String, dynamic>? userData = await _getUserData();
    if (userData != null) {
      return userData['history']?['pointsWon'] ?? 0;
    }
    return 0; // Default value if user is not authenticated or data fetch fails
  }

  // Fetch Calories Lost
  Future<int> getCaloriesLost() async {
    Map<String, dynamic>? userData = await _getUserData();
    if (userData != null) {
      return userData['history']?['caloriesLost'] ?? 0;
    }
    return 0;
  }

  // Fetch Water Intake
  Future<double> getWaterIntake() async {
    Map<String, dynamic>? userData = await _getUserData();
    if (userData != null) {
      return (userData['history']?['waterIntake'] as num?)?.toDouble() ?? 0.0;
    }
    return 0.0;
  }

  // Fetch Workout Sessions
  Future<int> getWorkoutSessions() async {
    Map<String, dynamic>? userData = await _getUserData();
    if (userData != null) {
      return userData['history']?['workoutSessions'] ?? 0;
    }
    return 0;
  }

  // Fetch Challenges Won
  Future<int> getChallengesWon() async {
    Map<String, dynamic>? userData = await _getUserData();
    if (userData != null) {
      return userData['history']?['challengesWon'] ?? 0;
    }
    return 0;
  }

  // Fetch Challenges Lost
  Future<int> getChallengesLost() async {
    Map<String, dynamic>? userData = await _getUserData();
    if (userData != null) {
      return userData['history']?['challengesLost'] ?? 0;
    }
    return 0;
  }

  // Fetch Challenges Tied
  Future<int> getChallengesTied() async {
    Map<String, dynamic>? userData = await _getUserData();
    if (userData != null) {
      return userData['history']?['challengesTied'] ?? 0;
    }
    return 0;
  }

  // Fetch Friends Involved
  Future<List<String>> getFriendsInvolved() async {
    Map<String, dynamic>? userData = await _getUserData();
    if (userData != null) {
      return List<String>.from(userData['history']?['friendsInvolved'] ?? []);
    }
    return [];
  }
}
