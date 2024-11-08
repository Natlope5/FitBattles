import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitbattles/models/earned_points_model.dart';  // Ensure the correct import

Future<EarnedPointsStats> fetchEarnedPointsStats(String userId) async {
  try {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('points')
        .doc('stats')
        .get();

    if (docSnapshot.exists) {
      return EarnedPointsStats.fromMap(docSnapshot.data()!); // Convert Firestore data to model
    } else {
      throw Exception("No stats available.");
    }
  } catch (e) {
    throw Exception("Failed to load stats: $e");
  }
}
