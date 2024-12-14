import 'package:flutter/material.dart';

class ActivityLevelScreen extends StatefulWidget {
  @override
  _ActivityLevelScreenState createState() => _ActivityLevelScreenState();
}

class _ActivityLevelScreenState extends State<ActivityLevelScreen> {
  String? _selectedActivityLevel = ''; // Nullable for selected activity level
  double? height; // Nullable height
  double? weight; // Nullable weight
  double? age; // Nullable age
  String? gender; // Nullable gender
  String? firstName; // Nullable first name
  String? lastName; // Nullable last name
  String? email;
  String? password;
  // List of activity levels
  final List<Map<String, dynamic>> _activityLevels = [
    {
      'label': '0-2 Days',
      'image': 'assets/images/low_activity.png',
      'description': 'Sedentary',
    },
    {
      'label': '3-4 Days',
      'image': 'assets/images/medium_activity.png',
      'description': 'Light',
    },
    {
      'label': '5 Days',
      'image': 'assets/images/medium_activity.png',
      'description': 'Moderate',
    },
    {
      'label': '6 Days',
      'image': 'assets/images/high_activity.png',
      'description': 'Active',
    },
    {
      'label': '7 Days',
      'image': 'assets/images/high_activity.png',
      'description': 'Very Active ',
    },
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Fetch arguments passed from the previous screen
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      height = args['height'] as double?;
      weight = args['weight'] as double?;
      age = args['age'] as double?;
      gender = args['gender'] as String?;
      firstName = args['firstName'] as String?;
      lastName = args['lastName'] as String?;
      email = args['email'] as String?;
      password = args['password'] as String?;
      // Debug print to verify received arguments
      print('Height: $height cm');
      print('Weight: $weight kg');
      print('Age: $age');
      print('Gender: $gender');
      print('First Name: $firstName');
      print('Last Name: $lastName');
    }
  }

  void _submitData() {
    // Check if the activity level has been selected
    if (_selectedActivityLevel?.isEmpty ?? true) {
      print("Activity level not selected.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an activity level.')),
      );
    } else {
      print("Navigating to allergies screen...");
      try {
        Navigator.pushNamed(
          context,
          '/allergies',
          arguments: {
            'email': email, // Pass the email
            'password': password, // Pass the password
            'height': height,
            'weight': weight,
            'age': age,
            'gender': gender,
            'firstName': firstName,
            'lastName': lastName,
            'activityLevel': _selectedActivityLevel,
          },
        );
        print("Navigation successful");
      } catch (e) {
        print("Error during navigation: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Your Activity Level'),
        backgroundColor: Color(0xFF78BC45),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Image.asset(
                'assets/images/logo.png', // Replace with your logo path
                height: 150,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'How often do you engage in physical activity?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF78BC45),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _activityLevels.length,
                itemBuilder: (context, index) {
                  var activityLevel = _activityLevels[index];
                  bool isSelected =
                      _selectedActivityLevel == activityLevel['description'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedActivityLevel = activityLevel['description'];
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? Colors.green.shade100 : Colors.white,
                        border: Border.all(
                          color: isSelected ? Colors.green : Colors.grey,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            activityLevel['image'],
                            height: 60,
                            width: 60,
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activityLevel['label'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  activityLevel['description'],
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          Radio<String>(
                            value: activityLevel['description'],
                            groupValue: _selectedActivityLevel,
                            onChanged: (value) {
                              setState(() {
                                _selectedActivityLevel = value!;
                              });
                            },
                            activeColor: Colors.green,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF78BC45),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  'Next',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
