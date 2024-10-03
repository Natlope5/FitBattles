import 'package:fitbattles/screens/user_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendsListPage extends StatefulWidget {
  const FriendsListPage({super.key});

  @override
  FriendsListPageState createState() => FriendsListPageState();
}

class FriendsListPageState extends State<FriendsListPage> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> friendsList = [];
  List<Map<String, dynamic>> suggestedFriendsList = [];

  String userId = 'currentUserId'; // Placeholder for the current user ID (replace with actual user ID)

  @override
  void initState() {
    super.initState();
    _fetchFriends();
  }

  Future<void> _fetchFriends() async {
    friendsList.clear();

    // Fetch friends from Firestore
    DocumentSnapshot userFriendsDoc = await _firestore.collection('users').doc(userId).get();
    if (userFriendsDoc.exists) {
      List<dynamic> friends = userFriendsDoc['friends'];
      for (String friendId in friends) {
        DocumentSnapshot friendDoc = await _firestore.collection('users').doc(friendId).get();
        if (friendDoc.exists) {
          friendsList.add({
            'id': friendId,
            'name': friendDoc['name'],
            'image': friendDoc['image'],
          });
        }
      }
      setState(() {});
    }
  }

  Future<void> _searchFriends(String query) async {
    if (query.isEmpty) {
      suggestedFriendsList.clear();
      setState(() {});
      return;
    }

    QuerySnapshot searchResults = await _firestore
        .collection('users')
        .where('phone', isEqualTo: query)
        .get();

    if (searchResults.docs.isEmpty) {
      searchResults = await _firestore
          .collection('users')
          .where('email', isEqualTo: query)
          .get();
    }

    if (searchResults.docs.isEmpty) {
      searchResults = await _firestore
          .collection('users')
          .where('userId', isEqualTo: query)
          .get();
    }

    suggestedFriendsList = searchResults.docs.map((doc) {
      return {
        'id': doc.id,
        'name': doc['name'],
        'image': doc['image'],
      };
    }).toList();

    setState(() {});
  }

  Future<void> _addFriend(String friendId) async {
    bool isFriendAlreadyAdded = friendsList.any((friend) => friend['id'] == friendId);

    if (!isFriendAlreadyAdded) {
      await _firestore.collection('users').doc(userId).update({
        'friends': FieldValue.arrayUnion([friendId]),
      });
      _showSnackBar('Friend added successfully!');
      await _fetchFriends();
    } else {
      _showSnackBar('Friend already added!');
    }
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

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
                      backgroundImage: NetworkImage(friend['image'] ?? ''),
                    ),
                    title: Text(friend['name']),
                    onTap: () => _viewProfile(friend['id']),
                  );
                },
              ),
            ),
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
                      backgroundImage: NetworkImage(friend['image'] ?? ''),
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
