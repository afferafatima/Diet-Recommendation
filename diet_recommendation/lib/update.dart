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
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "John Doe",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF78BC45),
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.edit, color: Color(0xFF78BC45), size: 24),
                  onPressed: () {
                    // Navigate to UpdateProfileScreen when pressed
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UpdateProfileScreen()),
                    );
                  },
                ),
              ],
            ),
            // Other profile information goes here...
          ],
        ),
      ),
    );
  }
}

class UpdateProfileScreen extends StatefulWidget {
  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  // Pre-filled values for text fields
  final TextEditingController nameController =
      TextEditingController(text: "John Doe");
  final TextEditingController ageController = TextEditingController(text: "28");
  final TextEditingController contactController =
      TextEditingController(text: "+1234567890");
  final TextEditingController emailController =
      TextEditingController(text: "johndoe@example.com");
  final TextEditingController weightController =
      TextEditingController(text: "60 kg");
  final TextEditingController heightController =
      TextEditingController(text: "165cm");

  // Dropdown items for Weight Goal, Health Issues, and Food Allergies
  String selectedWeightGoal = 'Maintain Weight'; // default value
  String selectedHealthIssue = 'None'; // default value
  String selectedFoodAllergy = 'None'; // default value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Profile'),
        backgroundColor: Color(0xFF78BC45),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTextField("Name", nameController),
              buildTextField("Age", ageController),
              buildTextField("Contact", contactController),
              buildTextField("Email", emailController),
              buildTextField("Weight", weightController),
              buildTextField("Height", heightController),
              SizedBox(height: 20),

              // Dropdown for Weight Goal
              buildDropdown(
                'Weight Goal',
                selectedWeightGoal,
                <String>['Maintain Weight', 'Lose Weight', 'Gain Weight'],
                (String? newValue) {
                  setState(() {
                    selectedWeightGoal = newValue!;
                  });
                },
              ),

              SizedBox(height: 20),

              // Dropdown for Health Issues
              buildDropdown(
                'Health Issues',
                selectedHealthIssue,
                <String>['None', 'Diabetes', 'Heart Disease', 'Hypertension'],
                (String? newValue) {
                  setState(() {
                    selectedHealthIssue = newValue!;
                  });
                },
              ),

              SizedBox(height: 20),

              // Dropdown for Food Allergies
              buildDropdown(
                'Food Allergies',
                selectedFoodAllergy,
                <String>[
                  'None',
                  'Peanut Allergy',
                  'Lactose Intolerance',
                  'Gluten Allergy'
                ],
                (String? newValue) {
                  setState(() {
                    selectedFoodAllergy = newValue!;
                  });
                },
              ),

              SizedBox(height: 30),

              // Update Profile button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Handle update action here
                  },
                  child: Text('Update Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF78BC45),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Text Field Widget
  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF78BC45), width: 2),
          ),
        ),
      ),
    );
  }

  // Dropdown Menu Widget
  Widget buildDropdown(String label, String value, List<String> options,
      ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF78BC45), width: 2),
            ),
          ),
          icon: Icon(Icons.arrow_downward, color: Color(0xFF78BC45)),
          items: options.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
