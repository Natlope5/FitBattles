import 'package:flutter/material.dart';

class ThemeSelection extends StatelessWidget {
  const ThemeSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Selection'), // Hardcoded title
      ),
      body: Column(
        children: [
          ListTile(
            title: const Text('Light Theme'), // Hardcoded light theme text
            onTap: () {
              // Handle light theme selection
            },
          ),
          ListTile(
            title: const Text('Dark Theme'), // Hardcoded dark theme text
            onTap: () {
              // Handle dark theme selection
            },
          ),
        ],
      ),
    );
  }
}
