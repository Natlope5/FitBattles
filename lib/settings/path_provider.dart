import 'dart:io';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'app_strings.dart'; // Import the strings file

final Logger logger = Logger(); // Initialize your logger

Future<void> getTemporaryDirectoryExample() async {
  try {
    // Get the temporary directory
    final Directory tempDir = await getTemporaryDirectory();

    // Log the path
    logger.d('${AppStrings.temporaryDirectoryLog}${tempDir.path}');

    // You can now use the path for your needs
  } catch (e) {
    logger.e('${AppStrings.errorGettingTempDir}$e');
  }
}
