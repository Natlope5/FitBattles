import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitbattles/settings/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';

class ChallengeSchedulingPage extends StatefulWidget {
  const ChallengeSchedulingPage({super.key});

  @override
  ChallengeSchedulingPageState createState() => ChallengeSchedulingPageState();
}

class ChallengeSchedulingPageState extends State<ChallengeSchedulingPage> with SingleTickerProviderStateMixin {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  double challengeIntensity = 1.0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late AnimationController _controller;
  late Animation<double> _animation;

  final TextEditingController challengeNameController = TextEditingController();
  final TextEditingController challengeDescriptionController = TextEditingController();

  final List<String> communityChallenges = [
    "10,000 Steps a Day",
    "30 Days of Yoga",
    "Daily Plank Challenge",
    "Weekly Running Club"
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
        title: const Text('Schedule Challenge'),
        backgroundColor: isDarkTheme ? Colors.black : const Color(0xFF5D6C8A),
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
                  'Schedule Your Challenge!',
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

  void createChallengeWithId(String challengeId, String name, String description) {
    CollectionReference challengesRef = _firestore.collection('communityChallenges');
    challengesRef.doc(challengeId).set({
      'name': name,
      'description': description,
      'participants': [],
      'intensity': challengeIntensity,
    }).then((_) {
      logger.i('Challenge created with custom ID: $challengeId');
    }).catchError((error) {
      logger.i('Error creating challenge: $error');
    });
  }

  void _joinChallenge(String challenge) {
    String userId = "currentUserId"; // Replace with actual user ID retrieval logic
    CollectionReference challengesRef = _firestore.collection('communityChallenges');

    challengesRef.doc(challenge).update({
      'participants': FieldValue.arrayUnion([userId])
    }).then((_) {
      _showSnackBar('Successfully joined $challenge!');
    }).catchError((error) {
      _showSnackBar('Failed to join $challenge: ${error.toString()}');
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, bool isDarkTheme, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDarkTheme ? Colors.white70 : Colors.black87),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide(color: isDarkTheme ? Colors.grey : Colors.teal, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide(color: const Color(0xFF85C83E), width: 2.0),
        ),
      ),
      style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
    );
  }
}
