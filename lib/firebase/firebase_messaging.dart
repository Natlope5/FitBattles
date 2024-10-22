import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth package
import 'package:firebase_messaging/firebase_messaging.dart'; // Firebase Messaging package
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore package
import 'package:logger/logger.dart'; // Logger for logging messages
import 'package:fitbattles/settings/app_strings.dart'; // Import your strings file
import 'package:http/http.dart' as http;

final Logger logger = Logger();

// Function to set up Firebase messaging
Future<void> setupFirebaseMessaging() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  try {
    // Request permission to show notifications
    NotificationSettings settings = await messaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      logger.i(AppStrings.notificationPermissionGranted);
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      logger.i(AppStrings.notificationPermissionProvisional);
    } else {
      logger.w(AppStrings.notificationPermissionDenied);
      return; // Exit if permission denied
    }

    // Listen for messages while the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      logger.i('${AppStrings.foregroundMessageReceived}: ${message.notification?.title}');
      if (message.notification != null) {
        logger.i('Message data: ${message.data}');
      }
      handleMessage(message);
    });

    // Listen for messages when the app is opened from a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      logger.i('${AppStrings.backgroundMessageOpened}: ${message.notification?.title}');
      handleMessage(message);
    });

    // Check if the app was opened from a notification
    RemoteMessage? initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      logger.i('${AppStrings.appOpenedByNotification}: ${initialMessage.notification?.title}');
      handleMessage(initialMessage);
    }

    // Call the function to set user history data in Firestore
    await _setUserHistory();

    // Call the function to update the leaderboard
    await _updateLeaderboard();
  } catch (e) {
    logger.e('${AppStrings.errorSettingUpMessaging}: $e');
  }
}

// Function to handle incoming messages
void handleMessage(RemoteMessage message) {
  logger.i('${AppStrings.handlingMessage}: ${message.data}');
}

// Function to set user history in Firestore
Future<void> _setUserHistory() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Retrieve actual data from your app's state
  int pointsWon = await getPointsWon();
  int caloriesLost = await getCaloriesLost();
  double waterIntake = await getWaterIntake();
  int workoutSessions = await getWorkoutSessions();
  int challengesWon = await getChallengesWon();
  int challengesLost = await getChallengesLost();
  int challengesTied = await getChallengesTied();

  // Get the currently authenticated user
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    String userId = user.uid;

    try {
      // Save dynamic data in Firestore
      await firestore.collection('users').doc(userId).set({
        'history': {
          'pointsWon': pointsWon,
          'caloriesLost': caloriesLost,
          'waterIntake': waterIntake,
          'workoutSessions': workoutSessions,
          'challengesWon': challengesWon,
          'challengesLost': challengesLost,
          'challengesTied': challengesTied,
        },
      }, SetOptions(merge: true)); // Use merge to update without overwriting other fields

      logger.i('User history data successfully set in Firestore');
    } catch (e) {
      logger.e('Error setting user history data: $e');
    }
  } else {
    logger.w('No user is currently signed in.');
  }
}

// Function to update the leaderboard in Firestore
Future<void> _updateLeaderboard() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Get the currently authenticated user
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    String userId = user.uid;

    try {
      // Retrieve the user's points (or any metric you want to base the leaderboard on)
      int userPoints = await getPointsWon();

      // Update the leaderboard in Firestore
      await firestore.collection('leaderboard').doc(userId).set({
        'userId': userId,
        'points': userPoints,
      }, SetOptions(merge: true)); // Use merge to prevent overwriting

      logger.i('Leaderboard data successfully updated in Firestore');
    } catch (e) {
      logger.e('Error updating leaderboard data: $e');
    }
  } else {
    logger.w('No user is currently signed in.');
  }
}

// Functions to retrieve app-specific data for user history
Future<int> getPointsWon() async {
  try {
    final snapshot = await FirebaseFirestore.instance.collection('users').doc('user_id').get(); // Replace 'user_id' with the actual user ID
    if (snapshot.exists) {
      return snapshot.data()?['points'] ?? 0; // Fetch points from the user's document
    }
  } catch (e) {
    // Handle error (you can log the error or return a default value)
    logger.e("Error fetching points: $e");
  }
  return 0; // Default value if fetching fails
}

