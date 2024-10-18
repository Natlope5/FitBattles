import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../firebase/firebase_messaging.dart';
import 'app_strings.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  CameraPageState createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool isRecording = false;
  List<CameraDescription>? cameras;

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndInitializeCamera(); // Request permissions and initialize camera
  }

  Future<void> _requestPermissionsAndInitializeCamera() async {
    // Request camera and microphone permissions
    var cameraStatus = await Permission.camera.status;
    var microphoneStatus = await Permission.microphone.status;

    if (cameraStatus.isDenied) {
      cameraStatus = await Permission.camera.request();
    }

    if (microphoneStatus.isDenied) {
      microphoneStatus = await Permission.microphone.request();
    }

    if (cameraStatus.isGranted && microphoneStatus.isGranted) {
      await _initializeCamera(); // Call method to initialize the camera
    } else {
      // Handle the case where permissions are denied
      if (mounted) {
        // Check if the widget is still mounted before showing the SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera and microphone permissions are required to use this feature.')),
        );
      }
    }
  }


  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras(); // Get available cameras

      if (cameras != null && cameras!.isNotEmpty) {
        _controller = CameraController(
          cameras![0], // Use the first camera available
          ResolutionPreset.high,
        );
        _initializeControllerFuture = _controller.initialize();

        if (mounted) {
          // Check if the widget is still in the tree before calling setState
          setState(() {}); // Trigger a rebuild after initialization
        }
      } else {
        if (mounted) {
          // Check if the widget is still in the tree before showing a SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No cameras found on this device.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // Handle the error and notify the user, if the widget is still mounted
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing camera: $e')),
        );
      }
    }
  }


  @override
  void dispose() {
    _controller.dispose(); // Dispose of the controller when done
    super.dispose();
  }

  Future<void> _recordVideo() async {
    try {
      await _initializeControllerFuture; // Ensure the camera is initialized
      final String filePath = '${(await getTemporaryDirectory()).path}/video_${DateTime.now()}.mp4'; // Generate file path

      if (!isRecording) {
        await _controller.startVideoRecording();
        setState(() {
          isRecording = true;
        });
      } else {
        await _controller.stopVideoRecording();
        setState(() {
          isRecording = false;
        });
        _showRecordingSnackbar(filePath); // Show recording notification
      }
    } catch (e) {
      // Handle any errors
      logger.d(e); // Use logger or another debug tool in production
    }
  }

  void _showRecordingSnackbar(String filePath) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Video saved to: $filePath')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.cameraTitle)), // Use cameraTitle from strings
      body: cameras == null
          ? const Center(child: CircularProgressIndicator()) // Show loading spinner until cameras are initialized
          : FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: CameraPreview(_controller), // Display camera preview
                ),
                ElevatedButton(
                  onPressed: _recordVideo,
                  child: Text(isRecording ? 'Stop Recording' : AppStrings.recordVideo), // Update button text
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator()); // Show loading spinner while camera initializes
          }
        },
      ),
    );
  }
}
