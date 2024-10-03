import 'package:flutter/material.dart';
import 'package:fitbattles/models/privacy_model.dart';
 // Import your PrivacyModel

class PrivacySettingsPage extends StatefulWidget {
  final String uid;

  const PrivacySettingsPage({super.key, required this.uid});

  @override
  PrivacySettingsPageState createState() => PrivacySettingsPageState();
}

class PrivacySettingsPageState extends State<PrivacySettingsPage> {
  late PrivacyModel privacyModel;
  String currentPrivacySetting = 'public'; // Default privacy setting

  @override
  void initState() {
    super.initState();
    privacyModel = PrivacyModel(uid: widget.uid);
    _fetchPrivacySetting(); // Fetch the user's privacy setting on init
  }

  Future<void> _fetchPrivacySetting() async {
    try {
      String privacy = await privacyModel.getPrivacySetting(); // Get the setting from PrivacyModel
      setState(() {
        currentPrivacySetting = privacy;
      });
    } catch (error) {
      // Handle potential errors like network issues
      _showErrorDialog('Failed to fetch privacy settings');
    }
  }

  Future<void> _updatePrivacySetting(String newPrivacy) async {
    try {
      await privacyModel.updatePrivacySetting(newPrivacy); // Update via PrivacyModel
      setState(() {
        currentPrivacySetting = newPrivacy;
      });
    } catch (error) {
      // Handle potential errors like Firestore permission issues
      _showErrorDialog('Failed to update privacy settings');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Who can view your data?', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: currentPrivacySetting,
              items: const [
                DropdownMenuItem(value: 'public', child: Text('Public')),
                DropdownMenuItem(value: 'friends', child: Text('Friends Only')),
                DropdownMenuItem(value: 'private', child: Text('Private')),
              ],
              onChanged: (String? newValue) {
                if (newValue != null) {
                  _updatePrivacySetting(newValue); // Update the privacy setting
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
