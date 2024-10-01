import 'package:flutter/material.dart'; // Importing Flutter Material for UI components
import 'package:cloud_firestore/cloud_firestore.dart'; // Importing Firestore for database interaction
import 'package:fitbattles/screens/user_profile_page.dart'; // Importing user profile page

class FriendsListPage extends StatefulWidget {
  const FriendsListPage({super.key}); // Constructor for the FriendsListPage

  @override
  FriendsListPageState createState() => FriendsListPageState(); // Creating state for the widget
}

class FriendsListPageState extends State<FriendsListPage> {
  final TextEditingController _searchController = TextEditingController(); // Controller for the search text field
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance to interact with the database

  List<Map<String, dynamic>> friendsList = []; // List to hold friends data
  List<Map<String, dynamic>> suggestedFriendsList = []; // List for suggested friends

  String userId = 'currentUserId'; // Placeholder for the current user ID (to be replaced with actual user ID)

  @override
  void initState() {
    super.initState();
    _fetchFriends(); // Fetch the list of friends when the page is initialized
  }

  // Function to fetch friends from Firestore
  Future<void> _fetchFriends() async {
    friendsList.clear(); // Clear the existing friends list before fetching

    // Fetch currently added friends from Firestore
    DocumentSnapshot userFriendsDoc = await _firestore.collection('users').doc(userId).get();
    if (userFriendsDoc.exists) {
      List<dynamic> friends = userFriendsDoc['friends']; // Get the list of friend IDs
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
      setState(() {}); // Update the UI after fetching friends
    }
  }

  // Function to search for friends based on the query
  Future<void> _searchFriends(String query) async {
    if (query.isEmpty) {
      suggestedFriendsList.clear(); // Clear suggested friends if the search query is empty
      setState(() {}); // Update the UI
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

    setState(() {}); // Update the UI after searching for friends
  }

  // Function to add a friend
  Future<void> _addFriend(String friendId) async {
    bool isFriendAlreadyAdded = friendsList.any((friend) => friend['id'] == friendId); // Check if the friend is already added

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
    final snackBar = SnackBar(content: Text(message)); // Create a SnackBar with the message
    ScaffoldMessenger.of(context).showSnackBar(snackBar); // Show the SnackBar
  }

  // Function to navigate to the user's profile page
  void _viewProfile(String friendId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserProfilePage(userId: friendId)), // Navigate to user profile
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Friends')), // AppBar title
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding for the body
        child: Column(
          children: [
            // TextField for searching friends
            TextField(
              controller: _searchController, // Controller for the text field
              decoration: InputDecoration(
                labelText: 'Search by Phone, Email, or User ID', // Label for the text field
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search), // Search icon
                  onPressed: () => _searchFriends(_searchController.text), // Search action
                ),
              ),
            ),
            const SizedBox(height: 16), // Space between text field and friend list
            const Text(
              'Added Friends',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Title style
            ),
            Expanded(
              child: ListView.builder(
                itemCount: friendsList.length, // Number of friends to display
                itemBuilder: (context, index) {
                  final friend = friendsList[index]; // Get friend details
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(friend['image'] ?? ''), // Use NetworkImage for friend's image
                    ),
                    title: Text(friend['name']), // Friend's name
                    onTap: () => _viewProfile(friend['id']), // Navigate to profile on tap
                  );
                },
              ),
            ),
            const SizedBox(height: 16), // Space between added friends and suggested friends section
            const Text(
              'Suggested Friends',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Title style for suggested friends
            ),
            Expanded(
              child: ListView.builder(
                itemCount: suggestedFriendsList.length, // Number of suggested friends to display
                itemBuilder: (context, index) {
                  final friend = suggestedFriendsList[index]; // Get suggested friend details
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(friend['image'] ?? ''), // Use NetworkImage for friend's image
                    ),
                    title: Text(friend['name']), // Suggested friend's name
                    trailing: ElevatedButton(
                      onPressed: () => _addFriend(friend['id']), // Add friend on button press
                      child: const Text('Add Friend'), // Button label
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
