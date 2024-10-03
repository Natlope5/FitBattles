import 'package:cloud_firestore/cloud_firestore.dart';

class PrivacyModel {
  final String uid;

  PrivacyModel({required this.uid});

  // Fetch current privacy setting from Firestore
  Future<String> getPrivacySetting() async {
    var userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return userDoc['privacy'] ?? 'public'; // Return 'public' if no setting is found
  }

  // Update the user's privacy setting in Firestore
  Future<void> updatePrivacySetting(String privacySetting) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'privacy': privacySetting,
    });
  }
}
