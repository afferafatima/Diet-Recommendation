import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  final String name = "John Doe";
  final String age = "28";
  final String contact = "+1234567890";
  final String email = "johndoe@example.com";
  final String weight = "60 kg";
  final String height = "165cm ";
  final String gender = "Male";
  final String weightGoal = "Maintain Weight";
  final String healthRestrictions = "None";
  final String activityLevel = "Moderate";
  final String foodRestrictions = "None";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Color(0xFF78BC45),
        elevation: 4,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Handle back button press
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF78BC45),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton(
                      icon:
                          Icon(Icons.edit, color: Color(0xFF78BC45), size: 24),
                      onPressed: () {
                        // Handle edit profile action
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              buildInfoCard(
                context,
                icon: Icons.cake,
                title: 'Age',
                content: age,
              ),
              buildInfoCard(
                context,
                icon: Icons.phone,
                title: 'Contact',
                content: contact,
              ),
              buildInfoCard(
                context,
                icon: Icons.email,
                title: 'Email',
                content: email,
              ),
              buildInfoCard(
                context,
                icon: Icons.male,
                title: 'Gender',
                content: gender,
              ),
              buildInfoCard(
                context,
                icon: Icons.fitness_center,
                title: 'Weight Goal',
                content: weightGoal,
              ),
              buildInfoCard(
                context,
                icon: Icons.straighten,
                title: 'Height',
                content: height,
              ),
              buildInfoCard(
                context,
                icon: Icons.monitor_weight,
                title: 'Weight',
                content: weight,
              ),
              buildInfoCard(
                context,
                icon: Icons.health_and_safety,
                title: 'Health Restrictions',
                content: healthRestrictions,
              ),
              buildInfoCard(
                context,
                icon: Icons.directions_run,
                title: 'Activity Level',
                content: activityLevel,
              ),
              buildInfoCard(
                context,
                icon: Icons.food_bank,
                title: 'Food Restrictions',
                content: foodRestrictions,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build stylish information cards
  Widget buildInfoCard(BuildContext context,
      {required IconData icon,
      required String title,
      required String content}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(
          icon,
          color: Color(0xFF78BC45),
          size: 30,
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          content,
          style: TextStyle(fontSize: 16, color: Colors.grey[800]),
        ),
      ),
    );
  }
}
