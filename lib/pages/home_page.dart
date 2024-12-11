// import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitbattles/pages/points/earned_points_page.dart';
import 'package:fitbattles/pages/points/leaderboard_page.dart';
import 'package:fitbattles/pages/settings/settings_page.dart';
import 'package:fitbattles/pages/social/conversations_overview_page.dart';
import 'package:fitbattles/settings/ui/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fitbattles/widgets/persistent_navigation_bar.dart';
import 'package:fl_chart/fl_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.id, required this.email, required String uid});

  final String id;
  final String email;

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  // String? _photoURL;
  // String _userName= 'User';
  // File? _image;
  final picker = ImagePicker();
  final Logger logger = Logger();
  bool showPreloadedChallenges = false;
  int pointsEarned = 500;
  int pointsGoal = 1000;
  int unreadMessages = 0;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // _loadUserProfile();
    _checkUnreadMessages();
    _setupRealtimeUpdates();
  }

  List<Widget> get _pages => [
    _buildHomeContent(),
    const ConversationsOverviewPage(),
    LeaderboardPage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Future<void> _pickAndUploadImage() async {
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _image = File(pickedFile.path);
  //     });
  //
  //     try {
  //       final storageRef = FirebaseStorage.instance.ref();
  //       final userId = FirebaseAuth.instance.currentUser!.uid;
  //       final imageRef = storageRef.child('profile_images/$userId.jpg');
  //
  //       await imageRef.putFile(_image!);
  //       String downloadURL = await imageRef.getDownloadURL();
  //
  //       // Save download URL to Firestore
  //       await FirebaseFirestore.instance.collection('users').doc(userId).update(
  //         {'photoURL': downloadURL},
  //       );
  //     } catch (e) {
  //       logger.e("Error uploading image: $e");
  //     }
  //   }
  // }

  // Future<void> _loadUserProfile() async {
  //   try {
  //     DocumentSnapshot userProfile = await FirebaseFirestore.instance.collection('users').doc(widget.id).get();
  //     setState(() {
  //       _photoURL = userProfile['photoURL'];
  //       _userName= userProfile['name']?? 'User';
  //     });
  //   } catch (e) {
  //     logger.e("Error loading user profile: $e");
  //   }
  // }

  Future<void> _checkUnreadMessages() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final query = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('conversations')
        .where('lastRead', isLessThan: FieldValue.serverTimestamp())
        .get();

    setState(() {
      unreadMessages = query.docs.length;
    });
  }

  void _setupRealtimeUpdates() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('conversations')
        .snapshots()
        .listen((snapshot) {
      int unreadCount = 0;
      for (var doc in snapshot.docs) {
        final lastRead = doc.data().containsKey('lastRead') ? doc['lastRead'] as Timestamp? : null;
        final lastUpdated = doc.data().containsKey('lastUpdated') ? doc['lastUpdated'] as Timestamp? : null;

        if (lastUpdated != null && (lastRead == null || lastRead.compareTo(lastUpdated) < 0)) {
          unreadCount++;
        }
      }
      setState(() {
        unreadMessages = unreadCount;
      });
    });
  }

  Widget _buildHomeContent() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60.0, horizontal: 18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Align(
            //   alignment: Alignment.centerLeft,
            //   child: Padding(
            //     padding: const EdgeInsets.only(bottom: 16.0),
                // child: Text(
                //   'Welcome back, $_userName',
                //   style: TextStyle(
                //     fontSize: 24,
                //     fontWeight: FontWeight.bold,
                //     color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                //   ),
                // ),
            //   ),
            // ),
            // _buildHeader(themeProvider),
            // const SizedBox(height: 32),
            // _buildPointsSection(context, themeProvider),
            // const SizedBox(height: 32),
            _buildHealthReportContainer(context, themeProvider),
            const SizedBox(height: 32),
            _buildChallengesContainer(context, themeProvider),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 1,
                  child: _buildWorkoutContainer(context, themeProvider),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: _buildGoalsContainer(context, themeProvider),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildTopChallengedFriends(exampleFriends, themeProvider),
            _buildFriendsListButton(context, themeProvider),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('settings')
          .doc('notifications')
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          // Default values if settings don't exist
          return _buildScaffold(themeProvider, unreadMessages, true, true);
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final receiveNotifications = data['receiveNotifications'] ?? true;
        final messageNotifications = data['messageNotifications'] ?? true;

        return _buildScaffold(
            themeProvider, unreadMessages, receiveNotifications, messageNotifications);
      },
    );
  }

  Widget _buildScaffold(
      ThemeProvider themeProvider,
      int unreadMessages,
      bool receiveNotifications,
      bool messageNotifications) {
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Color(0xFF1F1F1F) : null,
      body: Container(
        decoration: themeProvider.isDarkMode
            ? null
            : BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE7E9EF), Color(0xFF2C96CF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          // appBar: AppBar(
          //   backgroundColor: Colors.transparent,
          //   automaticallyImplyLeading: false,
          //   title: const Text(
          //     "Home",
          //     style: TextStyle(color: Colors.transparent),
          //   ),
          //   leading: Builder(
          //     builder: (context) => IconButton(
          //       icon: Icon(Icons.menu), // Hamburger menu icon
          //       onPressed: () => Scaffold.of(context).openDrawer(),
          //     ),
          //   ),
          //   actions: [
          //     Stack(
          //       children: [
          //         IconButton(
          //           icon: const Icon(Icons.message),
          //           onPressed: () {
          //             Navigator.push(
          //               context,
          //               MaterialPageRoute(
          //                   builder: (context) => ConversationsOverviewPage()),
          //             );
          //           },
          //         ),
          //         if (unreadMessages > 0 &&
          //             receiveNotifications == true &&
          //             messageNotifications == true)
          //           Positioned(
          //             right: 8,
          //             top: 8,
          //             child: CircleAvatar(
          //               radius: 8,
          //               backgroundColor: Colors.red,
          //               child: Text(
          //                 '$unreadMessages',
          //                 style:
          //                 const TextStyle(color: Colors.white, fontSize: 10),
          //               ),
          //             ),
          //           ),
          //       ],
          //     ),
          //     IconButton(
          //       icon: Icon(themeProvider.isDarkMode
          //           ? Icons.wb_sunny
          //           : Icons.nights_stay),
          //       onPressed: () {
          //         themeProvider.toggleTheme();
          //       },
          //     ),
          //     IconButton(
          //       icon: const Icon(Icons.settings),
          //       onPressed: () {
          //         Navigator.pushNamed(context, '/settings');
          //       },
          //     ),
          //   ],
          // ),
          // drawer: Drawer(
          //   child: ListView(
          //     padding: EdgeInsets.zero,
          //     children: <Widget>[
          //       DrawerHeader(
          //         decoration: BoxDecoration(
          //           color: themeProvider.isDarkMode
          //               ? Color(0xFF1F1F1F)
          //               : Color(0xFF58708F),
          //         ),
          //         child: Text(
          //           'FitBattles',
          //           style: TextStyle(color: Colors.white, fontSize: 25),
          //         ),
          //       ),
          //       ListTile(
          //         leading: const Icon(Icons.home),
          //         title: const Text('Home'),
          //         onTap: () {
          //           Navigator.pop(context); // Close the drawer
          //         },
          //       ),
          //       ListTile(
          //         leading: const Icon(Icons.fitness_center),
          //         title: const Text('Workout'),
          //         onTap: () {
          //           Navigator.pushNamed(context, '/workout');
          //         },
          //       ),
          //       ListTile(
          //         leading: const Icon(Icons.trending_up),
          //         title: const Text('Challenges'),
          //         onTap: () {
          //           Navigator.pushNamed(context, '/challenges');
          //         },
          //       ),
          //       ListTile(
          //         leading: const Icon(Icons.history),
          //         title: const Text('History'),
          //         onTap: () {
          //           Navigator.pushNamed(context, '/history');
          //         },
          //       ),
          //       ListTile(
          //         leading: const Icon(Icons.logout),
          //         title: const Text('Logout'),
          //         onTap: () {
          //           final FirebaseAuth auth = FirebaseAuth.instance;
          //           SettingsPageState.showLogoutDialog(context, auth);
          //         },
          //       ),
          //     ],
          //   ),
          // ),
          body: _pages[_selectedIndex],
          bottomNavigationBar: PersistentNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
          // floatingActionButton: SpeedDial(
          //   animatedIcon: AnimatedIcons.add_event,
          //   backgroundColor: Color(0xFF84C63E),
          //   children: [
          //
          //     SpeedDialChild(
          //       child: Icon(Icons.add),
          //       label: 'Add Goal',
          //       backgroundColor: Colors.lime,
          //       onTap: () {
          //         Navigator.of(context).pushNamed('/addGoal');
          //       },
          //     ),
          //     SpeedDialChild(
          //         child: Icon(Icons.add),
          //         label: 'Log Workout',
          //         backgroundColor: Colors.lime,
          //         onTap: () {
          //           Navigator.of(context).pushNamed('/customWorkout');
          //         }
          //     ),
          //     SpeedDialChild(
          //       child: Icon(Icons.add),
          //       label: 'Add Challenge',
          //       backgroundColor: Colors.lime,
          //       onTap: () {
          //         Navigator.of(context).pushNamed('/create_challenge');
          //       },
          //     ),
          //   ],
          // ),
        ),
      ),
    );
  }

  // Widget _buildHeader(ThemeProvider themeProvider) {
  //   final textColor = themeProvider.isDarkMode ? Colors.white : Colors.black;
  //
  //   return Container(
  //     color: Colors.transparent,
  //     width: double.infinity,
  //     height: 200,
  //     padding: const EdgeInsets.symmetric(horizontal: 16.0),
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: [
  //         Text(
  //           'FitBattles',
  //           style: TextStyle(
  //             fontSize: 30,
  //             fontWeight: FontWeight.bold,
  //             color: Colors.transparent,
  //
  //           ),
  //           textAlign: TextAlign.center,
  //         ),
  //         const SizedBox(height: 10),
  //         GestureDetector(
  //           onTap: _pickAndUploadImage,
  //           child: CircleAvatar(
  //             radius: 60,
  //             backgroundColor: themeProvider.isDarkMode ? Colors.grey[700] : Colors.grey[300],
  //             backgroundImage: _image != null
  //                 ? FileImage(_image!)
  //                 : (_photoURL != null ? NetworkImage(_photoURL!) : null),
  //             child: _image == null && _photoURL == null
  //                 ? Icon(Icons.add_a_photo, color: textColor, size: 30)
  //                 : null,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildPointsSection(BuildContext context,
  //     ThemeProvider themeProvider) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 16.0),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: [
  //         Text(
  //           'Points Earned',
  //           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: themeProvider.isDarkMode ? Colors.white : Colors.black),
  //         ),
  //         const SizedBox(height: 8),
  //         ClipRRect(
  //           borderRadius: BorderRadius.circular(10),
  //           child: LinearProgressIndicator(
  //             value: pointsEarned / pointsGoal,
  //             minHeight: 20,
  //             backgroundColor: themeProvider.isDarkMode
  //                 ? Colors.grey[800]
  //                 : Colors.grey[300],
  //             color: const Color(0xFF85C83E),
  //           ),
  //         ),
  //         const SizedBox(height: 8),
  //         Text(
  //           '$pointsEarned / $pointsGoal points',
  //           style: TextStyle(fontSize: 16, color: themeProvider.isDarkMode ? Colors.white : Colors.black),
  //         ),
  //         const SizedBox(height: 16),
  //       ElevatedButton(
  //         onPressed: () {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => EarnedPointsPage(
  //                 userId: widget.id, // Only pass userId, as EarnedPointsPage fetches other data from Firebase
  //               ),
  //             ),
  //           );
  //         },
  //         style: ElevatedButton.styleFrom(
  //           foregroundColor: Colors.white,
  //           backgroundColor: const Color(0xFF85C83E),
  //         ),
  //         child: const Text('View Earned Points'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildChallengesContainer(BuildContext context, ThemeProvider themeProvider) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Challenges',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Divider(
                color: Colors.grey.shade300,
                thickness: 1,
                height: 0,
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5, // Number of placeholder challenges
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Container(
                        width: 150,
                        decoration: BoxDecoration(
                          color: themeProvider.isDarkMode ? Colors.grey[700] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'Challenge ${index + 1}',
                            style: TextStyle(
                              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: Icon(
              Icons.arrow_forward,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pushNamed('/user_challenges');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutContainer(BuildContext context, ThemeProvider themeProvider) {
    return Stack(
      children: [
        Card(
          elevation: 5, // Adds depth to the card
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Workout', // Section title
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Divider(
                  color: Colors.grey.shade300,
                  thickness: 1,
                  height: 0,
                ),
                const SizedBox(height: 10),
                // Placeholder Workouts Section
                const SizedBox(height: 10),
                SizedBox(
                  height: 88,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5, // Number of placeholder workouts
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Container(
                          width: 150,
                          decoration: BoxDecoration(
                            color: themeProvider.isDarkMode ? Colors.grey[700] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              'Workout ${index + 1}',
                              style: TextStyle(
                                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: Icon(
              Icons.arrow_forward,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () {
              // action to be determined
              Navigator.of(context).pushNamed('/customWorkout');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsContainer(BuildContext context, ThemeProvider themeProvider) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Goals',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Divider(
                color: Colors.grey.shade300,
                thickness: 1,
                height: 0,
              ),
              const SizedBox(height: 10),
              // Placeholder Goals Section
              const SizedBox(height: 10),
              SizedBox(
                height: 88,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5, // Number of placeholder goals
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Container(
                        width: 150,
                        decoration: BoxDecoration(
                          color: themeProvider.isDarkMode ? Colors.grey[700] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'Goal ${index + 1}',
                            style: TextStyle(
                              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: Icon(
              Icons.arrow_forward,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () {
              // To be determined
              Navigator.pushNamed(context, '/currentGoals');
            },
          ),
        ),
      ],
    );
  }


  Widget _buildHealthReportContainer(BuildContext context, ThemeProvider themeProvider) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(128),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Health Report',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Divider(
                color: Colors.grey.shade300,
                thickness: 1,
                height: 0,
              ),
              const SizedBox(height: 10),

              // Graph Section
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                child: _buildCaloriesChart(), // fl_chart bar chart for calories
              ),
            ],
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: Icon(
              Icons.arrow_forward,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () {
              // Add your desired action here
              Navigator.of(context).pushNamed('/historyNextPage');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCaloriesChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(show: true),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(0, 1),
              FlSpot(1, 3),
              FlSpot(2, 2),
              FlSpot(3, 5),
              FlSpot(4, 3),
              FlSpot(5, 4),
            ],
            isCurved: true,
            //color: [Colors.blue],
            barWidth: 4,
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }


  Widget _buildTopChallengedFriends(List<String> friends, ThemeProvider themeProvider) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Top Challenged Friends',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Divider(
                color: Colors.grey.shade300,
                thickness: 1,
                height: 0,
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: GestureDetector(
                        onTap: () {
                          _showFriendInfo(
                            context,
                            friends[index].split('/').last.split('.').first,
                            friends[index],
                            gamesWon: 25,
                            streakDays: 10,
                            rank: 3,
                          );
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: AssetImage(friends[index]),
                            ),
                            const SizedBox(height: 8),
                            Text(friends[index].split('/').last.split('.').first),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: Icon(
              Icons.arrow_forward,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () {
              // Add your desired action here
              Navigator.of(context).pushNamed('/topChallengedFriendsNextPage');
            },
          ),
        ),
      ],
    );
  }

  void _showFriendInfo(BuildContext context, String friendName,
      String friendImagePath,
      {int gamesWon = 0, int streakDays = 0, int rank = 0}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF85C83E),
          title: Text(friendName, style: const TextStyle(color: Colors.black)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(friendImagePath),
              const SizedBox(height: 10),
              Text('Games Won: $gamesWon',
                  style: const TextStyle(color: Colors.black)),
              const SizedBox(height: 5),
              Text('Streak Days: $streakDays',
                  style: const TextStyle(color: Colors.black)),
              const SizedBox(height: 5),
              Text('Rank: $rank', style: const TextStyle(color: Colors.black)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  final List<String> exampleFriends = [
    'assets/images/Bob.png',
    'assets/images/Charlie.png',
    'assets/images/Hannah.png',
    'assets/images/Ian.png',
    'assets/images/Fiona.png',
    'assets/images/George.png',
    'assets/images/Ethan.png',
    'assets/images/Diana.png',
    'assets/images/Alice.png',
  ];

  Widget _buildFriendsListButton(BuildContext context, ThemeProvider themeProvider) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(
            context, '/friends'); // Navigate to the friends page
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, // Set text color to white
        backgroundColor: const Color(0xFF85C83E),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 36.0),
      ),
      child: const Text('Friends'),
    );
  }
}