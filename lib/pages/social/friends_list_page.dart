import 'package:flutter/material.dart';
import 'package:fitbattles/firebase/services/friends_service.dart';

class FriendsListPage extends StatefulWidget {
  const FriendsListPage({super.key});

  @override
  State<FriendsListPage> createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  final FriendsService _firebaseService = FriendsService();
  String? friendCode;
  List<Map<String, dynamic>> friends = [];
  List<Map<String, dynamic>> friendRequests = [];

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    friendCode = await _firebaseService.ensureFriendCode();
    _loadFriends();
    _loadFriendRequests();
  }

  Future<void> _loadFriends() async {
    final loadedFriends = await _firebaseService.fetchFriends();
    setState(() {
      friends = loadedFriends;
    });
  }

  Future<void> _loadFriendRequests() async {
    final requests = await _firebaseService.fetchFriendRequests();
    setState(() {
      friendRequests = requests;
    });
  }

  void _sendFriendRequest() async {
    final emailController = TextEditingController();
    final friendCodeController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Send Friend Request'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Friend\'s Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: friendCodeController,
                decoration: const InputDecoration(
                  labelText: 'Friend\'s Code',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (emailController.text.isNotEmpty) {
                  final friendData = await _firebaseService.sendFriendRequest(
                    email: emailController.text,
                  );
                  _handleFriendRequestResponse(friendData);
                } else if (friendCodeController.text.isNotEmpty) {
                  final friendData = await _firebaseService.sendFriendRequest(
                    friendCode: friendCodeController.text,
                  );
                  _handleFriendRequestResponse(friendData);
                }
                Navigator.pop(context);
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  void _handleFriendRequestResponse(Map<String, dynamic>? friendData) {
    if (friendData != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend request sent to ${friendData['name']}!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not found.')),
      );
    }
  }

  Widget _buildFriendsList() {
    return friends.isNotEmpty
        ? ListView.builder(
      itemCount: friends.length,
      itemBuilder: (context, index) {
        final friend = friends[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(friend['image']),
          ),
          title: Text(friend['name']),
          subtitle: Text(friend['email']),
        );
      },
    )
        : const Center(child: Text('No friends added yet.'));
  }

  Widget _buildFriendRequestsList() {
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
              subtitle: Text('Status: ${request['status']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () async {
                      await _firebaseService.acceptFriendRequest(
                        request['requestId'],
                        request['email'],
                      );
                      _loadFriendRequests();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.red),
                    onPressed: () async {
                      await _firebaseService.declineFriendRequest(request['requestId']);
                      _loadFriendRequests();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _sendFriendRequest,
          ),
        ],
      ),
      body: Column(
        children: [
          if (friendCode != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Your Friend Code: $friendCode',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(child: _buildFriendsList()),
          const Divider(),
          Expanded(child: _buildFriendRequestsList()),
        ],
      ),
    );
  }
}