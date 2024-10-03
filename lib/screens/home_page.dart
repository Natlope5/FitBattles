import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:fitbattles/challenges/earned_points_page.dart';

// The HomePage class, which is a StatefulWidget that takes a user ID and email as parameters.
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.uid, required this.email});

  final String uid; // User ID
  final String email; // User email

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _image; // Variable to hold the selected image
  final picker = ImagePicker(); // Instance of ImagePicker to pick images
  String? selectedChallenge; // Variable to hold the selected challenge
  bool showPreloadedChallenges = false; // Flag to show/hide preloaded challenges
  final Logger logger = Logger(); // Logger instance for logging errors

  // Points variables
  int pointsEarned = 500; // Example value for earned points
  int pointsGoal = 1000; // Example goal for points

  // Preloaded challenges that can be displayed to the user
  List<String> preloadedChallenges = [
    '10,000 Steps Challenge',
    '30-Day Fitness Challenge',
    'Weekly Running Challenge',
    'Daily Yoga Challenge',
    'Strength Training Challenge',
    'Hydration Challenge',
    'Weight Loss Challenge',
    'Cycling Challenge',
    'Mindfulness Challenge',
    'Flexibility Challenge',
    'Squats Challenge',
    'Sit-Ups Challenge',
    'Push-Ups Challenge',
  ];

  // Placeholder data for friends
  final List<Map<String, String>> friends = [
    {'name': 'Alice', 'image': 'assets/images/alice.jpg'},
    {'name': 'Bob', 'image': 'assets/images/bob.jpg'},
    {'name': 'Charlie', 'image': 'assets/images/charlie.jpg'},
    {'name': 'Diana', 'image': 'assets/images/diana.jpg'},
    {'name': 'Ethan', 'image': 'assets/images/ethan.jpg'},
    {'name': 'Fiona', 'image': 'assets/images/fiona.jpg'},
    {'name': 'George', 'image': 'assets/images/george.jpg'},
    {'name': 'Hannah', 'image': 'assets/images/hannah.jpg'},
    {'name': 'Ian', 'image': 'assets/images/ian.jpg'},
    {'name': 'Jack', 'image': 'assets/images/jack.jpg'},
  ];

  // Method to pick an image from the gallery and upload it to Firebase
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
    // Build the UI for the HomePage
    return Scaffold(
      backgroundColor: const Color(0xFF5D6C8A), // Background color
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 100.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _buildHeader(),
              // Build the header section
              const SizedBox(height: 32),
              _buildPointsSection(context),
              // Build the points section
              const SizedBox(height: 32),
              _buildChallengesContainer(context),
              // Build the challenges container
              const SizedBox(height: 32),
              _buildHistoryContainer(context),
              // Build the history container
              const SizedBox(height: 32),
              _buildTopChallengedFriends(friends), // Pass the friends list
              // Build the top challenged friends section
              const SizedBox(height: 32),
              Tooltip(
                message: 'View your friends list',
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/friendsList'); // Navigate to the friends list page
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF85C83E),
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                  ),
                  child: const Text('View Friends'), // Button text
                ),
              ),
            ],
          ),
        ),
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
                  ? const Icon(Icons.add_a_photo, color: Colors.black,
                  size: 30) // Placeholder icon
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  // Widget to build the points section
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
          LinearProgressIndicator(
            value: pointsEarned / pointsGoal, // Progress based on earned points
            minHeight: 20,
            backgroundColor: Colors.grey[300],
            color: const Color(0xFF85C83E),
          ),
          const SizedBox(height: 8),
          Text(
            '$pointsEarned / $pointsGoal points',
            // Display earned points and goal
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Navigate to the EarnedPointsPage when button is pressed
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                  const EarnedPointsPage(
                      points: 1000, streakDays: 350), // Example parameters
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF85C83E),
            ),
            child: const Text('View Earned Points'), // Button text
          ),
        ],
      ),
    );
  }

  // Widget to build the challenges container
  Widget _buildChallengesContainer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      width: MediaQuery.of(context).size.width * 0.9, // Responsive width
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Challenges', // Section title
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Workout tracking button
          _buildWorkoutTrackingButton(context),

          // Button to show/hide preloaded challenges
          ElevatedButton(
            onPressed: () {
              // Toggle visibility of preloaded challenges when button is pressed
              setState(() {
                showPreloadedChallenges = !showPreloadedChallenges;
              });
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF85C83E),
            ),
            child: Text(showPreloadedChallenges ? 'Hide Preloaded Challenges' : 'Show Preloaded Challenges'), // Toggle button text
          ),

          const SizedBox(height: 16),

          // Conditionally display preloaded challenges list
          if (showPreloadedChallenges) _buildPreloadedChallengesList(),

          const SizedBox(height: 16),

          // Button to create a new challenge
          ElevatedButton(
            onPressed: () {
              // Navigate to the create new challenge page
              Navigator.pushNamed(context, '/create_challenge'); // Update route accordingly
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF85C83E),
            ),
            child: const Text('Create a New Challenge'), // Button text
          ),
        ],
      ),
    );
  }

  // Widget to build the list of preloaded challenges
  Widget _buildPreloadedChallengesList() {
    return ListView.builder(
      shrinkWrap: true,
      // Prevents scrolling issues
      physics: const NeverScrollableScrollPhysics(),
      // Disable scrolling for this ListView
      itemCount: preloadedChallenges.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(preloadedChallenges[index]), // Display each challenge
          onTap: () {
            // Set the selected challenge when tapped
            setState(() {
              selectedChallenge = preloadedChallenges[index];
            });
          },
        );
      },
    );
  }

  Widget _buildHistoryContainer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      width: MediaQuery.of(context).size.width * 0.9, // Responsive width
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My History', // Section title
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // Navigate to the history page when button is pressed
              Navigator.pushNamed(context, '/my_history');
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF85C83E),
            ),
            child: const Text('View My History'), // Button text
          ),
        ],
      ),
    );
  }


