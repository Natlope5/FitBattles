import 'package:flutter/material.dart';

class PersistentNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const PersistentNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.face), label: 'Friends'),
        NavigationDestination(icon: Icon(Icons.leaderboard), label: 'Leaderboard'),
        NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}