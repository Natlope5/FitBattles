import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lottie/lottie.dart';
import 'package:vibration/vibration.dart';

class HydrationPage extends StatefulWidget {
  const HydrationPage({super.key});

  @override
  HydrationPageState createState() => HydrationPageState();
}

class HydrationPageState extends State<HydrationPage> with TickerProviderStateMixin {
  int consumedMl = 0;
  int dailyGoalMl = 4000;
  int cupSizeMl = 500;
  late AnimationController _animationController;
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool isDarkMode = false;
  List<String> hydrationHistory = [];
  String selectedWaterType = "Water";

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _loadSettings();
    _loadHydrationHistory();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      dailyGoalMl = prefs.getInt('dailyGoalMl') ?? 4000;
      cupSizeMl = prefs.getInt('cupSizeMl') ?? 500;
      consumedMl = prefs.getInt('consumedMl') ?? 0;
    });
  }

  void _scheduleNotifications() async {
    await _notificationsPlugin.periodicallyShow(
      0,
      'Hydration Reminder',
      'Don\'t forget to drink water!',
      RepeatInterval.hourly,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'hydration_channel',
          'Hydration Notifications',
          channelDescription: 'Reminders to drink water throughout the day',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexact, // Required parameter
    );
  }

  void _initNotifications() async {
    const AndroidInitializationSettings androidInitSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(
        android: androidInitSettings);
    await _notificationsPlugin.initialize(initSettings);
    _scheduleNotifications();
  }

  void _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('dailyGoalMl', dailyGoalMl);
    prefs.setInt('cupSizeMl', cupSizeMl);
    prefs.setInt('consumedMl', consumedMl);
    prefs.setStringList('hydrationHistory', hydrationHistory);
  }

  void _loadHydrationHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      hydrationHistory = prefs.getStringList('hydrationHistory') ?? [];
    });
  }

  void _addToHistory(String log) async {
    String date = DateTime.now().toString().split(' ')[0];
    hydrationHistory.add('$date: $consumedMl mL ($selectedWaterType)');
    _saveSettings();
  }

  void _clearHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Ensure widget is still mounted before calling setState or showing the snackbar
    if (mounted) {
      setState(() {
        consumedMl = 0;
        hydrationHistory.clear();
        _animationController.value = 0.0;
      });

      // Clear preferences
      await prefs.clear();

      // Show snackbar if widget is still mounted
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hydration log cleared!'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _handleCupClick() {
    setState(() {
      if (consumedMl + cupSizeMl <= dailyGoalMl) {
        consumedMl += cupSizeMl;
        _animationController.value = consumedMl / dailyGoalMl;

        _addToHistory('$cupSizeMl mL ($selectedWaterType) added');
        Vibration.vibrate(duration: 50);
      }
      _saveSettings();
    });
  }

  Widget _getCelebrationWidget() {
    if (consumedMl >= dailyGoalMl) {
      return Lottie.asset('assets/animations/congratulations.json', height: 150, width: 150);
    }
    return const SizedBox.shrink();
  }

  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  Widget _hydrationGraph() {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: hydrationHistory
                  .asMap()
                  .entries
                  .map((entry) {
                int index = entry.key;
                int value = int.parse(entry.value.split(': ')[1].split(' ')[0]);
                return FlSpot(index.toDouble(), value.toDouble());
              }).toList(),
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double progressPercent = consumedMl / dailyGoalMl;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hydration Tracker'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: _toggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _clearHistory,
            tooltip: 'Clear Log',
          ),
        ],
      ),
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Muscle Cup Animation with Filling Progress
            Lottie.asset(
              'assets/animations/muscle_cup.json',
              height: 150,
              width: 150,
              fit: BoxFit.cover,
              controller: _animationController,
              onLoaded: (composition) {
                _animationController.duration = composition.duration;
              },
            ),
            Text(
              '$consumedMl mL / $dailyGoalMl mL',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: progressPercent.clamp(0.0, 1.0),
              color: Colors.blue,
              backgroundColor: Colors.grey[300],
              minHeight: 10,
            ),
            const SizedBox(height: 20),
            _getCelebrationWidget(),
            ElevatedButton(
              onPressed: _handleCupClick,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text('Add $cupSizeMl mL ($selectedWaterType)'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your Hydration Graph',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            _hydrationGraph(),
            const SizedBox(height: 20),
            const Text(
              'Hydration History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Column(
              children: hydrationHistory.map((entry) {
                return ListTile(
                  leading: const Icon(Icons.history, color: Colors.blue),
                  title: Text(
                    entry,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
