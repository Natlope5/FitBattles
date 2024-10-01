import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

final Logger logger = Logger(); // Create a logger instance

Future<void> sendGoalCompletionNotification(String goalName, String userDeviceToken) async {
  const String serverToken = 'YOUR_SERVER_KEY'; // Replace with your server key
  const String fcmUrl = 'https://fcm.googleapis.com/fcm/send';

  final message = {
    'to': userDeviceToken,
    'notification': {
      'title': 'Goal Completed!',
      'body': "Congratulations! You've completed your goal: $goalName.",
    },
    'data': {
      'goal': goalName,
    },
  };

  try {
    final response = await http.post(
      Uri.parse(fcmUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      logger.i('Notification sent successfully!');
    } else {
      logger.e('Failed to send notification: ${response.body}');
    }
  } catch (e) {
    logger.e('Error sending notification: $e');
  }
}
