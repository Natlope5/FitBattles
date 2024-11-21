import 'package:flutter/material.dart';
import 'package:fitbattles/services/firebase/friends_service.dart';
import 'package:fitbattles/pages/social/messages_page.dart';

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

  Future<void> _showFriendStatsDialog(Map<String, dynamic> friend) async {
    final friendId = friend['id'];
    final nameController = TextEditingController(text: friend['name']);
    bool isEditing = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      friend['name'] ?? 'Unknown',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      setState(() {
                        isEditing = !isEditing;
                      });
                    },
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Weekly Stats',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FutureBuilder<Map<String, dynamic>>(
                        future: _firebaseService.getFriendWeeklyStats(friendId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return const Text('Failed to fetch stats.');
                          }
                          final stats = snapshot.data ?? {};
                          final weeklyCalories = stats['calories'] ?? 0;
                          final workoutsCount = stats['workouts'] ?? 0;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Calories Burned: $weeklyCalories kcal'),
                              Text('Workouts Completed: $workoutsCount'),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.message),
                        label: const Text('Message'),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MessagesPage(friendId: friendId, friendName: friend['name']),
                            ),
                          );
                        },
                      ),
                      if (isEditing)
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'Edit Friend\'s Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                if (isEditing)
                  ElevatedButton(
                    onPressed: () async {
                      await _firebaseService.editFriendName(friendId, nameController.text);
                      Navigator.pop(context);
                      _loadFriends();
                    },
                    child: const Text('Save'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFriendsList() {
    return friends.isNotEmpty
        ? ListView.builder(
      itemCount: friends.length,
      itemBuilder: (context, index) {
        final friend = friends[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: friend['image'] != null && friend['image'].isNotEmpty
                ? NetworkImage(friend['image'])
                : const AssetImage('assets/placeholder_avatar.png') as ImageProvider,
          ),
          title: Text(friend['name'] ?? 'Unknown'),
          subtitle: Text(friend['email'] ?? 'No email provided'),
          onTap: () {
            _showFriendStatsDialog(friend);
          },
        );
      },
    )
        : const Center(child: Text('No friends added yet.'));
  }

  Widget _buildFriendRequestsList() {
    return friendRequests.isNotEmpty
        ? ListView.builder(
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
                  _loadFriends();
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