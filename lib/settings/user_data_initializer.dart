import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'logger.dart'; // Assuming you're using a logger to track errors

// Function to create a new user document with the correct structure in Firestore
Future<void> createUserDocument(User user) async {
  try {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'history': {
        'pointsWon': 0,
        'caloriesLost': 0,
        'waterIntake': 0.0,
        'workoutSessions': 0,
        'challengesWon': 0,
        'challengesLost': 0,
        'challengesTied': 0,
        'friendsInvolved': []
      }
    });
    logger.i('User document created successfully');
  } catch (e) {
    logger.e('Error creating user document: $e');
  }
}

// Function to update existing user data if the 'history' field is missing or incomplete
Future<void> updateExistingUserData() async {
  WriteBatch batch = FirebaseFirestore.instance.batch();

  try {
    // Get all users from the 'users' collection
    QuerySnapshot usersSnapshot = await FirebaseFirestore.instance.collection('users').get();

    for (QueryDocumentSnapshot userDoc in usersSnapshot.docs) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      // Ensure 'history' field exists, or create default structure if missing
      Map<String, dynamic> history = userData['history'] ?? {};

      history.putIfAbsent('pointsWon', () => 0);
      history.putIfAbsent('caloriesLost', () => 0);
      history.putIfAbsent('waterIntake', () => 0.0);
      history.putIfAbsent('workoutSessions', () => 0);
      history.putIfAbsent('challengesWon', () => 0);
      history.putIfAbsent('challengesLost', () => 0);
      history.putIfAbsent('challengesTied', () => 0);
      history.putIfAbsent('friendsInvolved', () => []);

      // Update the user's document with the correct history structure
      batch.update(userDoc.reference, {'history': history});
    }

    // Commit the batch update
    await batch.commit();
    logger.i('Successfully updated user data.');
  } catch (e) {
    logger.e('Error updating user data: $e');
  }
}
