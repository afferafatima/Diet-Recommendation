import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ActivityScreen(),
    );
  }
}

class ActivityScreen extends StatefulWidget {
  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  int _selectedIndex = 0;

  // List of screens for bottom navigation
  static List<Widget> _widgetOptions = <Widget>[
    ActivityContent(), // Activity screen content
    Center(child: Text('Diet Screen')),
    Center(child: Text('Profile Screen')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_dining),
            label: 'Diet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF78BC45), // Set selected item color
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

class ActivityContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20), // Spacing

          // Logo at the top
          Center(
            child: Image.asset(
              'assets/images/logo.png', // Replace with your logo image path
              height: 200, // Set the height of the logo
            ),
          ),

          Center(
            child: Text(
              'Weight Goal: Lose Weight',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF78BC45),
              ),
            ),
          ),

          SizedBox(height: 20), // Spacing
          Center(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: CircularProgressIndicator(
                        value: 0.75, // Adjust for actual calorie percentage
                        strokeWidth: 12,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF78BC45), // Green color for calories
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '540 kcal',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text('of 700 kcal'),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  'Calorie Count',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          SizedBox(height: 20), // Spacing

          // Macronutrient Breakdown
          Text(
            'Macronutrients',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildNutritionCard(
                  'Protein', '200g', Icons.restaurant, Colors.green),
              buildNutritionCard(
                  'Carbs', '100g', Icons.local_pizza, Colors.blue),
              buildNutritionCard('Fats', '50g', Icons.apple, Colors.orange),
            ],
          ),

          SizedBox(height: 60), // Spacing

          // Button to get diet plan
          Center(
            child: SizedBox(
              height: 50, // Set your desired height here
              child: ElevatedButton(
                onPressed: () {
                  // Add your diet plan logic here
                  print('Get Diet Plan');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF78BC45), // Button color
                ),
                child: Text('Get Diet Plan',
                    style: TextStyle(color: Colors.black, fontSize: 15)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget for individual nutrition cards
  Widget buildNutritionCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      width: 100,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
          Text(label, style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
