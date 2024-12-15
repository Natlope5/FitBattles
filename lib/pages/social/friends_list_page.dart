import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitbattles/services/firebase/friends_service.dart';
import 'package:fitbattles/pages/social/chat_page.dart';
import 'package:fitbattles/settings/ui/theme_provider.dart';

class FriendsListPage extends StatefulWidget {
  const FriendsListPage({super.key});

  @override
  State<FriendsListPage> createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  final FriendsService _firebaseService = FriendsService();

  List<Map<String, dynamic>> friends = [];
  List<Map<String, dynamic>> friendRequests = [];
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    await _loadFriends();
    await _loadFriendRequests();
  }

  Future<void> _loadFriends() async {
    final loadedFriends = await _firebaseService.fetchFriends();
    if (!mounted) return;
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
          title: const Text('Add a Friend'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter your friend\'s email or code:', style: TextStyle(color: Colors.grey[700])),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Friend\'s Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text('OR', style: TextStyle(color: Colors.grey[500])),
              const SizedBox(height: 16),
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
                  final friendData = await _firebaseService.sendFriendRequest(email: emailController.text);
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

    final privacySetting = await _firebaseService.getFriendPrivacy(friendId);
    bool canViewStats = privacySetting == 'public' || privacySetting == 'friends';

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
                      if (canViewStats)
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
                        )
                      else
                        const Text('This user\'s stats are private.'),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.message),
                        label: const Text('Message'),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(friendId: friendId, friendName: friend['name']),
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

  Future<void> _showFriendRequestsBottomSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Friend Requests',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: friendRequests.isNotEmpty
                    ? ListView.builder(
                  itemCount: friendRequests.length,
                  itemBuilder: (context, index) {
                    final request = friendRequests[index];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundImage: AssetImage('assets/images/placeholder_avatar.png'),
                        ),
                        title: Text(request['name']),
                        subtitle: Text('Status: ${request['status']}'),
                        trailing: Wrap(
                          spacing: 8,
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
                                await _firebaseService.declineFriendRequest(
                                  request['requestId'],
                                );
                                _loadFriendRequests();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
                    : const Center(child: Text('No friend requests available.')),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final bgColor = isDark
        ? const Color(0xFF1F1F1F)
        : null;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Container(
          decoration: !isDark
              ? const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE7E9EF), Color(0xFF2C96CF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          )
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modern Header with Requests
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Friends',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        InkWell(
                          onTap: () => _showFriendRequestsBottomSheet(context),
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Icon(Icons.person_add_alt_1,
                                  size: 28, color: isDark ? Colors.white : Colors.black),
                              if (friendRequests.isNotEmpty)
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: Center(
                                    child: Text(
                                      friendRequests.length.toString(),
                                      style: const TextStyle(color: Colors.white, fontSize: 10),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Always visible search bar
                    TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Search friends...',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                        ),
                        prefixIcon: Icon(Icons.search, color: isDark ? Colors.white : Colors.black),
                        filled: true,
                        fillColor: isDark ? Colors.grey[800] : Colors.white.withOpacity(0.9),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onTap: () {
                        // Request focus so that the keyboard stays open
                        _searchFocusNode.requestFocus();
                      },
                      onChanged: (value) {
                        // Implement friend filtering if desired
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // Friends List
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.transparent : Colors.white.withOpacity(0.8),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: friends.isNotEmpty
                      ? ListView.builder(
                    itemCount: friends.length,
                    padding: const EdgeInsets.all(16.0),
                    itemBuilder: (context, index) {
                      final friend = friends[index];
                      return Card(
                        color: isDark ? Colors.grey[850] : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundImage: friend['image'] != null && friend['image'].isNotEmpty
                                ? NetworkImage(friend['image'])
                                : const AssetImage('assets/images/placeholder_avatar.png')
                            as ImageProvider,
                            radius: 24,
                          ),
                          title: Text(
                            friend['name'] ?? 'Unknown',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            friend['email'] ?? 'No email provided',
                            style: TextStyle(
                              color: isDark ? Colors.grey[300] : Colors.grey[700],
                            ),
                          ),
                          onTap: () {
                            _showFriendStatsDialog(friend);
                          },
                        ),
                      );
                    },
                  )
                      : Center(
                    child: Text(
                      'No friends found.',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Floating action button to send friend requests
      floatingActionButton: FloatingActionButton(
        onPressed: _sendFriendRequest,
        backgroundColor: const Color(0xFF85C83E),
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}