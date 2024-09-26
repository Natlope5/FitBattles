import 'package:firebase_messaging/firebase_messaging.dart'; // Importing Firebase Messaging for push notifications
import 'package:flutter/material.dart'; // Importing Flutter Material for UI components
import 'package:logger/logger.dart'; // Importing Logger for logging messages

// Define a GlobalKey for the navigator
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Class to handle notifications using Firebase Cloud Messaging
class NotificationsHandler {
  // Create an instance of FirebaseMessaging
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Create an instance of Logger for logging purposes
  final Logger _logger = Logger();

  // Initialization method for setting up notifications
  Future<void> init() async {
    // Request permissions for iOS notifications
    NotificationSettings settings = await _firebaseMessaging.requestPermission();
    // Log the user's permission status
    _logger.i('User granted permission: ${settings.authorizationStatus}');

    // Get the FCM token for this device
    String? token = await _firebaseMessaging.getToken();
    // Log the token for debugging purposes
    _logger.i('FCM Token: $token');

    // Listen for incoming messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message); // Show notification for incoming message
    });

    // Handle messages when the app is in the background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle notification taps when the app is opened from a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message); // Navigate based on the notification data
    });
  }

  // Static method to handle background messages
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // Log the handling of the background message
    Logger().i('Handling a background message: ${message.messageId}');
    // Optionally show a local notification here (e.g., using flutter_local_notifications)
  }

  // Method to show notifications when messages are received
  void _showNotification(RemoteMessage message) {
    // Display a SnackBar for the notification
    if (navigatorKey.currentContext != null) {
      // Use the ScaffoldMessenger to show a SnackBar
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text(message.notification?.title ?? 'Notification'), // Display the notification title or a default message
          action: SnackBarAction(
            label: 'Dismiss', // Action label for dismissing the notification
            onPressed: () {
              // Optionally handle dismiss action (e.g., logging)
            },
          ),
        ),
      );
    } else {
      // Log a warning if there is no context available to show the notification
      _logger.w('No context available to show notification.');
    }
  }

  // Method to handle notification taps
  void _handleNotificationTap(RemoteMessage message) {
    // Check if the message data contains a route to navigate to
    if (message.data['route'] != null) {
      // Navigate to the specified route using the navigator key
      navigatorKey.currentState?.pushNamed(message.data['route']);
    }
  }
}
