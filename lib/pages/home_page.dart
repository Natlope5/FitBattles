import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitbattles/challenges/challenge.dart';
import 'package:fitbattles/challenges/earned_points_page.dart';
import 'package:fitbattles/settings/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.id, required this.email, required String uid});

  final String id; // User ID
  final String email; // User email

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _photoURL;
  File? _image;
  final picker = ImagePicker();
  final Logger logger = Logger();
  bool showPreloadedChallenges = false;
  int pointsEarned = 500;
  int pointsGoal = 1000;


  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _pickAndUploadImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      try {
        final storageRef = FirebaseStorage.instance.ref();
        final userId = FirebaseAuth.instance.currentUser!.uid;
        final imageRef = storageRef.child('profile_images/$userId.jpg');

        await imageRef.putFile(_image!); // Upload the image
        String downloadURL = await imageRef
            .getDownloadURL(); // Get download URL

        // Save download URL to Firestore
        await FirebaseFirestore.instance.collection('users').doc(userId).update(
            {
              'photoURL': downloadURL,
            });
      } catch (e) {
        logger.e("Error uploading image: $e");
      }
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      DocumentSnapshot userProfile = await FirebaseFirestore.instance
          .collection('users').doc(widget.id).get();
      setState(() {
        _photoURL = userProfile['photoURL'];
      });
    } catch (e) {
      logger.e("Error loading user profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF5D6C8A), // Blue background
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Gray AppBar
        automaticallyImplyLeading: false,
        title: const Text(
          "Home Page",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(
                  context, '/settings'); // Navigate to Settings page
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 100.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _buildHeader(themeProvider),
              const SizedBox(height: 32),
              _buildPointsSection(context, themeProvider),
              const SizedBox(height: 32),
              _buildChallengesContainer(context, themeProvider),
              const SizedBox(height: 32),
              _buildWorkoutContainer(context, themeProvider),
              const SizedBox(height: 32),
              _buildGoalsContainer(context, themeProvider),
              const SizedBox(height: 32),
              _buildHistoryContainer(context, themeProvider),
              const SizedBox(height: 32),
              _buildTopChallengedFriends(exampleFriends, themeProvider),
              _buildFriendsListButton(context, themeProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeProvider themeProvider) {
    final textColor = themeProvider.isDarkMode ? Colors.white : Colors.black;

    return Container(
      color: Colors.transparent,
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'FitBattles',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _pickAndUploadImage,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: themeProvider.isDarkMode
                  ? Colors.grey[700]
                  : Colors.grey[300],
              backgroundImage: _image != null
                  ? FileImage(_image!)
                  : (_photoURL != null ? NetworkImage(_photoURL!) : null),
              child: _image == null && _photoURL == null
                  ? Icon(Icons.add_a_photo, color: textColor, size: 30)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsSection(BuildContext context,
      ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Points Earned',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: pointsEarned / pointsGoal,
              minHeight: 20,
              backgroundColor: themeProvider.isDarkMode
                  ? Colors.grey[800]
                  : Colors.grey[300],
              color: const Color(0xFF85C83E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$pointsEarned / $pointsGoal points',
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                  const EarnedPointsPage(
                    points: 1000,
                    streakDays: 350,
                    totalChallengesCompleted: 0,
                    pointsEarnedToday: 0,
                    bestDayPoints: 0,
                    userId: '',
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, // Set text color to white
              backgroundColor: const Color(0xFF85C83E),
            ),
            child: const Text('View Earned Points'),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengesContainer(BuildContext context,
      ThemeProvider themeProvider) {
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      width: MediaQuery
          .of(context)
          .size
          .width * 0.9,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Challenges',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/user_challenges');
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, // Set text color to white
              backgroundColor: const Color(0xFF85C83E),
            ),
            child: const Text('Challenges'), // Button text
          ),
          const SizedBox(height: 16),

          // New button for scheduling a challenge
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                  context, '/scheduleChallenge'); // Navigate to scheduling page
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, // Set text color to white
              backgroundColor: const Color(0xFF85C83E),
            ),
            child: const Text('Community Challenges'), // New button text
          ),

          // Existing button to create a new challenge
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/create_challenge');
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, // Set text color to white
              backgroundColor: const Color(0xFF85C83E),
            ),
            child: const Text('New Challenge'), // Button text
          ),
          const SizedBox(height: 16),

          // Existing button to view badges & rewards
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/rewards');
            },
            style: ElevatedButton.styleFrom(
                foregroundColor: themeProvider.isDarkMode ? Colors.white : Colors.black),
            child: const Text('View Badges & Rewards'),

          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/leaderboard');
            },
            style: ElevatedButton.styleFrom(
                foregroundColor: themeProvider.isDarkMode ? Colors.white : Colors.black),
            child: const Text('Leaderboard'),

          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutContainer(BuildContext context, ThemeProvider themeProvider) {
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      width: MediaQuery.of(context).size.width * 0.9, // Responsive width
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Workout', // Section title
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          // Custom Workout button
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/customWorkout');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: themeProvider.isDarkMode
                  ? const Color(0xFF85C83E)  // Dark green for dark mode
                  : const Color(0xFF85C83E), // Light green for light mode
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), // Fully rounded corners
              ),
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            ),
            child: const Text(
              'Custom Workout',
              style: TextStyle(
                color: Colors.white, // White text color
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildWorkoutTrackingButton(context, themeProvider),
        ],
      ),
    );
  }

  Widget _buildGoalsContainer(BuildContext context, ThemeProvider themeProvider) {
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Goals',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/addGoal');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF85C83E),
                foregroundColor: themeProvider.isDarkMode ? Colors.white : Colors.black
            ),
            child: const Text('Add Goal'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/currentGoals');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF85C83E), foregroundColor: themeProvider.isDarkMode ? Colors.white : Colors.black
            ),
            child: const Text('Current Goals'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryContainer(BuildContext context,
      ThemeProvider themeProvider) {
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(128),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      width: MediaQuery
          .of(context)
          .size
          .width * 0.9,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'History',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/history');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF85C83E),
                foregroundColor: themeProvider.isDarkMode ? Colors.white : Colors.black
            ),
            child: const Text('View History'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/healthReport');
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF85C83E),
                foregroundColor: themeProvider.isDarkMode ? Colors.white : Colors.black
            ),
            child: const Text('View Health Report'),
          ),
        ],
      ),
    );
  }

  Widget _buildTopChallengedFriends(List<String> friends,
      ThemeProvider themeProvider) {
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      width: MediaQuery
          .of(context)
          .size
          .width * 0.9,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Challenged Friends',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: friends.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      _showFriendInfo(context, friends[index]
                          .split('/')
                          .last
                          .split('.')
                          .first, friends[index], gamesWon: 25,
                          streakDays: 10,
                          rank: 3);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage(friends[index]),
                        ),
                        const SizedBox(height: 8),
                        Text(friends[index]
                            .split('/')
                            .last
                            .split('.')
                            .first),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFriendInfo(BuildContext context, String friendName,
      String friendImagePath,
      {int gamesWon = 0, int streakDays = 0, int rank = 0}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF85C83E),
          title: Text(friendName, style: const TextStyle(color: Colors.black)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(friendImagePath),
              const SizedBox(height: 10),
              Text('Games Won: $gamesWon',
                  style: const TextStyle(color: Colors.black)),
              const SizedBox(height: 5),
              Text('Streak Days: $streakDays',
                  style: const TextStyle(color: Colors.black)),
              const SizedBox(height: 5),
              Text('Rank: $rank', style: const TextStyle(color: Colors.black)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  final List<String> exampleFriends = [
    'assets/images/Bob.png',
    'assets/images/Charlie.png',
    'assets/images/Hannah.png',
    'assets/images/Ian.png',
    'assets/images/Fiona.png',
    'assets/images/George.png',
    'assets/images/Ethan.png',
    'assets/images/Diana.png',
    'assets/images/Alice.png',
  ];

  Widget _buildFriendsListButton(BuildContext context, ThemeProvider themeProvider) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(
            context, '/friends'); // Navigate to the friends page
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, // Set text color to white
        backgroundColor: const Color(0xFF85C83E),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 36.0),
      ),
      child: const Text('Explore friends'),
    );
  }
}

// Widget to build the workout tracking navigation button
Widget _buildWorkoutTrackingButton(BuildContext context, ThemeProvider themeProvider) {
  return ElevatedButton(
    onPressed: () {
      Navigator.pushNamed(context, '/workoutTracking'); // Navigate to the workout tracking page
    },
    style: ElevatedButton.styleFrom(
      foregroundColor: themeProvider.isDarkMode ? Colors.white : Colors.black,
      backgroundColor: const Color(0xFF85C83E), // Use the theme color
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 32.0),
    ),
    child: const Text('Workout Tracking'), // Button text
  );
}

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Challenge challenge = ModalRoute.of(context)!.settings.arguments as Challenge;

    return Scaffold(
      appBar: AppBar(
        title: Text(challenge.name), // Display challenge name in the app bar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${challenge.type}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text('Start Date: ${challenge.startDate.toLocal()}'),
            const SizedBox(height: 5),
            Text('End Date: ${challenge.endDate.toLocal()}'),
            const SizedBox(height: 20),
            // Add any additional information you want to show
          ],
        ),
      ),
    );
  }
}