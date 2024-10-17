import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../settings/app_strings.dart';
import '../settings/app_dimens.dart';

class ViewUserProfile extends StatelessWidget {
  final String currentUid;
  final String targetUid;

  const ViewUserProfile({super.key, required this.currentUid, required this.targetUid});

  Future<Map<String, dynamic>> getUserData() async {
    // Fetch the user's document from Firestore
    var userDoc = await FirebaseFirestore.instance.collection('users').doc(targetUid).get();

    // Check if the user document exists
    if (!userDoc.exists) {
      throw Exception(AppStrings.userDoesNotExist);
    }

    String privacy = userDoc['privacy'] ?? 'public';

    // Handle privacy settings
    if (privacy == 'public') {
      return userDoc.data() as Map<String, dynamic>; // Show public data
    } else if (privacy == 'friends') {
      // Check if current user is a friend
      var friendDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUid)
          .collection('friends')
          .doc(targetUid)
          .get();

      if (friendDoc.exists) {
        return userDoc.data() as Map<String, dynamic>; // Show data if friends
      } else {
        throw Exception(AppStrings.notAllowedToView);
      }
    } else if (privacy == 'private') {
      // Only the user themselves can view private data
      if (currentUid == targetUid) {
        return userDoc.data() as Map<String, dynamic>;
      } else {
        throw Exception(AppStrings.profileIsPrivate);
      }
    } else {
      throw Exception(AppStrings.invalidPrivacySetting);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          var userData = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Text('${userData['name'] ?? AppStrings.noName} ${AppStrings.userProfile}'), // Use user name or fallback
            ),
            body: Padding(
              padding: const EdgeInsets.all(AppDimens.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display user image if available
                  if (userData['image'] != null && userData['image'] != '')
                    CircleAvatar(
                      radius: AppDimens.avatarRadius,
                      backgroundImage: NetworkImage(userData['image']),
                    ),
                  const SizedBox(height: AppDimens.spaceBetweenEntries),
                  // Display user name
                  Text('Name: ${userData['name'] ?? AppStrings.noName}', style: TextStyle(fontSize: AppDimens.nameFontSize)),
                  const SizedBox(height: AppDimens.spaceBetweenEntries),
                  // Display user email
                  Text('Email: ${userData['email'] ?? AppStrings.noEmail}', style: TextStyle(fontSize: AppDimens.emailFontSize)),
                  const SizedBox(height: AppDimens.spaceBetweenEntries),
                  // Display privacy setting
                  Text('Privacy Setting: ${userData['privacy'] ?? 'public'}', style: TextStyle(fontSize: AppDimens.privacyFontSize)),
                ],
              ),
            ),
          );
        } else {
          return const Center(child: Text('No data found.'));
        }
      },
    );
  }
}
