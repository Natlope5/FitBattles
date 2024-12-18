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
    if (!mounted) return;
    setState(() {
      friendRequests = requests;
    });
  }

  void _showFriendRequestsBottomSheet(BuildContext context) {
    final localContext = context; // Capture context locally to avoid async gap issues.
    final emailController = TextEditingController();
    final friendCodeController = TextEditingController();

    showModalBottomSheet(
      context: localContext,
      backgroundColor: Theme.of(localContext).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          height: MediaQuery.of(sheetContext).size.height * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Centered handle bar
              Center(
                child: Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Friend Requests',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: friendRequests.isNotEmpty
                    ? ListView.builder(
                  itemCount: friendRequests.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    final request = friendRequests[index];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      color: Theme.of(localContext).cardColor,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/placeholder_avatar.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        title: Text(
                          request['name'],
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          textAlign: TextAlign.start,
                        ),
                        subtitle: Text(
                          'Status: ${request['status']}',
                          textAlign: TextAlign.start,
                        ),
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
                                if (!mounted) return;
                                await _loadFriendRequests();
                                await _loadFriends();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.clear, color: Colors.red),
                              onPressed: () async {
                                await _firebaseService.declineFriendRequest(
                                  request['requestId'],
                                );
                                if (!mounted) return;
                                await _loadFriendRequests();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
                    : Align(
                  alignment: Alignment.centerLeft,
                  child: const Text('No friend requests available.'),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Add a Friend',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                textAlign: TextAlign.left,
                decoration: const InputDecoration(
                  labelText: 'Friend\'s Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'OR',
                  style: TextStyle(color: Colors.grey[500]),
                  textAlign: TextAlign.start,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: friendCodeController,
                textAlign: TextAlign.left,
                decoration: const InputDecoration(
                  labelText: 'Friend\'s Code',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (emailController.text.isNotEmpty) {
                        final friendData = await _firebaseService.sendFriendRequest(email: emailController.text);
                        _handleFriendRequestResponse(friendData, localContext);
                      } else if (friendCodeController.text.isNotEmpty) {
                        final friendData = await _firebaseService.sendFriendRequest(
                          friendCode: friendCodeController.text,
                        );
                        _handleFriendRequestResponse(friendData, localContext);
                      }
                        Navigator.pop(sheetContext);
                    },
                    child: const Text('Send'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleFriendRequestResponse(Map<String, dynamic>? friendData, BuildContext localContext) {
    if (!mounted) return;
    if (friendData != null) {
      ScaffoldMessenger.of(localContext).showSnackBar(
        SnackBar(content: Text('Friend request sent to ${friendData['name']}!')),
      );
      _loadFriendRequests();
    } else {
      ScaffoldMessenger.of(localContext).showSnackBar(
        const SnackBar(content: Text('User not found.')),
      );
    }
  }

  Future<void> _showFriendStatsDialog(Map<String, dynamic> friend) async {
    final localContext = context; // Capture context to avoid async usage issue
    final friendId = friend['id'];
    final nameController = TextEditingController(text: friend['name']);
    bool isEditing = false;

    final privacySetting = await _firebaseService.getFriendPrivacy(friendId);
    bool canViewStats = privacySetting == 'public' || privacySetting == 'friends';

    showDialog(
      context: localContext,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      friend['name'] ?? 'Unknown',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.start,
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
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: 8),
                      if (canViewStats)
                        FutureBuilder<Map<String, dynamic>>(
                          future: _firebaseService.getFriendWeeklyStats(friendId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              return const Text('Failed to fetch stats.', textAlign: TextAlign.start);
                            }
                            final stats = snapshot.data ?? {};
                            final weeklyCalories = stats['calories'] ?? 0;
                            final workoutsCount = stats['workouts'] ?? 0;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Calories Burned: $weeklyCalories kcal', textAlign: TextAlign.start),
                                Text('Workouts Completed: $workoutsCount', textAlign: TextAlign.start),
                              ],
                            );
                          },
                        )
                      else
                        const Text('This user\'s stats are private.', textAlign: TextAlign.start),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.message),
                        label: const Text('Message'),
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          Navigator.push(
                            dialogContext,
                            MaterialPageRoute(
                              builder: (newContext) => ChatPage(friendId: friendId, friendName: friend['name']),
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
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                if (isEditing)
                  ElevatedButton(
                    onPressed: () async {
                      await _firebaseService.editFriendName(friendId, nameController.text);
                      Navigator.pop(dialogContext);
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final bgColor = isDark ? const Color(0xFF1F1F1F) : null;

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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: Text(
                  'Friends',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),

              // Search area
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 0.0),
                child: TextField(
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
                    _searchFocusNode.requestFocus();
                  },
                  onChanged: (value) {
                    // Implement friend filtering if desired
                  },
                ),
              ),

              const SizedBox(height: 16),

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
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[800],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: friend['image'] != null && friend['image'].isNotEmpty
                                  ? Image.network(friend['image'], fit: BoxFit.cover)
                                  : Image.asset('assets/images/placeholder_avatar.png', fit: BoxFit.cover),
                            ),
                          ),
                          title: Text(
                            friend['name'] ?? 'Unknown',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.start,
                          ),
                          subtitle: Text(
                            friend['email'] ?? 'No email provided',
                            style: TextStyle(
                              color: isDark ? Colors.grey[300] : Colors.grey[700],
                            ),
                            textAlign: TextAlign.start,
                          ),
                          onTap: () {
                            _showFriendStatsDialog(friend);
                          },
                        ),
                      );
                    },
                  )
                      : Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'No friends found.',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFriendRequestsBottomSheet(context),
        backgroundColor: const Color(0xFF85C83E),
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
