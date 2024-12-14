import 'package:flutter/material.dart';
import 'weightage.dart'; // Correctly import the HeightWeightScreen

class PersonalInfoScreen extends StatefulWidget {
  @override
  _PersonalInfoScreenState createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  DateTime? _selectedDate;
  String? _selectedGender;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  String? email;
  String? password;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Retrieve the email and password from the route arguments
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      email = args['email'];
      password = args['password'];
    }
  }

  // Date picker to select birth date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Save data and navigate to the next screen
  void _saveData() {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _selectedGender == null ||
        _selectedDate == null) {
      // Show a message if any field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please complete all fields.'),
        ),
      );
    } else {
      // Calculate age
      int age = DateTime.now().year - _selectedDate!.year;
      if (DateTime.now().month < _selectedDate!.month ||
          (DateTime.now().month == _selectedDate!.month &&
              DateTime.now().day < _selectedDate!.day)) {
        age--;
      }

      // Navigate to the next screen with data
      Navigator.pushNamed(
        context,
        '/home', // Replace with your actual next page route
        arguments: {
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text, // Pass the full name
          'age': age, // Pass the age
          'gender': _selectedGender!, // Pass the gender
          'email': email, // Pass the email
          'password': password, // Pass the password
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Information'),
        backgroundColor: Color(0xFF78BC45),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Column(
                  children: [
                    Icon(Icons.shield, size: 40, color: Color(0xFF78BC45)),
                    SizedBox(height: 8),
                    Text(
                      'Personal Information',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              // First Name
              Text('First Name', style: TextStyle(fontSize: 14)),
              SizedBox(height: 6),
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'First name',
                  hintStyle: TextStyle(fontSize: 12),
                ),
              ),
              SizedBox(height: 12),
              // Last Name
              Text('Last Name', style: TextStyle(fontSize: 14)),
              SizedBox(height: 6),
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Last name',
                  hintStyle: TextStyle(fontSize: 12),
                ),
              ),
              SizedBox(height: 16),
              // Date Picker
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: _selectedDate == null
                                ? 'DD / MM / YY'
                                : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                            hintStyle: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Gender selection
              Text('Gender', style: TextStyle(fontSize: 14)),
              SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedGender = 'Male';
                      });
                    },
                    child: Container(
                      width: 100,
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedGender == 'Male'
                              ? Colors.green
                              : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: _selectedGender == 'Male'
                            ? Colors.green.shade100
                            : Colors.white,
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.male, color: Colors.black, size: 18),
                            SizedBox(width: 5),
                            Text(
                              'Male',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 25),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedGender = 'Female';
                      });
                    },
                    child: Container(
                      width: 100,
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedGender == 'Female'
                              ? Colors.green
                              : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: _selectedGender == 'Female'
                            ? Colors.green.shade100
                            : Colors.white,
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.female, color: Colors.black, size: 18),
                            SizedBox(width: 5),
                            Text(
                              'Female',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 25),
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF78BC45),
                      ),
                      child: Text(
                        'Next',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
