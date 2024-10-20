import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitbattles/settings/app_colors.dart';
import 'package:fitbattles/settings/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:fitbattles/settings/app_strings.dart';

import '../firebase/firebase_messaging.dart';

class FriendsListPage extends StatefulWidget {
  const FriendsListPage({super.key});

  @override
  State<FriendsListPage> createState() => _FriendsListPage();
}

class _FriendsListPage extends State<FriendsListPage> {
  final List<Map<String, dynamic>> exampleFriends = [
    {'name': 'Bob', 'image': 'assets/images/Bob.png'},
    {'name': 'Charlie', 'image': 'assets/images/Charlie.png'},
    // ... other friends
  ];

  List<Map<String, dynamic>> addedFriends = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAddedFriends();
  }

  Future<void> _loadAddedFriends() async {
    try {
      // Replace 'userID' with the actual user ID or token
      final DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc('userID') // Fetch the user's document
          .get();

      if (doc.exists) {
        setState(() {
          addedFriends = List<Map<String, dynamic>>.from(doc['friends'] ?? []);
        });
      }
    } catch (e) {
      logger.i('Error loading friends: $e');
    }
  }

  Future<void> _saveFriends() async {
    try {
      // Replace 'userID' with the actual user ID or token
      await FirebaseFirestore.instance
          .collection('users')
          .doc('userID') // Save to the user's document
          .set({'friends': addedFriends});
    } catch (e) {
      logger.i('Error saving friends: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredFriends = exampleFriends.where((friend) {
      return friend['name'].toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkTheme ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBarColor,
        title: Text(
          AppStrings.friendsTitle,
          style: TextStyle(color: textColor),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimens.padding),
            child: TextField(
              decoration: InputDecoration(
                labelText: AppStrings.searchFriendsLabel,
                labelStyle: TextStyle(color: textColor),
                border: const OutlineInputBorder(),
                fillColor: isDarkTheme ? Colors.grey[800] : Colors.white,
                filled: true,
              ),
              style: TextStyle(color: textColor),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredFriends.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: ClipOval(
                    child: Image.asset(
                      filteredFriends[index]['image'],
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    filteredFriends[index]['name'],
                    style: TextStyle(color: textColor),
                  ),
                  tileColor: AppColors.tileColor,
                  trailing: IconButton(
                    icon: Icon(Icons.add, color: textColor),
                    onPressed: () {
                      setState(() {
                        addedFriends.add(filteredFriends[index]);
                      });
                      _saveFriends(); // Save friends to Firestore
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${filteredFriends[index]['name']} ${AppStrings.addedFriendMessage}',
                            style: TextStyle(color: textColor),
                          ),
                        ),
                      );
                    },
                  ),
                  onTap: () => showFriendInfoDialog(filteredFriends[index]),
                );
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(AppDimens.padding),
            child: Text(
              'Added Friends',
              style: TextStyle(
                fontSize: AppDimens.fontSizeTitle,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          addedFriends.isEmpty
              ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              AppStrings.noFriendsAdded,
              style: TextStyle(
                fontSize: AppDimens.fontSizeSubtitle,
                color: textColor,
              ),
            ),
          )
              : Expanded(
            child: ListView.builder(
              itemCount: addedFriends.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: ClipOval(
                    child: Image.asset(
                      addedFriends[index]['image'],
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    addedFriends[index]['name'],
                    style: TextStyle(color: textColor),
                  ),
                  tileColor: AppColors.tileColor,
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: AppColors.deleteIconColor),
                    onPressed: () {
                      setState(() {
                        addedFriends.removeAt(index);
                      });
                      _saveFriends(); // Save friends to Firestore
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void showFriendInfoDialog(Map<String, dynamic> friend) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkTheme ? Colors.white : Colors.black;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            friend['name'],
            style: TextStyle(color: textColor),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipOval(
                child: Image.asset(
                  friend['image'],
                  width: AppDimens.avatarSize,
                  height: AppDimens.avatarSize,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                AppStrings.challengeStats,
                style: TextStyle(color: textColor),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppStrings.closeButtonLabel,
                style: TextStyle(color: textColor),
              ),
            ),
          ],
        );
      },
    );
  }
}
