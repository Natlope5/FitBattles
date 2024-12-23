import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitbattles/pages/health/history_page.dart';
import 'package:fitbattles/pages/social/friends_list_page.dart';
import 'package:fitbattles/settings/ui/theme_provider.dart';
import 'package:fitbattles/widgets/containment/profile_drawer.dart';
import 'package:intl/intl.dart';
import 'package:fitbattles/pages/health/health_report_graph.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.id, required this.email, required String uid});

  final String id;
  final String email;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  int _selectedIndex = 1; // Default to home tab
  String profileImageUrl = '';

  @override
  void initState() {
    super.initState();
    _fetchProfileImage();
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
  Future<void> _fetchProfileImage() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.id).get();
    setState(() {
      profileImageUrl = userDoc['image_url'] ?? '';
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  Widget _buildHomeContent(BuildContext scaffoldContext) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return SingleChildScrollView(
      controller: _scrollController,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, MMM d').format(DateTime.now()),
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Summary',
                        style: TextStyle(
                          color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Builder(
                    builder: (innerContext) {
                      return InkWell(
                        onTap: () {
                          Scaffold.of(innerContext).openEndDrawer();
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage: profileImageUrl.isNotEmpty
                              ? NetworkImage(profileImageUrl)
                              : const AssetImage('assets/images/placeholder_avatar.png') as ImageProvider,
                          backgroundColor: Colors.transparent,
                        ),
                      );
                    },
                  )
                ],
              ),
              const SizedBox(height: 32),
              _buildHealthReportContainer(context, themeProvider),
              const SizedBox(height: 32),
              _buildChallengesContainer(context, themeProvider),
              const SizedBox(height: 32),
              _buildWorkoutContainer(context, themeProvider),
              const SizedBox(height: 32),
              _buildGoalsContainer(context, themeProvider),
              const SizedBox(height: 32),
              _buildTopChallengedFriends(exampleFriends, themeProvider),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildChallengesContainer(BuildContext context, ThemeProvider themeProvider) {
    return Stack(
      children: [
        Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
          child: Padding(
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
                    itemCount: 5,
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
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: const Icon(
              Icons.arrow_forward,
              color: Colors.lightGreen,
            ),
            onPressed: () {
              if (mounted) {
                Navigator.of(context).pushNamed('/user_challenges');
              }
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
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Workout',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Divider(
                  color: Colors.grey.shade300,
                  thickness: 1,
                  height: 0,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 88,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
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
            icon: const Icon(
              Icons.arrow_forward,
              color: Colors.lightGreen,
            ),
            onPressed: () {
              _showWorkoutOptions(context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsContainer(BuildContext context, ThemeProvider themeProvider) {
    return Stack(
      children: [
        Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
          child: Padding(
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
                const SizedBox(height: 20),
                SizedBox(
                  height: 88,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
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
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: const Icon(
              Icons.arrow_forward,
              color: Colors.lightGreen,
            ),
            onPressed: () {
              if (mounted) {
                Navigator.pushNamed(context, '/addGoal');
              }
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
          width: MediaQuery.of(context).size.width,
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
              const SizedBox(
                height: 200,
                child: HealthReportGraph(),
              ),
            ],
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: const Icon(
              Icons.arrow_forward,
              color: Colors.lightGreen,
            ),
            onPressed: () {
              if (mounted) {
                Navigator.of(context).pushNamed('/healthReport');
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopChallengedFriends(List<String> friends, ThemeProvider themeProvider) {
    return Stack(
      children: [
        Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
          child: Padding(
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
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: const Icon(
              Icons.arrow_forward,
              color: Colors.lightGreen,
            ),
            onPressed: () {
              if (mounted) {
                Navigator.of(context).pushNamed('/topChallengedFriendsNextPage');
              }
            },
          ),
        ),
      ],
    );
  }

  void _showFriendInfo(BuildContext context, String friendName, String friendImagePath,
      {int gamesWon = 0, int streakDays = 0, int rank = 0}) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF85C83E),
          title: Text(friendName, style: const TextStyle(color: Colors.black)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(friendImagePath),
              const SizedBox(height: 10),
              Text('Games Won: $gamesWon', style: const TextStyle(color: Colors.black)),
              const SizedBox(height: 5),
              Text('Streak Days: $streakDays', style: const TextStyle(color: Colors.black)),
              const SizedBox(height: 5),
              Text('Rank: $rank', style: const TextStyle(color: Colors.black)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }
  void _showWorkoutOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Custom Workout'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/customWorkout');
                },
              ),
              ListTile(
                title: const Text('Workout Tracker'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/workoutTracking');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('settings')
          .doc('notifications')
          .get(),
      builder: (context, snapshot) {
        final List<Widget> pages = [
          const FriendsListPage(),
          Builder(
            builder: (scaffoldContext) {
              return _buildHomeContent(scaffoldContext);
            },
          ),
          const HistoryPage(),
        ];

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF1F1F1F) : null,
          endDrawer: const ProfileDrawer(),
          body: SafeArea(
            child: snapshot.connectionState == ConnectionState.waiting
                ? const Center(child: CircularProgressIndicator())
                : AnimatedSwitcher(
              duration: const Duration(milliseconds: 100),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: pages[_selectedIndex],
            ),
          ),
          bottomNavigationBar: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                backgroundColor: isDark
                    ? Colors.black.withOpacity(0.05)
                    : Colors.white.withOpacity(0.1),
                elevation: 0,
                selectedItemColor: isDark ? Colors.white : Colors.blue,
                unselectedItemColor: isDark ? Colors.grey[400] : Colors.grey[700],
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.face),
                    label: 'Friends',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.history_edu),
                    label: 'History',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}