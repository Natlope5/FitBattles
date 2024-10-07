import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfilePage extends StatefulWidget {
  final String id;

  const UserProfilePage({super.key, required this.id});

  @override
  UserProfilePageState createState() => UserProfilePageState();
}

class UserProfilePageState extends State<UserProfilePage> {
  late String name = 'Loading...'; // Default loading text
  late String imageUrl = ''; // Default value
  late String privacySetting = 'Loading...'; // Default loading text
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
          name = userDoc['name'] ?? 'No Name'; // Default value if name not found
          imageUrl = userDoc['image'] ?? ''; // Default value if image not found
          privacySetting = userDoc['privacy'] ?? 'public'; // Default privacy setting
          isLoading = false; // Stop loading
        });
      } else {
        _showErrorDialog('User profile not found.');
      }
    } catch (e) {
      _showErrorDialog('Failed to fetch user profile: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
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
        title: const Text('User Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator()) // Show loading indicator
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl.isNotEmpty) ...[
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(imageUrl),
              ),
              const SizedBox(height: 10),
            ],
            Text('Name: $name', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text('Privacy Setting: $privacySetting', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to privacy settings or any other page if needed
                Navigator.pushNamed(context, '/privacySettings', arguments: widget.id);
              },
              child: const Text('Edit Privacy Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
