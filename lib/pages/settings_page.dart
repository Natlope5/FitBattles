import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required String heading});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _name = '';
  String _bio = '';
  int _age = 0;
  double _weight = 0.0;
  String _heightFeet = '0';
  String _heightInches = '0';
  bool _shareData = false;
  bool _receiveNotifications = false;
  String _visibility = 'public';

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  // Load user settings from Firestore
  Future<void> _loadUserSettings() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _name = userDoc['name'] ?? '';
          _bio = userDoc['bio'] ?? '';
          _age = userDoc['age'] ?? 0;
          _weight = userDoc['weight'] ?? 0.0;
          int totalHeightInInches = userDoc['height_inches'] ?? 0;
          _heightFeet = (totalHeightInInches ~/ 12).toString(); // Feet
          _heightInches = (totalHeightInInches % 12).toString(); // Remaining Inches
          _shareData = userDoc['share_data'] ?? false;
          _receiveNotifications = userDoc['receive_notifications'] ?? false;
          _visibility = userDoc['visibility'] ?? 'public';
        });
      }
    }
  }

  // Save user settings to Firestore
  Future<String> _saveSettings() async {
    User? user = _auth.currentUser;
    if (user != null && _formKey.currentState!.validate()) {
      try {
        // Convert height to total inches
        int totalHeightInInches = (int.parse(_heightFeet) * 12) + int.parse(_heightInches);

        DocumentReference userDoc = _firestore.collection('users').doc(user.uid);

        // Check if the document exists
        bool docExists = (await userDoc.get()).exists;

        if (docExists) {
          // Update the document
          await userDoc.update({
            'name': _name,
            'bio': _bio,
            'age': _age,
            'weight': _weight, // in lbs
            'height_inches': totalHeightInInches,
            'share_data': _shareData,
            'receive_notifications': _receiveNotifications,
            'visibility': _visibility,
          });
        } else {
          // Create the document if it does not exist
          await userDoc.set({
            'name': _name,
            'bio': _bio,
            'age': _age,
            'weight': _weight,
            'height_inches': totalHeightInInches,
            'share_data': _shareData,
            'receive_notifications': _receiveNotifications,
            'visibility': _visibility,
          });
        }

        // Reload the user settings after saving
        await _loadUserSettings();

        return 'Settings updated successfully!';
      } catch (e) {
        return 'Failed to update settings: ${e.toString()}';
      }
    }
    return 'Failed to update settings: Form validation error';
  }

  // Logout the user
  Future<void> _logout() async {
    await _auth.signOut();
    _navigateToLogin();
  }

  void _navigateToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacementNamed('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    initialValue: _name,
                    decoration: InputDecoration(labelText: 'Name'),
                    onChanged: (value) => setState(() => _name = value),
                    validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                  ),
                  TextFormField(
                    initialValue: _bio,
                    decoration: InputDecoration(labelText: 'Bio'),
                    onChanged: (value) => setState(() => _bio = value),
                  ),
                  TextFormField(
                    initialValue: _age.toString(),
                    decoration: InputDecoration(labelText: 'Age'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => setState(() => _age = int.tryParse(value) ?? 0),
                    validator: (value) => value!.isEmpty ? 'Please enter your age' : null,
                  ),
                  TextFormField(
                    initialValue: _weight.toString(),
                    decoration: InputDecoration(labelText: 'Weight (lbs)'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => setState(() => _weight = double.tryParse(value) ?? 0.0),
                    validator: (value) => value!.isEmpty ? 'Please enter your weight' : null,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: _heightFeet,
                          decoration: InputDecoration(labelText: 'Height (feet)'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => setState(() => _heightFeet = value),
                          validator: (value) => value!.isEmpty ? 'Please enter feet' : null,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          initialValue: _heightInches,
                          decoration: InputDecoration(labelText: 'Height (inches)'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => setState(() => _heightInches = value),
                          validator: (value) => value!.isEmpty ? 'Please enter inches' : null,
                        ),
                      ),
                    ],
                  ),
                  SwitchListTile(
                    title: Text('Share Data'),
                    value: _shareData,
                    onChanged: (value) => setState(() => _shareData = value),
                  ),
                  SwitchListTile(
                    title: Text('Receive Notifications'),
                    value: _receiveNotifications,
                    onChanged: (value) => setState(() => _receiveNotifications = value),
                  ),

                  // Privacy Settings label
                  SizedBox(height: 20), // Space before the title
                  Text(
                    'Privacy Settings',
                    style: TextStyle(
                      fontSize: 18, // You can adjust the size as needed
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10), // Space after the title

                  DropdownButtonFormField<String>(
                    value: _visibility,
                    decoration: InputDecoration(labelText: 'Profile Visibility'),
                    items: ['public', 'friendsOnly', 'private'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _visibility = value!),
                  ),

                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      String message = await _saveSettings();
                      _showSnackbar(message);
                    },
                    child: Text('Save Changes'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackbar(String message) {
    // Show the snackbar message
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
