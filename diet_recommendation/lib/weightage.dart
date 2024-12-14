import 'package:flutter/material.dart';

class HeightWeightScreen extends StatefulWidget {
  @override
  _HeightWeightScreenState createState() => _HeightWeightScreenState();
}

class _HeightWeightScreenState extends State<HeightWeightScreen> {
  double _height = 170; // Default height in cm
  double _weight = 70; // Default weight in kg
  late double age; // To store age
  late String gender; // To store gender
  late String firstName;
  late String lastName;
  late String email;
  late String password;
  // This method will be called when the screen is first initialized.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Extract arguments passed to this screen
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    email = args['email'];
    password = args['password'];

    age = args['age'];
    gender = args['gender'];
    firstName = args['firstName'];
    lastName = args['lastName'];
  }

  void _submitData() {
    // Pass data to the next screen
    Navigator.pushNamed(
      context,
      '/activity', // Correct route to navigate
      arguments: {
        'height': _height,
        'weight': _weight,
        'firstName': firstName,
        'lastName': lastName,
        'age': age, // Pass age
        'gender': gender, // Pass gender
        'email': email, // Pass the email
        'password': password, // Pass the password
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Height, Weight, Age & Gender'),
        backgroundColor: Color(0xFF78BC45),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Image.asset(
              'assets/images/logo.png',
              height: 200,
            ),
          ),
          Text(
            'Enter Your Height, Weight, Age, and Gender',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),
          // Height Slider
          Text(
            'Height: ${_height.toStringAsFixed(0)} cm',
            style: TextStyle(fontSize: 18),
          ),
          Slider(
            value: _height,
            min: 100,
            max: 250,
            divisions: 150,
            label: _height.round().toString(),
            activeColor: Color(0xFF78BC45),
            inactiveColor: Colors.grey[300],
            onChanged: (value) {
              setState(() {
                _height = value;
              });
            },
          ),
          SizedBox(height: 30),
          // Weight Slider
          Text(
            'Weight: ${_weight.toStringAsFixed(0)} kg',
            style: TextStyle(fontSize: 18),
          ),
          Slider(
            value: _weight,
            min: 30,
            max: 200,
            divisions: 170,
            label: _weight.round().toString(),
            activeColor: Color(0xFF78BC45),
            inactiveColor: Colors.grey[300],
            onChanged: (value) {
              setState(() {
                _weight = value;
              });
            },
          ),
          SizedBox(height: 30),
          // Next Button
          ElevatedButton(
            onPressed: _submitData,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF78BC45),
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            child: Text(
              'Next',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
