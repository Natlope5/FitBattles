import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../settings/app_dimens.dart';
import '../settings/app_strings.dart';

class UserProfilePage extends StatefulWidget {
  final String id;

  const UserProfilePage({super.key, required this.id});

  @override
  UserProfilePageState createState() => UserProfilePageState();
}

class UserProfilePageState extends State<UserProfilePage> {
  late String name = AppStrings.loading; // Default loading text
  late String imageUrl = ''; // Default value
  late String privacySetting = AppStrings.loading; // Default loading text
  bool isLoading = true; // State to manage loading status

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.id)
          .get();
      if (userDoc.exists) {
        setState(() {
          name = userDoc['name'] ?? AppStrings.noName; // Default value if name not found
          imageUrl = userDoc['image'] ?? ''; // Default value if image not found
          privacySetting = userDoc['privacy'] ?? AppStrings.defaultPrivacy; // Default privacy setting
          isLoading = false; // Stop loading
        });
      } else {
        _showErrorDialog(AppStrings.userProfileNotFound);
      }
    } catch (e) {
      _showErrorDialog('${AppStrings.failedToFetchProfile}: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(AppStrings.error),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(AppStrings.ok),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.userProfile),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimens.padding),
        child: isLoading
            ? const Center(child: CircularProgressIndicator()) // Show loading indicator
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl.isNotEmpty) ...[
              CircleAvatar(
                radius: AppDimens.avatarRadius,
                backgroundImage: NetworkImage(imageUrl),
              ),
              const SizedBox(height: AppDimens.spaceBetweenEntries),
            ],
            Text('${AppStrings.name}: $name', style: const TextStyle(fontSize: AppDimens.nameFontSize)),
            const SizedBox(height: AppDimens.spaceBetweenEntries),
            Text('${AppStrings.privacySetting}: $privacySetting', style: const TextStyle(fontSize: AppDimens.privacyFontSize)),
            const SizedBox(height: AppDimens.spaceBetweenEntries),
            ElevatedButton(
              onPressed: () {
                // Navigate to privacy settings or any other page if needed
                Navigator.pushNamed(context, '/privacySettings', arguments: widget.id);
              },
              child: const Text(AppStrings.editPrivacySettings),
            ),
          ],
        ),
      ),
    );
  }
}
