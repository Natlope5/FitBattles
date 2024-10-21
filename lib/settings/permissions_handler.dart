import 'package:flutter/material.dart';
import 'package:logger/logger.dart'; // For logging
import 'package:permission_handler/permission_handler.dart'; // For managing permissions
import 'app_strings.dart'; // Import your strings file

final Logger logger = Logger(); // Initialize the logger

class PermissionService {
  /// Requests notification permission and handles the result with a callback.
  Future<PermissionStatus> requestNotificationPermission(Function onPermissionDenied) async {
    try {
      final status = await Permission.notification.request();

      // Log the status of the permission request
      logger.i("Notification permission status: ${status.toString()}");

      // Check if permission is denied and call the callback
      if (status.isDenied || status.isPermanentlyDenied) {
        onPermissionDenied(); // Call the callback to handle the denial
      }

      return status; // Return the status for further processing
    } catch (e) {
      logger.e("Error requesting notification permission: $e");
      return PermissionStatus.denied; // Return a denied status on error
    }
  }
}

/// Shows a dialog to guide the user to the app settings to enable permissions.
void showGuideToSettingsDialog(Function openSettings, dynamic context) {
  logger.i(AppStrings.openingAppSettings); // Log the action of opening settings

  // Show a dialog to confirm before navigating to settings
  showDialog<void>(
    context: context, // You can pass context from where this function is called
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Permission Required'), // Dialog title
        content: Text('This app requires notification permission to function properly. Would you like to open the settings?'), // Dialog content
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // User rejected
            child: Text('Cancel'), // Cancel button
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              openSettings(); // This opens the app settings
            },
            child: Text('Open Settings'), // Open Settings button
          ),
        ],
      );
    },
  );
}
