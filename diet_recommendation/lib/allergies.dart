import 'package:flutter/material.dart';

class FoodAllergiesScreen extends StatefulWidget {
  @override
  _FoodAllergiesScreenState createState() => _FoodAllergiesScreenState();
}

class _FoodAllergiesScreenState extends State<FoodAllergiesScreen> {
  String _allergies = ''; // To store the selected allergies
  late double height; // To store height
  late double weight; // To store weight
  late double age; // To store age
  late String gender; // To store gender
  late String activityLevel; // To store activity level
  late String firstName;
  late String lastName;
  late String email;
  late String password;
  final TextEditingController _allergiesController =
      TextEditingController(); // Controller for allergies input

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Fetch arguments passed from the previous screen
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      height = args['height'] ?? 0.0;
      weight = args['weight'] ?? 0.0;
      age = args['age'] ?? 0.0;
      gender = args['gender'] ?? '';
      activityLevel = args['activityLevel'] ?? '';
      firstName = args['firstName'] ?? 'N/A';
      lastName = args['lastName'] ?? 'N/A';
      email = args['email'] ?? 'N/A';
      password = args['password'] ?? 'N/A';

      // Debug print to verify received arguments
      print('Received arguments in FoodAllergiesScreen:');
      print('Height: $height cm');
      print('Weight: $weight kg');
      print('Age: $age');
      print('Gender: $gender');
      print('Activity Level: $activityLevel');
      print('First Name: $firstName');
      print('Last Name: $lastName');
      print('Email: $email');
      print('Password: $password');
    } else {
      print('No arguments received.');
    }
  }

  void _submitData() {
    final allergies = _allergiesController.text.trim();

    if (allergies.isNotEmpty) {
      setState(() {
        _allergies = allergies;
      });

      print('Selected Food Allergies: $_allergies');

      // Navigate to the next screen with data
      Navigator.pushNamed(
        context,
        '/final', // Replace with your actual next page route
        arguments: {
          'height': height,
          'weight': weight,
          'age': age,
          'gender': gender,
          'activityLevel': activityLevel,
          'firstName': firstName,
          'lastName': lastName,
          'allergies': _allergies,
          'email': email, // Pass the email
          'password': password, // Pass the password
        },
      );
    } else {
      // Show a message if no allergies are entered
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your food allergies.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Allergies'),
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
            // Logo at the top
            Center(
              child: Image.asset(
                'assets/images/logo.png', // Replace with your logo path
                height: 150,
              ),
            ),
            SizedBox(height: 20),

            // Title
            Text(
              'Select Food Items You\'re Allergic To:',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF78BC45),
              ),
            ),
            SizedBox(height: 15),

            // Allergies input field
            Text('Enter ingredients you are allergic to:',
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            TextField(
              controller: _allergiesController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'E.g., Peanuts, Dairy, Gluten',
                hintStyle: TextStyle(fontSize: 14),
              ),
            ),
            Spacer(),

            // Submit Button
            Center(
              child: ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF78BC45),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: Text(
                  'Next',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
