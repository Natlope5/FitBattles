import 'package:cloud_firestore/cloud_firestore.dart';
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
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  double challengeIntensity = 1.0;

  late AnimationController _controller;
  late Animation<double> _animation;

  final TextEditingController challengeNameController = TextEditingController();
  final TextEditingController challengeDescriptionController = TextEditingController();

  final List<String> communityChallenges = [
    "Core Crusher",
    "Goal Setter",
    "Healthy Habit",
    "Community Leader",
    "Nutrition Enthusiast",
    "Cardio King/Queen",
    "Strength Specialist",
    "Fit Friend",
    "10K Steps a Day",
    "Consistent Trainer",
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(_controller);
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
        title: Text('Community Challenges'),
      ),
      body: Padding(
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
            const Text('Join a Community Challenge:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
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
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF85C83E),
              ),
              onPressed: () {
                String challengeName = challengeNameController.text.trim();
                String challengeDescription = challengeDescriptionController.text.trim();

                if (challengeName.isNotEmpty && challengeDescription.isNotEmpty) {
                  String challengeId = DateTime.now().millisecondsSinceEpoch.toString(); // Unique ID
                  createChallengeWithId(challengeId, challengeName, challengeDescription);
                  _showSnackBar('Challenge Scheduled!');
                  _showNotification('New Challenge Created', 'You have successfully created a new challenge: $challengeName');
                } else {
                  _showSnackBar('Please enter both name and description.');
                }
              },
              child: const Text('Schedule Challenge'),
            ),
          ],
        ),
      ),
    );
  }

  // Function to create a challenge in Firestore
  void createChallengeWithId(String challengeId, String challengeName, String challengeDescription) {
    FirebaseFirestore.instance.collection('communityChallenges').doc(challengeId).set({
      'name': challengeName,
      'description': challengeDescription,
      'intensity': challengeIntensity,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Function to join a community challenge
  void _joinChallenge(String challengeName) {
    _showSnackBar('You joined the challenge: $challengeName');
    // Additional logic for joining a challenge can be added here
  }

  // Helper method to show SnackBar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // Helper method to show notification
  void _showNotification(String title, String message) {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.show(
      0,
      title,
      message,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'your_channel_id',
          'your_channel_name',
          channelDescription: 'your_channel_description',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  // Helper method to build the text fields
  Widget _buildTextField(String label, TextEditingController controller, bool isDarkTheme, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
        border: OutlineInputBorder(),
      ),
    );
  }
}
