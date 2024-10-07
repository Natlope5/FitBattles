import 'package:fitbattles/challenges/challenge.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:fitbattles/challenges/earned_points_page.dart';

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
    Challenge(
      name: '10,000 Steps Challenge',
      type: 'Fitness',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 7)),
      participants: [],
    ),
    Challenge(
      name: 'Running Challenge',
      type: 'Fitness',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 7)),
      participants: [],
    ),
    Challenge(
      name: '30 Days Fit Challenge',
      type: 'Fitness',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 30)),
      participants: [],
    ),
    Challenge(
      name: 'SitUp Challenge',
      type: 'Fitness',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 7)),
      participants: [],
    ),
    Challenge(
      name: '100 Squat Challenge',
      type: 'Fitness',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 30)),
      participants: [],
    ),
  ];



  Future<void> _pickAndUploadImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path); // Store the selected image
        });
        logger.d('Image picked: ${pickedFile.path}');
      } else {
        logger.w('No image selected.');
      }
    } catch (e) {
      logger.e('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5D6C8A), // Background color
      appBar: AppBar(
        title: const Text('Home'),
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
              _buildHeader(),
              const SizedBox(height: 32),
              _buildPointsSection(context),
              const SizedBox(height: 32),
              _buildChallengesContainer(context),
              const SizedBox(height: 32),
              _buildHistoryContainer(context),
              const SizedBox(height: 32),
              // Assuming exampleFriends is defined somewhere
              _buildTopChallengedFriends(exampleFriends),
              const SizedBox(height: 32),
              _viewFriendsButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _viewFriendsButton(BuildContext context) {
    return Tooltip(
      message: 'View your friends list',
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/friendsList');
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: const Color(0xFF85C83E),
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
        ),
        child: const Text('View Friends'),
      ),
    );
  }

  // Widget to build the header section
  Widget _buildHeader() {
    return Container(
      color: Colors.grey[600],
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'FitBattles', // App title
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _pickAndUploadImage,
            // Call method to pick and upload image when tapped
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[300],
              backgroundImage: _image != null ? FileImage(_image!) : null,
              // Display selected image
              child: _image == null
                  ? const Icon(Icons.add_a_photo, color: Colors.black, size: 30) // Placeholder icon
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Points Earned', // Section title
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10), // Rounded corners for the progress bar
            child: LinearProgressIndicator(
              value: pointsEarned / pointsGoal, // Progress based on earned points
              minHeight: 20,
              backgroundColor: Colors.grey[300],
              color: const Color(0xFF85C83E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$pointsEarned / $pointsGoal points', // Display earned points and goal
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Navigate to the EarnedPointsPage when button is pressed
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EarnedPointsPage(
                    points: 1000,
                    streakDays: 350,
                    totalChallengesCompleted: 0,
                    pointsEarnedToday: 0,
                    bestDayPoints: 0,
                  ), // Example parameters
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: const Color(0xFF85C83E),
            ),
            child: const Text('View Earned Points'), // Button text
          ),
        ],
      ),
    );
  }

  Widget _buildChallengesContainer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
            child: Text(showPreloadedChallenges
                ? 'Hide Preloaded Challenges'
                : 'Show Preloaded Challenges'),
          ),
          const SizedBox(height: 16),
          if (showPreloadedChallenges) _buildPreloadedChallengesList(),
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

  Widget _buildPreloadedChallengesList() {
    return SizedBox(
      height: 100, // Fixed height for horizontal scrolling
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: preloadedChallenges.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Show challenge info when tapped
              _showChallengeInfo(preloadedChallenges[index]);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16.0),
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
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
          backgroundColor: const Color(0xFF85C83E), // Set background color to green
          title: Text(challenge.name),
          content: Container(
            // Optional: Add padding to the content
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Type: ${challenge.type}\nStart Date: ${challenge.startDate}\nEnd Date: ${challenge.endDate}',
              style: const TextStyle(color: Colors.black), // Change text color to improve visibility
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close', style: TextStyle(color: Colors.black)), // Adjust text color if needed
            ),
          ],
        );
      },
    );
  }



  Widget _buildHistoryContainer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(128), // Using withAlpha for shadow color
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
              logger.e("Navigating to history page..."); // Debugging log

              // Navigate to the history page
              Navigator.of(context).pushNamed('/history').catchError((error) {
                logger.e("Error navigating to history page: $error");
                // Return a default value to satisfy the return type requirement
                return null; // or some default value or action
              });
            },
            child: const Text('View History', style: TextStyle(color: Colors.black)),

          ),

        ],
      ),
    );
  }

  Widget _buildTopChallengedFriends(List<String> friends) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
                      // Pass the required arguments: context, friendName, and friendImagePath
                      _showFriendInfo(
                        context,
                        friends[index].split('/').last.split('.').first, // Friend's name
                        friends[index], // Friend's image path
                        gamesWon: 25, // Sample data, can be dynamic
                        streakDays: 10, // Sample data, can be dynamic
                        rank: 3, // Sample data, can be dynamic
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage(friends[index]), // Friend image from assets
                        ),
                        const SizedBox(height: 8),
                        Text(friends[index].split('/').last.split('.').first), // Friend's name
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
  void _showFriendInfo(BuildContext context, String friendName, String friendImagePath, {
    int gamesWon = 0,
    int streakDays = 0,
    int rank = 0,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF85C83E), // Set background color to green
          title: Text(friendName, style: const TextStyle(color: Colors.black)), // Change title color for visibility
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(friendImagePath), // Display friend image
              const SizedBox(height: 10),
              Text('Games Won: $gamesWon', style: const TextStyle(color: Colors.black)), // Show number of games won
              const SizedBox(height: 5),
              Text('Streak Days: $streakDays', style: const TextStyle(color: Colors.black)), // Show streak count
              const SizedBox(height: 5),
              Text('Rank: $rank', style: const TextStyle(color: Colors.black)), // Show rank
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Close', style: TextStyle(color: Colors.black)), // Adjust text color if needed
            ),
          ],
        );
      },
    );
  }

  final List <String> exampleFriends = [
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
}

