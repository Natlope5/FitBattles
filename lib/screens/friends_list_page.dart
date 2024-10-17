import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitbattles/screens/user_profile_page.dart';

class FriendsListPage extends StatefulWidget {
  const FriendsListPage({super.key});

  @override
  FriendsListPageState createState() => FriendsListPageState();
}

class FriendsListPageState extends State<FriendsListPage> {
  // Controller for the search text field
  final TextEditingController _searchController = TextEditingController();
  // Firestore instance to interact with the database
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lists to hold friends and suggested friends data
  List<Map<String, dynamic>> friendsList = [];
  List<Map<String, dynamic>> suggestedFriendsList = [];

  // Placeholder for the current user ID (to be replaced with actual user ID)
  String userId = 'currentUserId'; // Replace with actual user ID

  @override
  void initState() {
    super.initState();
    // Fetch the list of friends when the page is initialized
    _fetchFriends();
  }

  // Function to fetch friends from Firestore
  Future<void> _fetchFriends() async {
    // Clear the existing friends list before fetching
    friendsList.clear();

    // Fetch currently added friends from Firestore
    DocumentSnapshot userFriendsDoc = await _firestore.collection('users').doc(userId).get();
    if (userFriendsDoc.exists) {
      // Get the list of friend IDs from the user document
      List<dynamic> friends = userFriendsDoc['friends'];
      // Fetch user details for each friend
      for (String friendId in friends) {
        DocumentSnapshot friendDoc = await _firestore.collection('users').doc(friendId).get();
        if (friendDoc.exists) {
          // Add friend details to the friendsList
          friendsList.add({
            'id': friendId,
            'name': friendDoc['name'],
            'image': friendDoc['image'], // Assuming you have an image field
          });
        }
      }
      // Update the UI after fetching friends
      setState(() {});
    }
  }

  // Function to search for friends based on the query
  Future<void> _searchFriends(String query) async {
    if (query.isEmpty) {
      // Clear suggested friends if the search query is empty
      setState(() {
        suggestedFriendsList.clear();
      });
      return;
    }

    // Search for friends by phone number
    QuerySnapshot searchResults = await _firestore
        .collection('users')
        .where('phone', isEqualTo: query)
        .get();

    // If no results, search by email
    if (searchResults.docs.isEmpty) {
      searchResults = await _firestore
          .collection('users')
          .where('email', isEqualTo: query)
          .get();
    }

    // If still no results, search by user ID
    if (searchResults.docs.isEmpty) {
      searchResults = await _firestore
          .collection('users')
          .where('userId', isEqualTo: query)
          .get();
    }

    // Build a list of suggested friends from the search results
    suggestedFriendsList = searchResults.docs.map((doc) {
      return {
        'id': doc.id,
        'name': doc['name'],
        'image': doc['image'], // Assuming you have an image field
      };
    }).toList();

    // Update the UI after searching for friends
    setState(() {});
  }

  // Function to add a friend
  Future<void> _addFriend(String friendId) async {
    // Check if the friend is already added
    bool isFriendAlreadyAdded = friendsList.any((friend) => friend['id'] == friendId);

    if (!isFriendAlreadyAdded) {
      // If not added, update the user's friend list in Firestore
      await _firestore.collection('users').doc(userId).update({
        'friends': FieldValue.arrayUnion([friendId]),
      });
      _showSnackBar('Friend added successfully!'); // Show success message
      await _fetchFriends(); // Refresh friends list
    } else {
      _showSnackBar('Friend already added!'); // Show already added message
    }
  }

  // Function to show a SnackBar with a message
  void _showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Function to navigate to the user's profile page
  void _viewProfile(String friendId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserProfilePage(userId: friendId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Friends')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // TextField for searching friends
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Phone, Email, or User ID',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _searchFriends(_searchController.text),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Display section title for added friends
            const Text(
              'Added Friends',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: friendsList.length,
                itemBuilder: (context, index) {
                  final friend = friendsList[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(friend['image'] ?? ''), // Use NetworkImage for online images
                    ),
                    title: Text(friend['name']),
                    onTap: () => _viewProfile(friend['id']),
                  );
                },
              ),
            ),
            // Display section title for suggested friends
            const SizedBox(height: 16),
            const Text(
              'Suggested Friends',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: suggestedFriendsList.length,
                itemBuilder: (context, index) {
                  final friend = suggestedFriendsList[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(friend['image'] ?? ''), // Use NetworkImage for online images
                    ),
                    title: Text(friend['name']),
                    trailing: ElevatedButton(
                      onPressed: () => _addFriend(friend['id']),
                      child: const Text('Add Friend'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

