import 'package:cloud_firestore/cloud_firestore.dart';

class ChallengeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Future<void> updateUserChallengeProgress(int userProgress) async {
    String userId = "your_user_id"; // Replace with logic to get the user's ID
    try {
      await _firestore.collection('users').doc(userId).update({
        'challengeProgress': userProgress,
      });
    } catch (e) {
      print('Error updating user challenge progress: $e');
    }
  }
}