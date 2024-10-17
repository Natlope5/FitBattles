import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:fitbattles/settings/app_strings.dart'; // Import your strings file

class PrivacyModel {
  final String id;
  final Logger logger = Logger();

  PrivacyModel({required this.id}) {
    if (id.isEmpty) {
      throw ArgumentError(AppStrings.userIdEmptyError);
    }
  }

  Future<String> getPrivacySetting() async {
    try {
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(id).get();

      if (userDoc.exists) {
        return userDoc.data()?['privacy'] as String? ?? 'public';
      } else {
        return 'public';
      }
    } catch (e) {
      logger.e('${AppStrings.privacyFetchError} for user $id: $e');
      return 'public';
    }
  }

  Future<void> updatePrivacySetting(String privacySetting) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(id).update({
        'privacy': privacySetting,
      });
      logger.i('${AppStrings.privacySettingUpdated} to $privacySetting for user $id');
    } catch (e) {
      logger.e('Error updating privacy setting for user $id: $e');
    }
  }
}
