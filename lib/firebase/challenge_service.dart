import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChallengeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch the current weekly challenge
  Future<Map<String, dynamic>?> getCurrentWeeklyChallenge() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('weekly_challenges')
          .where('isCurrent', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data() as Map<String, dynamic>;
      } else {
        return null; // No current challenge found
      }
    } catch (e) {
      print('Error fetching current weekly challenge: $e');
      return null;
    }
  }

  // Retrieve user progress for the current challenge
  Future<int> getUserChallengeProgress() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists && userDoc.data() != null) {
        return (userDoc.data() as Map<String, dynamic>)['challengeProgress'] ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      print('Error fetching user challenge progress: $e');
      return 0;
    }
  }

  // Update user progress for the current challenge
  Future<void> updateUserChallengeProgress(int userProgress) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      await _firestore.collection('users').doc(userId).update({
        'challengeProgress': userProgress,
      });
    } catch (e) {
      print('Error updating user challenge progress: $e');
    }
  }
}