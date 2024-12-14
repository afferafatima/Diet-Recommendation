import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FinalPageScreen extends StatefulWidget {
  @override
  _FinalPageScreenState createState() => _FinalPageScreenState();
}

class _FinalPageScreenState extends State<FinalPageScreen> {
  late double height;
  late double weight;
  late double age;
  late String gender;
  late String activityLevel;
  late String allergies;
  late String firstName;
  late String lastName;
  late String email;
  late String password;

  // Controllers for each text field
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _activityLevelController =
      TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Gender selection
  String _selectedGender = "Male"; // default gender

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Fetching the arguments passed from the previous screen
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    // Initializing the text controllers with the passed data
    height = args['height'];
    weight = args['weight'];
    age = args['age'];
    gender = args['gender'];
    activityLevel = args['activityLevel'];
    allergies = args['allergies'];
    firstName = args['firstName'];
    lastName = args['lastName'];
    email = args['email'];
    password = args['password'];

    _firstNameController.text = firstName;
    _lastNameController.text = lastName;
    _heightController.text = height.toString();
    _weightController.text = weight.toString();
    _ageController.text = age.toString();
    _activityLevelController.text = activityLevel;
    _allergiesController.text = allergies;
    _emailController.text = email;
    _passwordController.text = password;

    // Set gender to selected value
    _selectedGender = gender;
  }

  void _submitData() async {
    final updatedFirstName = _firstNameController.text.trim();
    final updatedLastName = _lastNameController.text.trim();
    final updatedHeight = double.tryParse(_heightController.text) ?? height;
    final updatedWeight = double.tryParse(_weightController.text) ?? weight;
    final updatedAge = double.tryParse(_ageController.text) ?? age;
    final updatedActivityLevel = _activityLevelController.text.trim();
    final updatedAllergies = _allergiesController.text.trim();
    final updatedEmail = _emailController.text.trim();
    final updatedPassword = _passwordController.text.trim();

    // Prepare the data to send to the backend
    final Map<String, dynamic> data = {
      'email': updatedEmail,
      'password': updatedPassword,
      'firstName': updatedFirstName,
      'lastName': updatedLastName,
      'age': updatedAge,
      'weight': updatedWeight,
      'height': updatedHeight,
      'gender': _selectedGender,
      'activityLevel': updatedActivityLevel,
      'foodAllergies': updatedAllergies,
    };

    // Call the API endpoint to save user details
    final response = await http.post(
      Uri.parse('http://localhost:5000/api/saveUserDetails'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User details saved successfully')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to save user details')));
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _ageController.text = pickedDate
            .toString()
            .split(' ')[0]; // Set date as age (could be adjusted to exact age)
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirmation'),
        backgroundColor: Color(0xFF78BC45),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Logo at the top
              Center(
                child: Image.asset(
                  'assets/images/logo.png', // Replace with your logo image path
                  height: 200,
                ),
              ),
              SizedBox(height: 20),

              // Title
              Text(
                'Confirm Your Details:',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF78BC45),
                ),
              ),
              SizedBox(height: 20),

              // Editable fields
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
              ),
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
              ),
              TextField(
                controller: _heightController,
                decoration: InputDecoration(labelText: 'Height (cm)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _weightController,
                decoration: InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _ageController,
                decoration: InputDecoration(labelText: 'Date of Birth'),
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
              Row(
                children: <Widget>[
                  Text('Gender:'),
                  Radio<String>(
                    value: 'Male',
                    groupValue: _selectedGender,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedGender = value!;
                      });
                    },
                  ),
                  Text('Male'),
                  Radio<String>(
                    value: 'Female',
                    groupValue: _selectedGender,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedGender = value!;
                      });
                    },
                  ),
                  Text('Female'),
                ],
              ),
              TextField(
                controller: _activityLevelController,
                decoration: InputDecoration(labelText: 'Activity Level'),
              ),
              TextField(
                controller: _allergiesController,
                decoration: InputDecoration(labelText: 'Food Allergies'),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),

              SizedBox(height: 40), // Spacing before the confirm button

              // Confirm Button
              Center(
                child: ElevatedButton(
                  onPressed: _submitData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF78BC45),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  ),
                  child: Text(
                    'Confirm',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