// Widget to build the top challenged friends section
  Widget _buildTopChallengedFriends(List<Map<String, dynamic>> friends) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      width: MediaQuery
          .of(context)
          .size
          .width * 0.9, // Responsive width
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Challenged Friends', // Section title
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          // Display friends in a horizontal list view
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: friends.length,
              itemBuilder: (context, index) {
                return buildFriendCard(
                    friends[index]); // Build each friend's card
              },
            ),
          ),
        ],
      ),
    );
  }

// Widget to build each friend's card
  Widget buildFriendCard(Map<String, dynamic> friend) {
    return GestureDetector(
      onTap: () {
        showFriendInfoDialog(friend); // Show the info dialog when tapped
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Column(
          children: [
            ClipOval(
              child: Image.asset(
                friend['image']!, // Friend's image
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // If there's an error loading the image, show the placeholder
                  return Image.asset(
                    'assets/placeholder_avatar.png',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            const SizedBox(height: 4),
            Text(friend['name']!), // Friend's name
          ],
        ),
      ),
    );
  }

// Function to show the friend info dialog
  void showFriendInfoDialog(Map<String, dynamic> friend) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(friend['name']!), // Friend's name as title
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipOval(
                child: Image.asset(
                  friend['image']!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/placeholder_avatar.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Text('Challenges Won: ${friend['challengesWon'] ?? 0}'),
              Text('Total Challenges: ${friend['totalChallenges'] ?? 0}'),
              Text('Points Earned: ${friend['points'] ?? 0}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

// Example list of friends
  final List<Map<String, dynamic>> exampleFriends = [
    {
      'name': 'John Doe',
      'image': 'assets/friend_image.png',
      'challengesWon': 5,
      'totalChallenges': 10,
      'points': 150,
    },
    {
      'name': 'Jane Smith',
      'image': 'assets/friend_image2.png',
      'challengesWon': 8,
      'totalChallenges': 12,
      'points': 200,
    },
    // Add more friends as needed
  ];

// Usage example
  Widget buildFriendsSection() {
    return _buildTopChallengedFriends(
        exampleFriends); // Use the renamed variable here
  }

  // Widget to build the workout tracking navigation button
  Widget _buildWorkoutTrackingButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, '/workoutTracking'); // Navigate to the workout tracking page
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF85C83E), // Use the theme color
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 32.0),
      ),
      child: const Text('Start Workout Tracking'), // Button text
    );
  }
}