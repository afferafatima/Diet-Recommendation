import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DietPlanScreen(),
    );
  }
}

class DietPlanScreen extends StatefulWidget {
  @override
  _DietPlanScreenState createState() => _DietPlanScreenState();
}

class _DietPlanScreenState extends State<DietPlanScreen> {
  int _selectedIndex = 1; // Start on the Diet Plan screen

  // List of screens for bottom navigation
  static List<Widget> _widgetOptions = <Widget>[
    Center(child: Text('Home Screen')), // Home screen content
    DietPlanContent(), // Diet plan content
    Center(child: Text('Profile Screen')), // Profile screen content
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
      appBar: AppBar(
        title: Text(_selectedIndex == 0
            ? 'Home'
            : _selectedIndex == 1
                ? 'Weekly Diet Plan'
                : 'Profile'),
        backgroundColor: Color(0xFF78BC45),
        leading: _selectedIndex == 1
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop(); // Go back to previous screen
                },
              )
            : null,
      ),
      body: Column(
        children: [
          // Logo at the top
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.asset(
              'assets/images/logo.png', // Path to your logo image
              height: 200, // Adjust size as needed
            ),
          ),
          Expanded(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
        ],
      ),
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
        selectedItemColor:
            Color(0xFF78BC45), // Set selected item color to green
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

class DietPlanContent extends StatelessWidget {
  final List<Map<String, String>> dietPlan = [
    {
      "day": "Monday",
      "breakfast": "Aloo Paratha with Yogurt",
      "lunch": "Chicken Biryani",
      "dinner": "Seekh Kebabs with Raita"
    },
    {
      "day": "Tuesday",
      "breakfast": "Chana Daal with Rice",
      "lunch": "Palak Paneer with Roti",
      "dinner": "Karahi Chicken with Naan"
    },
    {
      "day": "Wednesday",
      "breakfast": "Omelette with Paratha",
      "lunch": "Chickpea Salad (Chole Chaat)",
      "dinner": "Daal Makhani with Roti"
    },
    {
      "day": "Thursday",
      "breakfast": "Halwa Puri",
      "lunch": "Chickpea Salad (Chole Chaat)",
      "dinner": "Fish Curry with Basmati Rice"
    },
    {
      "day": "Friday",
      "breakfast": "Egg Bhurji with Toast",
      "lunch": "Mutton Pulao",
      "dinner": "Vegetable Biryani with Raita"
    },
    {
      "day": "Saturday",
      "breakfast": "Omelette with Paratha",
      "lunch": "Kheer (Rice Pudding)",
      "dinner": "Bun Kebab"
    },
    {
      "day": "Sunday",
      "breakfast": "Lassi with Paratha",
      "lunch": "Paya (Trotter Curry) with Naan",
      "dinner": "Stuffed Bell Peppers with Mince"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 10.0), // Adjust padding here
      child: ListView.builder(
        itemCount: dietPlan.length,
        itemBuilder: (context, index) {
          final dayPlan = dietPlan[index];
          return Card(
            color: Color.fromARGB(255, 199, 239, 169),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 7),
            child: ListTile(
              title: Text(
                dayPlan["day"]!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DayDetailScreen(dayPlan: dayPlan),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class DayDetailScreen extends StatelessWidget {
  final Map<String, String> dayPlan;

  DayDetailScreen({required this.dayPlan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(dayPlan['day']!),
        backgroundColor: Color(0xFF78BC45),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo at the top
              Center(
                child: Image.asset(
                  'assets/images/logo.png', // Path to your logo
                  height: 200,
                ),
              ),
              SizedBox(height: 10), // Adjust this height to reduce space
              _buildMealSection(
                  'Breakfast', dayPlan['breakfast']!, 'Alternate Breakfast'),
              SizedBox(height: 20),
              _buildMealSection('Lunch', dayPlan['lunch']!, 'Alternate Lunch'),
              SizedBox(height: 20),
              _buildMealSection(
                  'Dinner', dayPlan['dinner']!, 'Alternate Dinner'),
              SizedBox(height: 20),
              _buildLikeItButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealSection(
      String mealType, String meal, String alternateLabel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$mealType: $meal',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 20), // Space between meal and alternate buttons
        _buildAlternatesSection(alternateLabel),
      ],
    );
  }

  Widget _buildAlternatesSection(String mealType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20), // Add some space between the title and the button
        Row(
          mainAxisAlignment: MainAxisAlignment.end, // Align to the right
          children: [
            ElevatedButton(
              onPressed: () {
                // Handle alternate option action
              },
              child: Text('$mealType Option'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF78BC45),
                foregroundColor: Colors.black,
                minimumSize: Size(120, 30), // Set minimum width and height
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLikeItButton() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min, // Minimize column size to fit children
        children: [
          SizedBox(height: 50), // Add space above the button
          ElevatedButton(
            onPressed: () {
              // Handle "I Like It" action
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF78BC45),
              padding: EdgeInsets.symmetric(
                  horizontal: 35, vertical: 15), // Adjust padding
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(21),
              ),
            ),
            child: Text(
              'I Like It',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18), // Change text color to white
            ),
          ),
        ],
      ),
    );
  }
}
