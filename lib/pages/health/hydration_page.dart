import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class HydrationPage extends StatefulWidget {
  const HydrationPage({super.key});

  @override
  HydrationPageState createState() => HydrationPageState();
}

class HydrationPageState extends State<HydrationPage> with TickerProviderStateMixin {
  int consumedMl = 1000; // Current water consumed
  final int dailyGoalMl = 4000; // Daily water goal
  final int cupSizeMl = 500; // Size of one cup in mL
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),  // Animation duration for smooth transition
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final int totalCups = (dailyGoalMl / cupSizeMl).ceil();
    final int filledCups = (consumedMl / cupSizeMl).floor();
    final double progressPercent = consumedMl / dailyGoalMl;

    // Update the animation progress based on the consumed amount
    _animationController.value = progressPercent;

    // Get motivational message and smiley face based on progress
    String motivationMessage = '';
    Widget smileyFace = SizedBox.shrink(); // Default to no smiley face

    if (progressPercent == 1.0) {
      motivationMessage = 'Great job, you reached your goal! 😊';
      smileyFace = Icon(Icons.sentiment_very_satisfied, size: 50, color: Colors.green);
    } else if (progressPercent >= 0.8) {
      motivationMessage = 'Almost there, keep it up champ!';
      smileyFace = Icon(Icons.sentiment_very_satisfied, size: 50, color: Colors.orange);
    } else if (progressPercent >= 0.5) {
      motivationMessage = 'You\'re halfway there, keep it up!';
      smileyFace = Icon(Icons.sentiment_neutral, size: 50, color: Colors.yellow);
    } else if (progressPercent > 0.0) {
      motivationMessage = 'You can do it, keep going!';
      smileyFace = Icon(Icons.sentiment_dissatisfied, size: 50, color: Colors.red);
    } else {
      motivationMessage = 'Let\'s get started!';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Today'),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        elevation: 0,
      ),
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: SingleChildScrollView(  // Wrap the body in a SingleChildScrollView
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            // Lottie Animation for Hydration, control the progress with AnimationController
            Center(
              child: Lottie.asset(
                'assets/animations/muscle_cup.json',
                height: 200,
                width: 200,
                alignment: Alignment.center,
                controller: _animationController, // Assign the controller
                repeat: false,
                animate: true,
              ),
            ),
            SizedBox(height: 20),
            Text(
              '$consumedMl mL',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '${(progressPercent * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 20,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '$filledCups/${(dailyGoalMl / cupSizeMl).ceil()} Cups',
              style: TextStyle(
                fontSize: 18,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            Text(
              '$cupSizeMl mL Cups',
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey[500] : Colors.grey[700],
              ),
            ),
            SizedBox(height: 16),
            Text(
              '$dailyGoalMl mL Daily Goal',
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.grey[500] : Colors.grey[700],
              ),
            ),
            SizedBox(height: 16),
            // Motivational message and smiley face
            Text(
              motivationMessage,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 10),
            smileyFace,  // Display smiley face
            SizedBox(height: 16),
            // Cups Row - Now inside a SingleChildScrollView for horizontal scrolling
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(totalCups, (index) {
                  bool isFilled = index < filledCups;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          // Toggle the cup's state when tapped
                          if (isFilled) {
                            consumedMl -= cupSizeMl;  // Remove the cup's water
                          } else if (consumedMl + cupSizeMl <= dailyGoalMl) {
                            consumedMl += cupSizeMl;  // Add the cup's water
                          }
                        });
                      },
                      child: SizedBox(
                        width: 32,  // Set fixed width to prevent overflow
                        height: 32, // Set fixed height to prevent overflow
                        child: Icon(
                          Icons.local_drink,
                          color: isFilled
                              ? (isDarkMode ? Colors.blueAccent : Colors.blue)
                              : (isDarkMode ? Colors.grey[700] : Colors.grey[400]),
                          size: 32,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
