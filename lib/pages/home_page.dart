import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitbattles/pages/health/history_page.dart';
import 'package:fitbattles/pages/points/leaderboard_page.dart';
import 'package:fitbattles/pages/social/friends_list_page.dart';
import 'package:fitbattles/settings/ui/theme_provider.dart';
import 'package:fitbattles/widgets/containment/settings_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:fitbattles/widgets/navigation/persistent_navigation_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.id, required this.email, required String uid});

  final String id;
  final String email;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final picker = ImagePicker();
  final Logger logger = Logger();
  bool showPreloadedChallenges = false;
  int pointsEarned = 500;
  int pointsGoal = 1000;
  int unreadMessages = 0;
  int _selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _checkUnreadMessages();
    _setupRealtimeUpdates();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<Widget> get _pages => [
    _buildHomeContent(),
    const FriendsListPage(),
    LeaderboardPage(),
    const MyHistoryPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
        padding: const EdgeInsets.only(top: 0.0, bottom: 60.0, left: 18.0, right: 18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
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
                    const Text(
                      'Summary',
                      style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    SettingsBottomSheet.show(context);
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: const AssetImage('assets/images/placeholder_avatar.png'),
                    backgroundColor: Colors.transparent,
                  ),
                )
              ],
            ),
            const SizedBox(height: 32),
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

  Widget _buildHomeContentWithoutSingleChildScrollView() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.only(top: 0.0, bottom: 60.0, left: 18.0, right: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
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
                  const Text(
                    'Summary',
                    style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              CircleAvatar(
                radius: 20,
                backgroundImage: const AssetImage('assets/images/placeholder_avatar.png'),
                backgroundColor: Colors.transparent,
              ),
            ],
          ),
          const SizedBox(height: 32),
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
      bool messageNotifications,
      ) {
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1F1F1F) : null,
      bottomNavigationBar: PersistentNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      body: Container(
        decoration: themeProvider.isDarkMode
            ? null
            : const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE7E9EF), Color(0xFF2C96CF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            if (_selectedIndex == 0)
              SliverToBoxAdapter(
                child: _buildHomeContentWithoutSingleChildScrollView(),
              ),

            if (_selectedIndex != 0)
              SliverFillRemaining(
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: _pages[_selectedIndex],
                ),
              ),
          ],
        ),
      ),
    );
  }

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
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: const Icon(
              Icons.arrow_forward,
              color: Colors.lightGreen,
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
                const SizedBox(height: 10),
                const SizedBox(height: 10),
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
              const SizedBox(height: 10),
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
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: const Icon(
              Icons.arrow_forward,
              color: Colors.lightGreen,
            ),
            onPressed: () {
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
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                child: _buildCaloriesChart(),
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
              Navigator.of(context).pushNamed('/healthReport');
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
            icon: const Icon(
              Icons.arrow_forward,
              color: Colors.lightGreen,
            ),
            onPressed: () {
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
              Text('Games Won: $gamesWon', style: const TextStyle(color: Colors.black)),
              const SizedBox(height: 5),
              Text('Streak Days: $streakDays', style: const TextStyle(color: Colors.black)),
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
        SettingsBottomSheet.show(context);
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF85C83E),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 36.0),
      ),
      child: const Text('Settings'),
    );
  }
}