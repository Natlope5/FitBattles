import 'package:fitbattles/settings/permissions_handler.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions(BuildContext context) async {
  // Request notification permission
  PermissionStatus status = await Permission.notification.request();
  if (!context.mounted) return; // Ensure context is still valid
  if (status.isDenied || status.isPermanentlyDenied) {
    showGuideToSettingsDialog(context);
  }

  // Request other permissions as needed
  PermissionStatus locationStatus = await Permission.location.request();
  if (!context.mounted) return; // Ensure context is still valid
  if (locationStatus.isDenied || locationStatus.isPermanentlyDenied) {
    showGuideToSettingsDialog(context);
  }
}
