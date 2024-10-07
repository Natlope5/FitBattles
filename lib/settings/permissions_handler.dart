import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

final Logger logger = Logger(); // Initialize your logger

Future<void> requestNotificationPermission() async {
  // Requesting the notification permission
  final status = await Permission.notification.request();

  if (status.isGranted) {
    // Permission granted
    logger.d('Notification permission granted');
  } else if (status.isDenied) {
    // Permission denied
    logger.d('Notification permission denied');
  } else if (status.isPermanentlyDenied) {
    // The permission is permanently denied
    logger.w('Notification permission permanently denied');
    // Optionally, guide the user to settings to enable it
    await _guideUserToSettings();
  } else if (status.isRestricted) {
    // The permission is restricted
    logger.w('Notification permission is restricted');
  } else {
    logger.e('Unknown permission status: ${status.toString()}');
  }
}

Future<void> _guideUserToSettings() async {
  // Optionally, provide user guidance
  logger.i('Opening app settings for notification permission...');
  await openAppSettings(); // This opens the app settings
}
