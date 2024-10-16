import 'package:flutter/material.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger(); // Initialize the logger

class ExactAlarmPermissionManager {
  static const platform = MethodChannel('com.example.fitbattles/exact_alarm');

  /// Checks if the "Schedule Exact Alarms" permission is granted.
  Future<bool> isPermissionGranted() async {
    try {
      // Invokes the method to check for the exact alarm permission
      final bool result = await platform.invokeMethod('checkExactAlarmPermission');
      return result;
    } on PlatformException catch (e) {
      logger.d("Error checking exact alarm permission: $e");
      return false; // Return false if there was an error
    }
  }

  /// Displays a dialog to request the "Schedule Exact Alarms" permission.
  void requestPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enable Exact Alarm Permission'),
          content: Text(
            'This app requires the "Schedule Exact Alarms" permission to send accurate notifications for challenges and activities.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                _openSettings(); // Open settings to allow the user to grant permission
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Go to Settings'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close the dialog without action
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  /// Opens the settings screen for granting the "Schedule Exact Alarms" permission.
  void _openSettings() {
    final AndroidIntent intent = AndroidIntent(
      action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
    );
    intent.launch(); // Launch the intent to open settings
  }
}
