import 'package:flutter/material.dart';

class VisibilitySettingsPage extends StatelessWidget {
  const VisibilitySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visibility Settings'),
      ),
      body: const Center(
        child: Text(
          'Visibility Settings Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
