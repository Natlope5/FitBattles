import 'package:firebase_messaging/firebase_messaging.dart'; // Importing Firebase Messaging for push notifications
import 'package:logger/logger.dart'; // Importing logger for logging messages

final Logger logger = Logger(); // Logger instance for debugging

Future<void> setupFirebaseMessaging() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  try {
    // Request permission for notifications
    NotificationSettings settings = await messaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      logger.i('User granted permission for notifications');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      logger.i('User granted provisional permission for notifications');
    } else {
      logger.w('User declined or has not accepted notification permissions');
      return; // Exit early if permissions are not granted
    }

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      logger.i('Received a foreground message: ${message.notification?.title}');
      if (message.notification != null) {
        logger.i('Message data: ${message.data}'); // Log message data
      }
      // Handle the message as needed
      handleMessage(message);
    });

    // Listen for messages when the app is in the background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      logger.i('Message opened when app is in background: ${message.notification?.title}');
      handleMessage(message); // Handle the notification
    });

    // Handle messages when the app is terminated
    RemoteMessage? initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      logger.i('App was opened by a notification: ${initialMessage.notification?.title}');
      handleMessage(initialMessage); // Handle the notification
    }
  } catch (e) {
    logger.e('Error setting up Firebase Messaging: $e');
  }
}

// Custom method to handle notifications
void handleMessage(RemoteMessage message) {
  // Custom logic for handling the notification
  // For example, navigate to a specific screen based on the message data
  logger.i('Handling message: ${message.data}');
}
