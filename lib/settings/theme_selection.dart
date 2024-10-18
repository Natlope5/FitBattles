import 'package:flutter/material.dart';
import 'package:fitbattles/l10n/app_localizations.dart'; // Adjust this import according to your project structure

class ThemeSelection extends StatelessWidget {
  const ThemeSelection({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.themeTitle), // Use the correct getter
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(localizations.lightTheme), // Use the correct getter
            onTap: () {
              // Handle light theme selection
            },
          ),
          ListTile(
            title: Text(localizations.darkTheme), // Use the correct getter
            onTap: () {
              // Handle dark theme selection
            },
          ),
        ],
      ),
    );
  }
}

