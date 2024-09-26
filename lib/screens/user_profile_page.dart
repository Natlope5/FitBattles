import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfilePage extends StatelessWidget {
  final String userId; // User ID to fetch the profile

  const UserProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')), // App bar with title
      body: FutureBuilder<DocumentSnapshot>(
        // Fetch user data from Firestore
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          // Show loading indicator while data is being fetched
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle errors while fetching user data
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Check if user data exists
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User not found')); // Display message if user not found
          }

          // Fetch user data as a Map
          final userData = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0), // Padding around the content
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display user image or default avatar
                if (userData['image'] != null)
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(userData['image']),
                  )
                else
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey, // Default background color
                    child: Icon(Icons.person, size: 50), // Default icon for no image
                  ),
                const SizedBox(height: 16), // Space below the avatar
                Text(
                  userData['name'] ?? 'No Name', // Display user name
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8), // Space below the name
                Text('Email: ${userData['email'] ?? 'No Email'}'), // Display user email
                const SizedBox(height: 8), // Space below the email
                Text('Phone: ${userData['phone'] ?? 'No Phone'}'), // Display user phone number
                const SizedBox(height: 16), // Space before friends list section
                const Text(
                  'Friends List:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Friends list title
                ),
                const SizedBox(height: 8), // Space below friends list title
                // Display the friends list using a FutureBuilder
                Expanded(
                  child: FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .where(FieldPath.documentId, whereIn: userData['friends'] ?? []) // Fetch friends
                        .get(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> friendsSnapshot) {
                      // Show loading indicator while friends data is being fetched
                      if (friendsSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // Handle errors while fetching friends data
                      if (friendsSnapshot.hasError) {
                        return Center(child: Text('Error: ${friendsSnapshot.error}'));
                      }

                      // Check if friends data is empty
                      if (friendsSnapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No friends found')); // Message if no friends
                      }

                      // Display list of friends
                      return ListView.builder(
                        itemCount: friendsSnapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final friendData = friendsSnapshot.data!.docs[index].data() as Map<String, dynamic>; // Fetch friend data
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(friendData['image'] ?? 'https://via.placeholder.com/150'), // Display friend image or placeholder
                            ),
                            title: Text(friendData['name'] ?? 'No Name'), // Display friend name
                            subtitle: Text(friendData['email'] ?? 'No Email'), // Display friend email
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
