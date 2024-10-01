import 'dart:convert'; // Importing for JSON encoding/decoding
import 'package:http/http.dart' as http; // Importing HTTP package for network requests
import 'package:logger/logger.dart'; // Importing logger for logging messages

final Logger logger = Logger(); // Create a logger instance

// Sends a notification to a user's device when they complete a goal
Future<void> sendGoalCompletionNotification(String goalName, String userDeviceToken) async {
  const String serverToken = 'YOUR_SERVER_KEY'; // Replace with your server key
  const String fcmUrl = 'https://fcm.googleapis.com/fcm/send'; // FCM endpoint

  // Constructing the message payload
  final message = {
    'to': userDeviceToken, // Target device token
    'notification': {
      'title': 'Goal Completed!', // Notification title
      'body': "Congratulations! You've completed your goal: $goalName.", // Notification body
    },
    'data': {
      'goal': goalName, // Additional data sent with the notification
    },
  };

  try {
    // Sending the HTTP POST request to FCM
    final response = await http.post(
      Uri.parse(fcmUrl), // Parse the FCM URL
      headers: {
        'Content-Type': 'application/json', // Content type for JSON
        'Authorization': 'key=$serverToken', // Authorization header with server key
      },
      body: jsonEncode(message), // Encode message to JSON
    );

    // Checking the response status code
    if (response.statusCode == 200) {
      logger.i('Notification sent successfully!'); // Log success message
    } else {
      logger.e('Failed to send notification: ${response.body}'); // Log error with response body
    }
  } catch (e) {
    logger.e('Error sending notification: $e'); // Log any errors that occur
  }
}
