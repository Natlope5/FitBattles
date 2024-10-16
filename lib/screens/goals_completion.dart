import 'package:fitbattles/settings/app_colors.dart';
import 'package:fitbattles/settings/app_dimens.dart';
import 'package:fitbattles/settings/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class GoalCompletionPage extends StatelessWidget {
  final String userToken; // This should be the user's FCM token

  const GoalCompletionPage({super.key, required this.userToken});

  Future<void> sendNotification(BuildContext context) async {
    // Use a local variable to store the ScaffoldMessenger
    final messenger = ScaffoldMessenger.of(context);

    try {
      final response = await http.post(
        Uri.parse('http://10.0.0.30:3000/sendNotification'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': AppStrings.goalCompletionTitle,
          'body': 'You have completed your fitness goal!',
          'payload': 'goal_completed',
          'route': '/goalDetails',
          'token': userToken,
        }),
      );

      if (response.statusCode == 200) {
        // Show success message
        messenger.showSnackBar(
          SnackBar(content: Text(AppStrings.notificationSuccess)),
        );
      } else {
        // Show error message
        messenger.showSnackBar(
          SnackBar(content: Text('${AppStrings.notificationFailure}${response.body}')),
        );
      }
    } catch (e) {
      // Handle any exceptions
      messenger.showSnackBar(
        SnackBar(content: Text('${AppStrings.errorOccurred}$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.goalCompletionTitle),
        backgroundColor: AppColors.primary, // Use color resource
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => sendNotification(context), // Pass context here
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonColor, // Use color resource
            padding: EdgeInsets.all(AppDimens.buttonPadding), // Use dimension resource
          ),
          child: const Text(AppStrings.sendNotificationButton), // Use string resource
        ),
      ),
    );
  }
}
