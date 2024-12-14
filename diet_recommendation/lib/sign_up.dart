import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Function to handle sign-up
  Future<void> signUp() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();
    final String confirmPassword = confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match!')),
      );
      return;
    }

    // Assuming the sign-up is successful and we want to navigate to the profile screen
    // In a real-world scenario, you'd send a POST request to the backend to save the user data
    // For now, we assume the sign-up is successful.

    // Navigate to the profile page and pass the email and password
    Navigator.pushNamed(
      context,
      '/profile', // The profile page route
      arguments: {
        'email': email,
        'password': password,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Sign Up'),
        backgroundColor: Color(0xFF78BC45), // AppBar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Logo Placeholder
              Container(
                margin: EdgeInsets.only(bottom: 20), // Spacing below the logo
                child: Image.asset(
                  'assets/images/logo.png', // Replace with your logo path
                  height: 200, // Adjust height as needed
                ),
              ),
              Text(
                'Sign Up',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              // Email TextField
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              // Password TextField
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              // Confirm Password TextField
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              // Sign Up Button
              ElevatedButton(
                onPressed: signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF78BC45), // Button background color
                  foregroundColor: Colors.white, // Button text color
                ),
                child: Text('Sign Up'),
              ),
              SizedBox(height: 20),
              Text('Or sign up with'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: FaIcon(FontAwesomeIcons.google),
                    onPressed: () {
                      // Implement Google sign up functionality
                    },
                  ),
                  IconButton(
                    icon: FaIcon(FontAwesomeIcons.facebook),
                    onPressed: () {
                      // Implement Facebook sign up functionality
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signin');
                },
                child: Text('Already have an account? Log in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
