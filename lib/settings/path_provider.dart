import 'dart:io';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

final Logger logger = Logger(); // Initialize your logger

Future<void> getTemporaryDirectoryExample() async {
  try {
    // Get the temporary directory
    final Directory tempDir = await getTemporaryDirectory();

    // Log the path
    logger.d('Temporary directory: ${tempDir.path}');

    // You can now use the path for your needs
  } catch (e) {
    logger.e('Error getting temporary directory: $e');
  }
}
