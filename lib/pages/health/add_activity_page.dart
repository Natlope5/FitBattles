import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl for date formatting

class AddActivityPage extends StatelessWidget {
  const AddActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get today's date and format it
    String formattedDate = DateFormat('dd MMMM').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5D6C8A), // Dark blue
        title: Text(
          formattedDate, // Display today's date
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: const [
          Icon(Icons.star_border, color: Colors.white),
          SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFE8F0FE), // Light blue
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                hintText: 'Search',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildActivityItem('Running', '300 KCal', Icons.directions_run),
                _buildActivityItem('Cycling', '250 KCal', Icons.pedal_bike),
                _buildActivityItem('Dance', '400 KCal', Icons.sports),
                _buildActivityItem('Yoga', '150 KCal', Icons.self_improvement),
                _buildActivityItem('Weight Lifting', '200 KCal', Icons.fitness_center),
                _buildActivityItem('Swimming', '500 KCal', Icons.pool),
                _buildActivityItem('Aerobics', '450 KCal', Icons.landscape),
                _buildActivityItem('Walking', '180 KCal', Icons.directions_walk),
                _buildActivityItem('Boxing', '600 KCal', Icons.sports_mma),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF85C83E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text('ADD', style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget to build a fitness activity item
  Widget _buildActivityItem(String name, String calories, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF5D6C8A)),
      title: Text(name, style: const TextStyle(fontSize: 18)),
      trailing: Text(calories, style: const TextStyle(fontSize: 16)),
    );
  }
}
