import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth package
import 'package:firebase_messaging/firebase_messaging.dart'; // Firebase Messaging package
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore package
import 'package:logger/logger.dart'; // Logger for logging messages
import 'package:fitbattles/settings/app_strings.dart'; // Import your strings file

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
      logger.i(AppStrings.foregroundMessageReceived, error: [message.notification?.title]);
      if (message.notification != null) {
        logger.i('Message data: ${message.data}');
      }
      handleMessage(message);
    });

    // Listen for messages when the app is opened from a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      logger.i(AppStrings.backgroundMessageOpened, error: [message.notification?.title]);
      handleMessage(message);
    });

    // Check if the app was opened from a notification
    RemoteMessage? initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      logger.i(AppStrings.appOpenedByNotification, error: [initialMessage.notification?.title]);
      handleMessage(initialMessage);
    }

    // Call the function to set user history data in Firestore
    await _setUserHistory();

    // Call the function to update the leaderboard
    await _updateLeaderboard();
  } catch (e) {
    logger.e(AppStrings.errorSettingUpMessaging, error: [e.toString()]);
  }
}

// Function to handle incoming messages
void handleMessage(RemoteMessage message) {
  logger.i('${AppStrings.handlingMessage} ${message.data}');
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

// Sample functions to fetch actual data (implement these)
Future<int> getPointsWon() async {
  return 150; // Replace with actual logic to fetch points
}

Future<int> getCaloriesLost() async {
  return 1200; // Replace with actual logic to fetch calories lost
}

Future<double> getWaterIntake() async {
  return 2.5; // Replace with actual logic to fetch water intake
}

Future<int> getWorkoutSessions() async {
  return 20; // Replace with actual logic to fetch workout sessions
}

Future<int> getChallengesWon() async {
  return 5; // Replace with actual logic to fetch challenges won
}

Future<int> getChallengesLost() async {
  return 2; // Replace with actual logic to fetch challenges lost
}

Future<int> getChallengesTied() async {
  return 1; // Replace with actual logic to fetch challenges tied
}
