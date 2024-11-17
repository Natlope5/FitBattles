import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitbattles/settings/ui/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(_controller);

    // Initialize community challenges
    _initializeCommunityChallenges();
  }

  @override
  void dispose() {
    _controller.dispose();
    challengeNameController.dispose();
    challengeDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkTheme = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Challenges'),
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
            _buildTextField('Challenge Description', challengeDescriptionController, isDarkTheme, maxLines: 3),
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
            const SizedBox(height: 16),
            const Text('Join a Community Challenge:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              itemCount: communityChallenges.length,
              itemBuilder: (context, index) {
                return Card(
                  color: isDarkTheme ? Colors.grey[800] : Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(
                      communityChallenges[index],
                      style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
                    ),
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF85C83E),
              ),
              onPressed: () {
                String challengeName = challengeNameController.text.trim();
                String challengeDescription = challengeDescriptionController.text.trim();

                if (challengeName.isNotEmpty && challengeDescription.isNotEmpty && selectedStartDate != null && selectedEndDate != null) {
                  String challengeId = DateTime.now().millisecondsSinceEpoch.toString(); // Unique ID
                  createChallengeWithId(challengeId, challengeName, challengeDescription);
                  _showNotification('New Challenge Created', 'You have successfully created a new challenge: $challengeName');
                } else {
                  _showSnackBar('Please fill all fields including start and end dates.');
                }
              },
              child: const Text('Schedule Challenge'),
            ),
          ],
        ),
      ),
    );
  }

  // Method to initialize community challenges
  void _initializeCommunityChallenges() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('communityChallenges').get();

      for (var doc in querySnapshot.docs) {
        setState(() {
          communityChallenges.add(doc['name'] as String);
        });
      }

      _showSnackBar('Community challenges initialized.');
    } catch (e) {
      _showSnackBar('Failed to initialize challenges: $e');
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
      _showSnackBar('User not authenticated. Cannot create challenge.');
    }
  }

  // Function to join a community challenge with user tracking
  void _joinChallenge(String challengeName) async {
    try {
      String sanitizedChallengeName = challengeName.replaceAll('/', '_');
      final collectionRef = FirebaseFirestore.instance.collection('communityChallenges');

      final challengeDoc = await collectionRef.doc(sanitizedChallengeName).get();

      if (!challengeDoc.exists) {
        await collectionRef.doc(sanitizedChallengeName).set({
          'name': challengeName,
          'description': 'This is a community challenge: $challengeName',
          'intensity': 1.0,
          'timestamp': FieldValue.serverTimestamp(),
        });
        _showSnackBar('Challenge created and joined: $challengeName');
      } else {
        _showSnackBar('You joined the challenge: $challengeName');
      }
    } catch (e) {
      _showSnackBar('Failed to join challenge: $e');
    }
  }

  // Helper method to show SnackBar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // Helper method to show notification
  void _showNotification(String title, String message) {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'community_challenge_channel',
      'CommunityChallengeNotifications',
      channelDescription: 'Notifications related to community challenges, including new challenge creation.',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    flutterLocalNotificationsPlugin.show(
      0,
      title,
      message,
      platformDetails,
    );
  }

  // Date and time selection methods
  Future<void> _selectStartDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedStartDate = pickedDate;
      });
    }
  }

  Future<void> _selectStartTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedStartTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        selectedStartTime = pickedTime;
      });
    }
  }

  Future<void> _selectEndDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedEndDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedEndDate = pickedDate;
      });
    }
  }

  Future<void> _selectEndTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedEndTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        selectedEndTime = pickedTime;
      });
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, bool isDarkTheme, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: isDarkTheme ? Colors.grey[800] : Colors.white,
      ),
    );
  }
}
