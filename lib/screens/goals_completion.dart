import 'package:fitbattles/settings/app_colors.dart';
import 'package:fitbattles/settings/app_dimens.dart';
import 'package:fitbattles/settings/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// A page that allows users to send a notification once they complete a fitness goal.
/// It sends a push notification via Firebase Cloud Messaging (FCM) using the user's token.
class GoalCompletionPage extends StatefulWidget {
  /// The FCM token of the user, used to target the notification.
  final String userToken;

  const GoalCompletionPage({super.key, required this.userToken});

  @override
  GoalCompletionPageState createState() => GoalCompletionPageState();
}

class GoalCompletionPageState extends State<GoalCompletionPage> {
  bool _isSending = false; // Track if a notification is being sent
  bool _isError = false;   // Track if an error occurred
  String _errorMessage = ''; // Store the error message if any

  /// Sends a notification to the user when they complete a fitness goal.
  ///
  /// This function makes an HTTP POST request to the server, including the FCM
  /// token and other notification details in the request body. If the request is
  /// successful, a success message is displayed; otherwise, an error message is shown.
  Future<void> sendNotification() async {
    setState(() {
      _isSending = true;   // Show loading state
      _isError = false;    // Reset error state before sending
      _errorMessage = '';  // Clear previous error messages
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.0.30:3000/sendNotification'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': AppStrings.goalCompletionTitle,
          'body': 'You have completed your fitness goal! Keep pushing forward!',
          'payload': 'goal_completed',
          'route': '/goalDetails', // Navigate to goal details in the app
          'token': widget.userToken, // Use the user's FCM token
        }),
      );

      // Check if the widget is still mounted before showing SnackBar
      if (!mounted) return; // Early return if widget is not mounted

      if (response.statusCode == 200) {
        // Notification sent successfully, show success SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.notificationSuccess)),
        );
      } else {
        // If there's a server-side error, display the error message
        setState(() {
          _isError = true;
          _errorMessage = '${AppStrings.notificationFailure} - ${response.body}';
        });
      }
    } catch (e) {
      // Handle any network errors or exceptions
      if (mounted) {
        setState(() {
          _isError = true;
          _errorMessage = '${AppStrings.errorOccurred}: $e';
        });
      }
    } finally {
      // Reset the loading state
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.goalCompletionTitle),
        backgroundColor: AppColors.primary, // Use predefined color
      ),
      body: Padding(
        padding: EdgeInsets.all(AppDimens.pagePadding), // Use padding resource
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Message displayed when an error occurs
              if (_isError)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Show a loading indicator while sending the notification
              if (_isSending)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: sendNotification, // Send notification on button press
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonColor, // Use button color resource
                    padding: EdgeInsets.all(AppDimens.buttonPadding), // Use button padding resource
                  ),
                  child: const Text(AppStrings.sendNotificationButton), // Use string resource for button text
                ),

              const SizedBox(height: 20), // Add some space between button and retry message

              // Option to retry sending notification if an error occurred
              if (_isError)
                TextButton(
                  onPressed: sendNotification, // Retry sending the notification
                  child: const Text(AppStrings.retryButton),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
