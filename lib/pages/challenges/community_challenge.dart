import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitbattles/settings/ui/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fitbattles/services/firebase/friends_service.dart';
import 'package:fitbattles/main.dart';

class CommunityChallengePage extends StatefulWidget {
  const CommunityChallengePage({super.key});

  @override
  CommunityChallengePageState createState() => CommunityChallengePageState();
}

class CommunityChallengePageState extends State<CommunityChallengePage> with SingleTickerProviderStateMixin {
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;
  double challengeIntensity = 1.0;

  late AnimationController _controller;
  late Animation<double> _animation;

  final TextEditingController challengeNameController = TextEditingController();
  final TextEditingController challengeDescriptionController = TextEditingController();

  final List<String> communityChallenges = [];
  final FriendsService _friendsService = FriendsService();

  List<Map<String, dynamic>> friends = [];
  String? selectedFriendId;

  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(_controller);

    _initializeCommunityChallenges();
    _fetchFriends();
  }

  @override
  void dispose() {
    _controller.dispose();
    challengeNameController.dispose();
    challengeDescriptionController.dispose();
    super.dispose();
  }
  Future<List<String>> getFriendsList(String userId) async {
    try {
      var snapshot = await FirebaseFirestore.instance.collection('users').doc(userId).collection('friends').get();
      List<String> friends = [];
      for (var doc in snapshot.docs) {
        friends.add(doc['friendName']); // Assuming friendName is the field where the friend's name is stored
      }
      return friends;
    } catch (e) {
      logger.e('Error fetching friends list: $e');
      return [];
    }
  }
  void _fetchFriends() async {
    try {
      List<Map<String, dynamic>> fetchedFriends = await _friendsService.fetchFriends();
      setState(() {
        friends = fetchedFriends
            .where((friend) => friend['id'] != null && friend['name'] != null)
            .toList();
      });
    } catch (e) {
      _showSnackBar('Failed to fetch friends: $e');
    }
  }

  void _joinChallenge(String challengeName) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        final challengeQuery = await FirebaseFirestore.instance
            .collection('communityChallenges')
            .where('name', isEqualTo: challengeName)
            .get();

        if (challengeQuery.docs.isNotEmpty) {
          final challengeDoc = challengeQuery.docs.first;

          // Update communityChallenge in user's challenge list
          final userChallengeRef = FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .collection('challenges')
              .doc(challengeDoc.id);

          await userChallengeRef.set({
            'challengeName': challengeName,
            'challengeCompleted': false,
            'communityChallenge': true,
          }, SetOptions(merge: true));

          _showSnackBar('You joined the community challenge: $challengeName');
        } else {
          _showSnackBar('Challenge not found.');
        }
      } catch (e) {
        _showSnackBar('Error joining challenge: $e');
      }
    }
  }

  void _initializeCommunityChallenges() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('communityChallenges').get();

      for (var doc in querySnapshot.docs) {
        setState(() {
          communityChallenges.add(doc['name'] as String);
        });
      }
    } catch (e) {
      _showSnackBar('Failed to initialize challenges: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkTheme = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Challenges'),
        actions: [
          Switch(
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });

              if (_notificationsEnabled) {
                _showNotification('Notifications Enabled', 'You will now receive notifications.');
              } else {
                _cancelNotifications();
              }
            },
            activeColor: Colors.white,
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.shade400,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ScaleTransition(
                scale: _animation,
                child: Text(
                  'Community Challenges!',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: isDarkTheme ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField('Challenge Name', challengeNameController, isDarkTheme),
            const SizedBox(height: 16),
            _buildTextField(
              'Challenge Description',
              challengeDescriptionController,
              isDarkTheme,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            const Text('Select a Friend:', style: TextStyle(fontSize: 18)),
            DropdownButton<String>(
              value: selectedFriendId,
              hint: const Text('Choose a friend'),
              isExpanded: true,
              items: friends.map((friend) {
                return DropdownMenuItem<String>(
                  value: friend['id'] != null ? friend['id'] as String : null,
                  child: Text(friend['name'] as String),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  selectedFriendId = value;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Challenge Intensity:', style: TextStyle(fontSize: 18)),
            Slider(
              value: challengeIntensity,
              min: 1.0,
              max: 5.0,
              divisions: 4,
              label: challengeIntensity.round().toString(),
              onChanged: (double value) {
                setState(() {
                  challengeIntensity = value;
                });
              },
              activeColor: const Color(0xFF85C83E),
              inactiveColor: Colors.teal.withAlpha(76),
            ),
            const SizedBox(height: 16),
            _buildDateAndTimePickers(),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF85C83E),
              ),
              onPressed: _createChallenge,
              child: const Text('Schedule Challenge'),
            ),
            const SizedBox(height: 20),
            const Text('Available Challenges:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: communityChallenges.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(communityChallenges[index]),
                    trailing: ElevatedButton(
                      onPressed: () {
                        _joinChallenge(communityChallenges[index]);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF85C83E),
                      ),
                      child: const Text('Join'),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateAndTimePickers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Start Date & Time:', style: TextStyle(fontSize: 18)),
        Row(
          children: [
            ElevatedButton(
              onPressed: _selectStartDate,
              child: Text(selectedStartDate == null ? 'Select Date' : '${selectedStartDate!.toLocal()}'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _selectStartTime,
              child: Text(selectedStartTime == null ? 'Select Time' : selectedStartTime!.format(context)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Select End Date & Time:', style: TextStyle(fontSize: 18)),
        Row(
          children: [
            ElevatedButton(
              onPressed: _selectEndDate,
              child: Text(selectedEndDate == null ? 'Select Date' : '${selectedEndDate!.toLocal()}'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _selectEndTime,
              child: Text(selectedEndTime == null ? 'Select Time' : selectedEndTime!.format(context)),
            ),
          ],
        ),
      ],
    );
  }

  void _createChallenge() {
    String challengeName = challengeNameController.text.trim();
    String challengeDescription = challengeDescriptionController.text.trim();

    if (challengeName.isNotEmpty &&
        challengeDescription.isNotEmpty &&
        selectedStartDate != null &&
        selectedEndDate != null &&
        selectedFriendId != null) {
      String challengeId = DateTime.now().millisecondsSinceEpoch.toString(); // Unique ID
      createChallengeWithId(challengeId, challengeName, challengeDescription);
      if (_notificationsEnabled) {
        _showNotification('New Challenge Created', 'You have successfully created a new challenge: $challengeName');
      }
    } else {
      _showSnackBar('Please fill all fields, including start and end dates.');
    }
  }

  // Function to create a challenge in Firestore with user tracking
  void createChallengeWithId(String challengeId, String challengeName, String challengeDescription) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String userId = currentUser.uid;

      FirebaseFirestore.instance.collection('communityChallenges').doc(challengeId).set({
        'name': challengeName,
        'description': challengeDescription,
        'intensity': challengeIntensity,
        'startDate': selectedStartDate,
        'endDate': selectedEndDate,
        'timestamp': FieldValue.serverTimestamp(),
        'createdBy': userId,
        'participants': [userId],
      }).then((_) {
        _showSnackBar('Challenge created successfully!');
      }).catchError((error) {
        _showSnackBar('Failed to create challenge: $error');
      });
    } else {
      _showSnackBar('You must be logged in to create a challenge.');
    }
  }

  // Function to display notification for new challenges
  void _showNotification(String title, String body) {
    localNotificationsPlugin.show(
      0,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'app_notifications_channel',  // Channel ID
          'App Notifications',          // Channel name
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
  void _cancelNotifications() {
    // Cancel all notifications
    localNotificationsPlugin.cancelAll();

  }

  // Date and time pickers
  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedStartDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedStartDate) {
      setState(() {
        selectedStartDate = picked;
      });
    }
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedStartTime ?? TimeOfDay.now(),
    );

    if (picked != null && picked != selectedStartTime) {
      setState(() {
        selectedStartTime = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedEndDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedEndDate) {
      setState(() {
        selectedEndDate = picked;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedEndTime ?? TimeOfDay.now(),
    );

    if (picked != null && picked != selectedEndTime) {
      setState(() {
        selectedEndTime = picked;
      });
    }
  }
  // Build text input field widget
  Widget _buildTextField(String label, TextEditingController controller, bool isDarkTheme, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        filled: true,
        fillColor: isDarkTheme ? Colors.grey[800] : Colors.white,
        labelStyle: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
      ),
    );
  }
}