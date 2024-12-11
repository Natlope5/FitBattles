import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

class CaloriesPage extends StatefulWidget {
  final String userId;

  const CaloriesPage({super.key, required this.userId});

  @override
  CaloriesPageState createState() => CaloriesPageState();
}

class CaloriesPageState extends State<CaloriesPage> {
  late final String userId;

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    _loadSavedData();
  }

  int totalCaloriesConsumed = 0;
  int totalCaloriesBurned = 0;
  int averageDailyBurnedCalories = 1000; // Default value, can be updated
  int daysAsMember = 35; // Default value, can be updated
  int goalCalories = 2000;
  int caloriesBurnedThisWeek = 500;

  final TextEditingController _consumedController = TextEditingController();
  final TextEditingController _burnedController = TextEditingController();

  // Load saved data from SharedPreferences
  Future<void> _loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      totalCaloriesConsumed = prefs.getInt('totalCaloriesConsumed') ?? 0;
      totalCaloriesBurned = prefs.getInt('totalCaloriesBurned') ?? 0;
      averageDailyBurnedCalories = prefs.getInt('averageDailyBurnedCalories') ?? 1000;
      daysAsMember = prefs.getInt('daysAsMember') ?? 35;
      goalCalories = prefs.getInt('goalCalories') ?? 2000;
    });
  }

  // Save data to SharedPreferences
  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('totalCaloriesConsumed', totalCaloriesConsumed);
    prefs.setInt('totalCaloriesBurned', totalCaloriesBurned);
    prefs.setInt('averageDailyBurnedCalories', averageDailyBurnedCalories);
    prefs.setInt('daysAsMember', daysAsMember);
    prefs.setInt('goalCalories', goalCalories);
  }

  void _addConsumedCalories() {
    final consumedValue = int.tryParse(_consumedController.text);
    if (consumedValue != null) {
      setState(() {
        totalCaloriesConsumed += consumedValue;
      });
      _saveData(); // Save the updated data
    } else {
      // Print a debug statement if the value is invalid
      logger.i("Invalid consumed calories input");
    }
    _consumedController.clear();
  }

  void _addBurnedCalories() {
    final burnedValue = int.tryParse(_burnedController.text);
    if (burnedValue != null) {
      setState(() {
        totalCaloriesBurned += burnedValue;
      });
      _saveData(); // Save the updated data
    } else {
      // Print a debug statement if the value is invalid
      logger.i("Invalid burned calories input");
    }
    _burnedController.clear();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate net calories based on the updated values
    int netCalories = totalCaloriesConsumed - totalCaloriesBurned;

    // Recalculate the total calories burned since member update
    int totalCaloriesBurnedSinceMember = averageDailyBurnedCalories * daysAsMember;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calories Tracker', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(title: "Calories Consumed", value: totalCaloriesConsumed, icon: Icons.fastfood, color: Colors.orangeAccent),
            _buildSummaryCard(title: "Calories Burned", value: totalCaloriesBurned, icon: Icons.local_fire_department, color: Colors.greenAccent),
            _buildSummaryCard(
              title: "Net Calories",
              value: netCalories,
              icon: Icons.calculate,
              color: netCalories >= 0 ? Colors.blueAccent : Colors.redAccent,
            ),
            const Divider(height: 30, thickness: 2),
            _buildInfoCard(
              icon: Icons.local_fire_department_outlined,
              title: "Total Calories Burned (Since Member)",
              subtitle: "$totalCaloriesBurnedSinceMember kcal",
            ),
            _buildInfoCard(icon: Icons.flag, title: "Weekly Goal", subtitle: "Burn $goalCalories kcal", isGoal: true, onPlusPressed: _showGoalInputDialog),
            const SizedBox(height: 20),
            _buildInputSection(),
            const SizedBox(height: 30),
            Center(child: Text('Stay on track! Log your calories regularly.', style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor, fontStyle: FontStyle.italic))),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color.fromRGBO(
            color.r.toInt(), // Cast .r (double) to int
            color.g.toInt(), // Cast .g (double) to int
            color.b.toInt(), // Cast .b (double) to int
            0.2, // Set the opacity value (0.2 for 20% opacity)
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        trailing: Text('$value kcal', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isGoal = false,
    VoidCallback? onPlusPressed,
  }) {
    // Get the current theme mode (light or dark)
    Color iconColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Theme.of(context).primaryColor;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.black54)),
        trailing: isGoal
            ? IconButton(icon: const Icon(Icons.add_circle_outline, color: Colors.green), onPressed: onPlusPressed)
            : null,
      ),
    );
  }

  void _showGoalInputDialog() {
    final TextEditingController goalController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Weekly Goal'),
          content: TextField(controller: goalController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Enter new goal (kcal)', border: OutlineInputBorder())),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(onPressed: () {
              setState(() {
                goalCalories = int.tryParse(goalController.text) ?? goalCalories;
              });
              _saveData(); // Save the updated goal
              Navigator.pop(context);
            }, child: const Text('Save')),
          ],
        );
      },
    );
  }

  Widget _buildInputSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const Text('Log Your Calories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(thickness: 1),
            _buildInputField(controller: _consumedController, label: 'Calories Consumed', icon: Icons.restaurant),
            const SizedBox(height: 10),
            _buildActionButton('Add Consumed Calories', _addConsumedCalories),
            const SizedBox(height: 20),
            _buildInputField(controller: _burnedController, label: 'Calories Burned', icon: Icons.directions_run),
            const SizedBox(height: 10),
            _buildActionButton('Add Burned Calories', _addBurnedCalories),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({required TextEditingController controller, required String label, required IconData icon}) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: TextStyle(color: Colors.black),  // Ensuring text color is black
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[200], // Different background color for dark mode
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2), borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
