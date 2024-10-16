import 'dart:io';

import 'package:camera/camera.dart';
import 'package:fitbattles/settings/app_colors.dart';
import 'package:fitbattles/settings/app_dimens.dart';
import 'package:fitbattles/settings/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

class CreateChallengePage extends StatefulWidget {
  const CreateChallengePage({super.key, required List<CameraDescription> cameras, required List friends, required String friend});

  @override
  CreateChallengePageState createState() => CreateChallengePageState();
}

class CreateChallengePageState extends State<CreateChallengePage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController challengeNameController = TextEditingController();
  final TextEditingController challengeTypeController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  String? videoPath; // Store the path of the selected video
  VideoPlayerController? videoController;
  String? statusMessage;
  List<String> selectedParticipants = [];
  List<String> participants = ['Participant 1', 'Participant 2', 'Participant 3'];

  @override
  void dispose() {
    challengeNameController.dispose();
    challengeTypeController.dispose();
    videoController?.dispose();
    super.dispose();
  }

  Future<void> selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != (isStartDate ? startDate : endDate)) {
      setState(() {
        if (isStartDate) {
          startDate = pickedDate;
        } else {
          endDate = pickedDate;
        }
      });
    }
  }

  Widget _buildTextInput(TextEditingController controller, String label, String errorMsg) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.accentColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.accentColor, width: 2.0),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return errorMsg;
        }
        return null;
      },
    );
  }

  Widget _buildParticipantDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: AppStrings.participants,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.accentColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.accentColor, width: 2.0),
        ),
      ),
      items: participants.map((String participant) {
        return DropdownMenuItem<String>(
          value: participant,
          child: Text(participant),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          if (newValue != null && !selectedParticipants.contains(newValue)) {
            selectedParticipants.add(newValue);
          }
        });
      },
    );
  }

  Widget _buildSelectedParticipantsChips() {
    return Wrap(
      spacing: 8.0,
      children: selectedParticipants.map((participant) {
        return Chip(
          label: Text(participant),
          onDeleted: () {
            setState(() {
              selectedParticipants.remove(participant);
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildDateRow(String label, DateTime? date, VoidCallback onPressed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.white)),
        ElevatedButton(
          onPressed: onPressed,
          child: Text(date != null ? DateFormat('yMMMd').format(date) : 'Select date'),
        ),
      ],
    );
  }

  Future<void> pickVideoFromCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    // Perform navigation with a separate function
    final path = await _navigateToCamera(firstCamera);

    // Check if the returned path is not null
    if (path != null) {
      _handleVideoPath(path);
    }
  }

// Method to navigate to the CameraPage
  Future<String?> _navigateToCamera(CameraDescription camera) {
    return Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => CameraPage(camera: camera),
      ),
    );
  }

// Handle the video path after navigation
  void _handleVideoPath(String path) {
    setState(() {
      videoPath = path; // Update videoPath with the new path
      videoController = VideoPlayerController.file(File(videoPath!))
        ..initialize().then((_) {
          // Refresh the UI after the controller is initialized
          if (mounted) {
            setState(() {}); // Refresh the UI
          }
        });
    });
  }



  Widget _buildVideoPickerButton() {
    return ElevatedButton(
      onPressed: pickVideoFromCamera,
      child: Text('Pick a Video'),
    );
  }

  Widget _buildVideoPlayer() {
    if (videoController != null && videoController!.value.isInitialized) {
      return AspectRatio(
        aspectRatio: videoController!.value.aspectRatio,
        child: VideoPlayer(videoController!),
      );
    } else {
      return Container(
        color: Colors.grey,
        height: 200,
        child: Center(child: Text('No video selected', style: TextStyle(color: Colors.white))),
      );
    }
  }

  Widget _buildNotifyOpponentsButton() {
    return ElevatedButton(
      onPressed: () {
        // Notify opponents logic here
      },
      child: Text('Notify Opponents'),
    );
  }

  Widget _buildCreateChallengeButton() {
    return ElevatedButton(
      onPressed: () {
        if (formKey.currentState!.validate()) {
          // Form submission logic here
          setState(() {
            statusMessage = 'Challenge created successfully!';
          });
        }
      },
      child: Text('Create Challenge'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Your Own Challenge', style: Theme.of(context).textTheme.titleLarge),
      ),
      body: Container(
        color: AppColors.primaryColor,
        padding: EdgeInsets.all(AppDimens.paddingLarge),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextInput(challengeNameController, AppStrings.challengeName, AppStrings.challengeNameError),
                SizedBox(height: AppDimens.spacingMedium),
                _buildTextInput(challengeTypeController, AppStrings.challengeType, AppStrings.challengeTypeError),
                SizedBox(height: AppDimens.spacingMedium),
                _buildParticipantDropdown(),
                SizedBox(height: AppDimens.spacingMedium),
                _buildSelectedParticipantsChips(),
                SizedBox(height: AppDimens.spacingMedium),
                _buildDateRow(AppStrings.startDate, startDate, () => selectDate(context, true)),
                SizedBox(height: AppDimens.spacingMedium),
                _buildDateRow(AppStrings.endDate, endDate, () => selectDate(context, false)),
                SizedBox(height: AppDimens.spacingMedium),
                _buildVideoPickerButton(),
                SizedBox(height: AppDimens.spacingMedium),
                _buildVideoPlayer(),
                SizedBox(height: AppDimens.spacingMedium),
                _buildNotifyOpponentsButton(),
                SizedBox(height: AppDimens.spacingMedium),
                _buildCreateChallengeButton(),
                SizedBox(height: AppDimens.spacingMedium),
                if (statusMessage != null)
                  Text(statusMessage!, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CameraPage extends StatefulWidget {
  final CameraDescription camera;

  const CameraPage({super.key, required this.camera});

  // The getter will return a future list of available cameras
  static Future<List<CameraDescription>> get cameras async => await availableCameras();

  @override
  CameraPageState createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takeVideo() async {
    try {
      await _initializeControllerFuture;

      // Start recording video
      await _controller.startVideoRecording();

      // Wait for the user to finish recording (you might want to adjust this)
      await Future.delayed(const Duration(seconds: 10));

      // Stop recording video
      final videoPath = await _controller.stopVideoRecording();

      // Check if the widget is still mounted before using context
      if (!mounted) return;

      // Return the video path to the previous screen
      Navigator.pop(context, videoPath.path);
    } catch (e) {
      // Handle errors here
      if (!mounted) return; // Check if the widget is still mounted
      Navigator.pop(context); // Navigate back without returning a video path
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record a Video'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(_controller),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                    onPressed: _takeVideo,
                    child: const Text('Record Video'),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
