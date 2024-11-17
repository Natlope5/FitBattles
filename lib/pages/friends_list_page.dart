import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitbattles/settings/ui/app_colors.dart';
import 'package:fitbattles/settings/ui/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:fitbattles/settings/ui/app_strings.dart';
import 'dart:math';

class FriendsListPage extends StatefulWidget {
  const FriendsListPage({super.key});

  @override
  State<FriendsListPage> createState() => _FriendsListPage();
}

class _FriendsListPage extends State<FriendsListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _friendCodeController = TextEditingController();

  String? friendCode;
  List<Map<String, dynamic>> friends = [];
  List<Map<String, dynamic>> friendRequests = [];
  List<Map<String, dynamic>> addedFriends = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _assignFriendCodeIfNeeded();
    _loadUserFriendCode();
    _loadFriends();
    _loadFriendRequests();
  }

  Future<void> _assignFriendCodeIfNeeded() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();

    // Check if the user already has a friend code
    if (userDoc.exists && userDoc.data()!['friendCode'] != null) {
      setState(() {
        friendCode = userDoc['friendCode'];
      });
      return;
    }

    // Generate and assign a unique friend code
    String newFriendCode;
    do {
      newFriendCode = _generateRandomCode(6); // Generate a 6-character code
    } while (await _isFriendCodeInUse(newFriendCode));

    await _firestore.collection('users').doc(currentUser.uid).set(
      {'friendCode': newFriendCode},
      SetOptions(merge: true),
    );

    setState(() {
      friendCode = newFriendCode;
    });
  }

// Helper function to generate a random alphanumeric code
  String _generateRandomCode(int length) {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(length, (_) => characters[random.nextInt(characters.length)]).join();
  }

// Helper function to check if the friend code already exists in Firebase
  Future<bool> _isFriendCodeInUse(String code) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('friendCode', isEqualTo: code)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> _loadUserFriendCode() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      setState(() {
        friendCode = userDoc['friendCode'] ?? 'No friend code available';
      });
    }
  }

  Future<void> _loadFriends() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final snapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('friends')
          .get();
      setState(() {
        friends = snapshot.docs.map((doc) {
          return {
            'name': doc['name'],
            'image': doc['imageUrl'],
            'friendId': doc.id,
          };
        }).toList();
      });
    }
  }

  Future<void> _loadFriendRequests() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final snapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('friendRequests')
          .get();
      setState(() {
        friendRequests = snapshot.docs.map((doc) {
          return {
            'name': doc['name'],
            'email': doc['email'],
            'status': doc['status'],
            'requestId': doc.id,
          };
        }).toList();
      });
    }
  }

  Future<void> _sendFriendRequest(String email) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final userSnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      final friendId = userSnapshot.docs[0].id;
      final friendData = userSnapshot.docs[0].data();

      await _firestore
          .collection('users')
          .doc(friendId)
          .collection('friendRequests')
          .add({
        'name': currentUser.displayName ?? 'Unknown',
        'email': currentUser.email,
        'status': 'pending',
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${friendData['name']} ${AppStrings.friendRequestSent}')),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not found')),
      );
    }
  }

  Future<void> _acceptFriendRequest(String requestId, String friendId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('friends')
        .doc(friendId)
        .set({
      'name': friendRequests.firstWhere((req) => req['requestId'] == requestId)['name'],
      'imageUrl': friendRequests.firstWhere((req) => req['requestId'] == requestId)['image'],
    });

    await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('friendRequests')
        .doc(requestId)
        .update({'status': 'accepted'});

    _loadFriends();
    _loadFriendRequests();
  }

  @override
  Widget build(BuildContext context) {
    final filteredFriends = friends.where((friend) {
      return friend['name'].toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBarColor,
        title: Text(AppStrings.friendsTitle),
      ),
      body: Column(
        children: [
          if (friendCode != null)
            Padding(
              padding: const EdgeInsets.all(AppDimens.padding),
              child: Text(
                'Your Friend Code: $friendCode',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(AppDimens.padding),
            child: TextField(
              decoration: InputDecoration(
                labelText: AppStrings.searchFriendsLabel,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          ElevatedButton(
            onPressed: () => _showAddFriendDialog(),
            child: const Text('Add Friend'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredFriends.length,
              itemBuilder: (context, index) {
                final friend = filteredFriends[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(friend['image']),
                  ),
                  title: Text(friend['name']),
                  trailing: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      _sendChallenge(friend['friendId']);
                    },
                  ),
                  onTap: () => _showFriendOptionsDialog(friend),
                );
              },
            ),
          ),
          const Divider(),
          _buildFriendRequestsSection(),
        ],
      ),
    );
  }

  void _showAddFriendDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Friend'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Enter friend\'s email'),
              ),
              TextField(
                controller: _friendCodeController,
                decoration: const InputDecoration(labelText: 'Or enter friend code'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_emailController.text.isNotEmpty) {
                  _sendFriendRequest(_emailController.text);
                }
                Navigator.pop(context);
              },
              child: const Text('Send Request'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFriendRequestsSection() {
    return friendRequests.isNotEmpty
        ? Column(
      children: [
        const Text('Friend Requests'),
        ListView.builder(
          shrinkWrap: true,
          itemCount: friendRequests.length,
          itemBuilder: (context, index) {
            final request = friendRequests[index];
            return ListTile(
              title: Text(request['name']),
              subtitle: Text('Request Status: ${request['status']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () => _acceptFriendRequest(request['requestId'], request['friendId']),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      // Add code to decline friend request here
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    )
        : const Center(child: Text('No friend requests available.'));
  }

  void _showFriendOptionsDialog(Map<String, dynamic> friend) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(friend['name']),
          actions: [
            TextButton(
              onPressed: () {
                _sendChallenge(friend['friendId']);
                Navigator.pop(context);
              },
              child: const Text('Challenge'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendChallenge(String friendId) async {
    // Implementation of sending a challenge request
  }
}