import 'package:flutter/material.dart';

class CaloriesPage extends StatefulWidget {
  const CaloriesPage({super.key, required String userId});

  @override
  CaloriesPageState createState() => CaloriesPageState();
}

class CaloriesPageState extends State<CaloriesPage> {
  // Variables to hold calories data
  int totalCaloriesConsumed = 0;
  int totalCaloriesBurned = 0;

  // Controllers for input fields
  final TextEditingController _consumedController = TextEditingController();
  final TextEditingController _burnedController = TextEditingController();

  // Function to add consumed calories
  void _addConsumedCalories() {
    setState(() {
      totalCaloriesConsumed += int.tryParse(_consumedController.text) ?? 0;
      _consumedController.clear();
    });
  }

  // Function to add burned calories
  void _addBurnedCalories() {
    setState(() {
      totalCaloriesBurned += int.tryParse(_burnedController.text) ?? 0;
      _burnedController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    int netCalories = totalCaloriesConsumed - totalCaloriesBurned;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calories Tracker',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(
              title: "Calories Consumed",
              value: totalCaloriesConsumed,
              icon: Icons.fastfood,
              color: Colors.orangeAccent,
            ),
            const SizedBox(height: 10),
            _buildSummaryCard(
              title: "Calories Burned",
              value: totalCaloriesBurned,
              icon: Icons.local_fire_department,
              color: Colors.greenAccent,
            ),
            const SizedBox(height: 10),
            _buildSummaryCard(
              title: "Net Calories",
              value: netCalories,
              icon: Icons.calculate,
              color: netCalories >= 0 ? Colors.blueAccent : Colors.redAccent,
            ),
            const SizedBox(height: 20),
            _buildInputSection(),
            const Spacer(),
            Center(
              child: Text(
                'Stay on track! Log your calories regularly.',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).hintColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // Widget to build summary cards
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
            color.r.toInt(),
            color.g.toInt(),
            color.b.toInt(),
            0.2, // opacity remains a double
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        trailing: Text(
          '$value kcal',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Input Section for Calories
  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputField(
          controller: _consumedController,
          label: 'Calories Consumed',
          icon: Icons.restaurant,
        ),
        const SizedBox(height: 10),
        _buildActionButton('Add Consumed Calories', _addConsumedCalories),
        const SizedBox(height: 20),
        _buildInputField(
          controller: _burnedController,
          label: 'Calories Burned',
          icon: Icons.directions_run,
        ),
        const SizedBox(height: 10),
        _buildActionButton('Add Burned Calories', _addBurnedCalories),
      ],
    );
  }

  // Custom input field widget
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).iconTheme.color),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).dividerColor, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Custom action button
  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _consumedController.dispose();
    _burnedController.dispose();
    super.dispose();
  }
}
