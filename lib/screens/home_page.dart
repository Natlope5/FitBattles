import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitbattles/challenges/challenge.dart';
import 'package:fitbattles/settings/theme_provider.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:fitbattles/challenges/earned_points_page.dart';
import 'package:provider/provider.dart';

import '../settings/app_strings.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.id, required this.email, required String uid});

  final String id; // User ID
  final String email; // User email

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _image; // Variable to hold the selected image
  final picker = ImagePicker(); // Instance of ImagePicker to pick images
  bool showPreloadedChallenges = false; // Flag to show/hide preloaded challenges
  final Logger logger = Logger(); // Logger instance for logging errors
  int pointsEarned = 500; // Example value for earned points
  int pointsGoal = 1000; // Example goal for points

  List<Challenge> preloadedChallenges = [
    Challenge(name: '10,000 Steps Challenge', type: 'Fitness', startDate: DateTime.now(), endDate: DateTime.now().add(const Duration(days: 7)), participants: []),
    Challenge(name: 'Running Challenge', type: 'Fitness', startDate: DateTime.now(), endDate: DateTime.now().add(const Duration(days: 7)), participants: []),
    Challenge(name: '30 Days Fit Challenge', type: 'Fitness', startDate: DateTime.now(), endDate: DateTime.now().add(const Duration(days: 30)), participants: []),
    Challenge(name: 'SitUp Challenge', type: 'Fitness', startDate: DateTime.now(), endDate: DateTime.now().add(const Duration(days: 7)), participants: []),
    Challenge(name: '100 Squat Challenge', type: 'Fitness', startDate: DateTime.now(), endDate: DateTime.now().add(const Duration(days: 30)), participants: []),
  ];

  Future<void> _pickAndUploadImage() async {
    // Picking an image from the gallery
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Update the state with the selected image
      setState(() {
        _image = File(pickedFile.path);
      });

      try {
        // Upload the image to Firebase Storage
        final storageRef = FirebaseStorage.instance.ref();
        final userId = FirebaseAuth.instance.currentUser!.uid;
        final imageRef = storageRef.child('profile_images/$userId.jpg');

        await imageRef.putFile(_image!); // Upload the image

        // Get the download URL of the uploaded image
        String downloadURL = await imageRef.getDownloadURL();

        // Save the download URL in Firestore under the user's profile
        await FirebaseFirestore.instance.collection('users').doc(userId).update(
            {
              'photoURL': downloadURL,
            });
      } catch (e) {
        // Log any errors during the upload
        logger.e("Error uploading image: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF5D6C8A), // Blue background
      appBar: AppBar(
        backgroundColor: Colors.grey[600], // Gray AppBar
        title: const Text(
          AppStrings.appName,
          style: TextStyle(color: Colors.black), // Black text
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings'); // Navigate to Settings page
            },
          ),
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.wb_sunny : Icons.nights_stay),
            onPressed: () {
              themeProvider.toggleTheme(); // Toggle the theme
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 100.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _buildHeader(themeProvider),
              const SizedBox(height: 32),
              _buildPointsSection(context, themeProvider),
              const SizedBox(height: 32),
              _buildChallengesContainer(context, themeProvider),
              const SizedBox(height: 32),
              _buildHistoryContainer(context, themeProvider),
              const SizedBox(height: 32),
              _buildTopChallengedFriends(exampleFriends, themeProvider),
              const SizedBox(height: 32),
              _buildFriendsListButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeProvider themeProvider) {
    // Set container and text color based on theme (dark or light)
    final containerColor = themeProvider.isDarkMode ? Colors.black : Colors.white;
    final textColor = themeProvider.isDarkMode ? Colors.white : Colors.black;

    return Container(
      color: containerColor, // Dynamically set container color
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
              color: textColor, // Dynamically set text color
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _pickAndUploadImage,
            child: CircleAvatar(
              radius: 40,
              backgroundColor: themeProvider.isDarkMode
                  ? Colors.grey[700]
                  : Colors.grey[300], // Adjust based on theme
              backgroundImage: _image != null ? FileImage(_image!) : null,
              child: _image == null
                  ? Icon(Icons.add_a_photo, color: textColor, size: 30) // Adjust icon color
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsSection(BuildContext context, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Points Earned',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: pointsEarned / pointsGoal,
              minHeight: 20,
              backgroundColor: themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[300],
              color: const Color(0xFF85C83E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$pointsEarned / $pointsGoal points',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EarnedPointsPage(
                    points: 1000,
                    streakDays: 350,
                    totalChallengesCompleted: 0,
                    pointsEarnedToday: 0,
                    bestDayPoints: 0, userId: '',
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: const Color(0xFF85C83E),
            ),
            child: const Text('View Earned Points'),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengesContainer(BuildContext context, ThemeProvider themeProvider) {
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
            'Challenges',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              setState(() {
                showPreloadedChallenges = !showPreloadedChallenges;
              });
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: const Color(0xFF85C83E),
            ),
            child: Text(showPreloadedChallenges ? 'Hide Preloaded Challenges' : 'Show Preloaded Challenges'),
          ),
          const SizedBox(height: 16),
          if (showPreloadedChallenges) _buildPreloadedChallengesList(themeProvider),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/create_challenge');
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: const Color(0xFF85C83E),
            ),
            child: const Text('Create Challenge'),
          ),
        ],
      ),
    );
  }

  Widget _buildPreloadedChallengesList(ThemeProvider themeProvider) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: preloadedChallenges.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _showChallengeInfo(preloadedChallenges[index]);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16.0),
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode ? Colors.grey[700] : Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF85C83E), width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    preloadedChallenges[index].name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(preloadedChallenges[index].type),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showChallengeInfo(Challenge challenge) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF85C83E),
          title: Text(challenge.name),
          content: Container(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Type: ${challenge.type}\nStart Date: ${challenge.startDate}\nEnd Date: ${challenge.endDate}',
              style: const TextStyle(color: Colors.black),
            ),
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

  Widget _buildHistoryContainer(BuildContext context, ThemeProvider themeProvider) {
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
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'History',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              logger.e("Navigating to history page...");
              Navigator.of(context).pushNamed('/history').catchError((error) {
                logger.e("Error navigating to history page: $error");
                return null;
              });
            },
            child: const Text('View History', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildTopChallengedFriends(List<String> friends, ThemeProvider themeProvider) {
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
                      _showFriendInfo(context, friends[index].split('/').last.split('.').first, friends[index], gamesWon: 25, streakDays: 10, rank: 3);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage(friends[index]),
                        ),
                        const SizedBox(height: 8),
                        Text(friends[index].split('/').last.split('.').first),
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

  void _showFriendInfo(BuildContext context, String friendName, String friendImagePath, {int gamesWon = 0, int streakDays = 0, int rank = 0}) {
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
              Text('Games Won: $gamesWon', style: const TextStyle(color: Colors.black)),
              const SizedBox(height: 5),
              Text('Streak Days: $streakDays', style: const TextStyle(color: Colors.black)),
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

  // Widget to build the workout tracking navigation button
  Widget _buildFriendsListButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, '/friends'); // Navigate to the workout tracking page
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: const Color(0xFF85C83E),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 36.0),
      ),
      child: const Text('Explore friends'),
    );
  }
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
