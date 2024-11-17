import 'package:flutter/material.dart'; // Required for Flutter widgets
import 'package:logger/logger.dart'; // For logging
import 'package:permission_handler/permission_handler.dart'; // For managing permissions
import 'ui/app_strings.dart'; // Import your strings file

final Logger logger = Logger(); // Initialize the logger

class PermissionService {
  /// Requests notification permission and handles the dialog if denied.
  Future<PermissionStatus> requestNotificationPermission(VoidCallback onShowSettingsDialog) async {
    final status = await Permission.notification.request();

    // Log the status of the permission request
    logger.i("Notification permission status: ${status.toString()}");

    if (status.isDenied || status.isPermanentlyDenied) {
      // If permission is denied, call the callback to show the settings dialog
      onShowSettingsDialog();
    }

    return status; // Return the status for further processing
  }
}

/// Shows a dialog to guide the user to the app settings to enable permissions.
void showGuideToSettingsDialog(BuildContext context) {
  logger.i(AppStrings.openingAppSettings); // Log the action of opening settings

  // Show a dialog to confirm before navigating to settings
  showDialog<void>(
    context: context,
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
              openAppSettings(); // This opens the app settings
            },
            child: Text('Open Settings'), // Open Settings button
          ),
        ],
      );
    },
  );
}
