import 'package:flutter/material.dart';

class FriendsListPage extends StatefulWidget {
  const FriendsListPage({super.key});

  @override
  State<FriendsListPage> createState() => _FriendsListPage();
}

class _FriendsListPage extends State<FriendsListPage> {
  // Define the exampleFriends list here
  final List<Map<String, dynamic>> exampleFriends = [
    {'name': 'Bob', 'image': 'assets/images/Bob.png'},
    {'name': 'Charlie', 'image': 'assets/images/Charlie.png'},
    {'name': 'Hannah', 'image': 'assets/images/Hannah.png'},
    {'name': 'Ian', 'image': 'assets/images/Ian.png'},
    {'name': 'Fiona', 'image': 'assets/images/Fiona.png'},
    {'name': 'George', 'image': 'assets/images/George.png'},
    {'name': 'Ethan', 'image': 'assets/images/Ethan.png'},
    {'name': 'Diana', 'image': 'assets/images/Diana.png'},
    {'name': 'Alice', 'image': 'assets/images/Alice.png'},
  ];

  List<Map<String, dynamic>> addedFriends = []; // List to hold added friends
  String searchQuery = ''; // Variable to hold search input

  @override
  Widget build(BuildContext context) {
    // Filter friends based on the search query
    final filteredFriends = exampleFriends.where((friend) {
      return friend['name'].toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5D6C8A), // App bar color
        title: const Text('Friends'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search Friends',
                border: OutlineInputBorder(),
                fillColor: Colors.white, // Input field background
                filled: true,
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value; // Update search query
                });
              },
            ),
          ),
          // List of filtered friends
          Expanded(
            child: ListView.builder(
              itemCount: filteredFriends.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: ClipOval(
                    child: Image.asset(filteredFriends[index]['image'], fit: BoxFit.cover),
                  ),
                  title: Text(filteredFriends[index]['name']),
                  tileColor: const Color(0xFFEFEFEF), // Background color for ListTile
                  trailing: IconButton(
                    icon: const Icon(Icons.add, color: Colors.black), // Add icon color
                    onPressed: () {
                      // Add friend to addedFriends list
                      setState(() {
                        addedFriends.add(filteredFriends[index]);
                      });
                      // Show feedback
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${filteredFriends[index]['name']} added!')),
                      );
                    },
                  ),
                  onTap: () => showFriendInfoDialog(filteredFriends[index]), // Show friend info on tap
                );
              },
            ),
          ),
          const Divider(),
          // Added friends section
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Added Friends',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          // List of added friends
          addedFriends.isEmpty
              ? const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No friends added yet.', style: TextStyle(fontSize: 16)),
          )
              : Expanded(
            child: ListView.builder(
              itemCount: addedFriends.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: ClipOval(
                    child: Image.asset(addedFriends[index]['image'], fit: BoxFit.cover),
                  ),
                  title: Text(addedFriends[index]['name']),
                  tileColor: const Color(0xFFEFEFEF), // Background color for ListTile
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red), // Delete icon color
                    onPressed: () {
                      // Remove friend from addedFriends list
                      setState(() {
                        addedFriends.removeAt(index);
                      });
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(friend['name']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipOval(
                child: Image.asset(
                  friend['image'],
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
              const Text('Challenge Stats:'), // Placeholder for challenge stats
              // Add challenge stats here, if available
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
