import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart'; // Import logger for logging errors

class PrivacyModel {
  final String id;
  final Logger logger = Logger(); // Initialize the logger instance

  PrivacyModel({required this.id}) {
    if (id.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }
  }

  // Fetch current privacy setting from Firestore
  Future<String> getPrivacySetting() async {
    try {
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(id).get();

      if (userDoc.exists) {
        return userDoc.data()?['privacy'] as String? ?? 'public'; // Return 'public' if no setting is found
      } else {
        return 'public'; // Return 'public' if the document does not exist
      }
    } catch (e) {
      // Handle any errors that occur during the fetch
      logger.e('Error fetching privacy setting for user $id: $e');
      return 'public'; // Return default value on error
    }
  }

  // Update the user's privacy setting in Firestore
  Future<void> updatePrivacySetting(String privacySetting) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(id).update({
        'privacy': privacySetting,
      });
      logger.i('Privacy setting updated to $privacySetting for user $id');
    } catch (e) {
      // Handle any errors that occur during the update
      logger.e('Error updating privacy setting for user $id: $e');
    }
  }
}