Future<List<String>> getAwards() async {
  try {
    final snapshot = await FirebaseFirestore.instance.collection('users').doc('user_id').get(); // Replace 'user_id' with the actual user ID
    if (snapshot.exists) {
      return List<String>.from(snapshot.data()?['awards'] ?? []); // Fetch awards list from the user's document
    }
  } catch (e) {
    // Handle error
    logger.i("Error fetching awards: $e");
  }
  return []; // Return an empty list if fetching fails
}

Future<int> getCaloriesLost() async {
  return 1200; // Replace with actual logic to fetch calories lost
}

Future<double> getWaterIntake() async {
  try {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('history')
        .doc('water_intake')
        .get();

    if (snapshot.exists) {
      return (snapshot.data() as Map<String, dynamic>)['intake']?.toDouble() ?? 0.0;
    } else {
      return 0.0; // Default if no intake is recorded
    }
  } catch (e) {
    // Handle error (e.g., log error)
    logger.d("Error fetching water intake: $e");
    return 0.0; // Return default on error
  }
}

// Fetch the total workout sessions for the user from Firestore
Future<int> getWorkoutSessions() async {
  try {
    // Get the currently authenticated user
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Fetch workout sessions from the user's history document
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (snapshot.exists) {
        // Cast the snapshot data to a Map<String, dynamic>
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        return data['history']['workoutSessions'] ?? 0;
      }
    }
  } catch (e) {
    logger.e("Error fetching workout sessions: $e");
  }
  return 0; // Default if fetching fails
}


// Fetch the total challenges won by the user from Firestore
Future<int> getChallengesWon() async {
  try {
    // Get the currently authenticated user
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Fetch challenges won from the user's history document
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (snapshot.exists) {
        // Cast the snapshot data to a Map<String, dynamic>
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        return data['history']['challengesWon'] ?? 0;
      }
    }
  } catch (e) {
    logger.e("Error fetching challenges won: $e");
  }
  return 0; // Default if fetching fails
}



// Fetch the total challenges lost by the user from Firestore
Future<int> getChallengesLost() async {
  try {
    // Get the currently authenticated user
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Fetch challenges lost from the user's history document
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (snapshot.exists) {
        // Cast the snapshot data to a Map<String, dynamic>
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        return data['history']['challengesLost'] ?? 0;
      }
    }
  } catch (e) {
    logger.e("Error fetching challenges lost: $e");
  }
  return 0; // Default if fetching fails
}

// Fetch the total challenges tied by the user from Firestore
Future<int> getChallengesTied() async {
  try {
    // Get the currently authenticated user
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Fetch challenges tied from the user's history document
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (snapshot.exists) {
        // Cast the snapshot data to a Map<String, dynamic>
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        return data['history']['challengesTied'] ?? 0;
      }
    }
  } catch (e) {
    logger.e("Error fetching challenges tied: $e");
  }
  return 0; // Default if fetching fails
}
Future<void> startChallenge(String challengeId, String opponentDeviceToken) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      logger.e('User not signed in.');
      return;
    }

    String userId = user.uid;

    // Save the challenge in Firestore
    await firestore.collection('startedChallenges').add({
      'challengeId': challengeId,
      'userId': userId,
      'startDate': Timestamp.now(),
    });

    logger.i('Challenge started: $challengeId for user: $userId');

    // Notify opponent (if device token is provided)
    if (opponentDeviceToken.isNotEmpty) {
      await sendNotification(opponentDeviceToken, challengeId);
    } else {
      logger.w('Opponent device token is empty. Cannot send notification.');
    }
  } catch (e) {
    logger.e('Error starting challenge: $e');
  }
}

// Function to send a notification to the opponent
Future<void> sendNotification(String deviceToken, String challengeId) async {
  final url = 'https://fcm.googleapis.com/fcm/send';
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'key=YOUR_SERVER_KEY',  // Replace with your FCM server key
  };
  final body = jsonEncode({
    'to': deviceToken,
    'notification': {
      'title': 'New Challenge!',
      'body': 'You have been challenged in challenge $challengeId.',
    },
    'data': {
      'challengeId': challengeId,
    },
  });

  try {
    final response = await http.post(Uri.parse(url), headers: headers, body: body);
    if (response.statusCode == 200) {
      logger.i('FCM notification sent successfully.');
    } else {
      logger.e('Failed to send FCM notification: ${response.body}');
    }
  } catch (e) {
    logger.e('Error sending notification: $e');
  }
}