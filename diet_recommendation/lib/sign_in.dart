import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Function to handle login
  Future<void> login() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email and password are required')),
      );
      return;
    }

    final url = Uri.parse('http://localhost:5000/login'); // Your API endpoint

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Successfully logged in
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );
        // Save JWT token or navigate to another screen
        print('JWT Token: ${responseData['token']}'); // Debugging message
      } else {
        // Handle error response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'Login failed')),
        );
      }
    } catch (e) {
      print('Error during login: $e'); // Debugging message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during login')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Sign In'),
        backgroundColor: Color(0xFF78BC45),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Logo Placeholder
              Container(
                margin: EdgeInsets.only(bottom: 20),
                child: Image.asset(
                  'assets/images/logo.png', // Replace with your logo path
                  height: 200,
                ),
              ),
              Text(
                'Log In',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF78BC45),
                  foregroundColor: Colors.white,
                ),
                child: Text('Log In'),
              ),
              SizedBox(height: 20),
              Text('Or log in with'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: FaIcon(FontAwesomeIcons.google),
                    onPressed: () {
                      // Implement Google login functionality
                    },
                  ),
                  IconButton(
                    icon: FaIcon(FontAwesomeIcons.facebook),
                    onPressed: () {
                      // Implement Facebook login functionality
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: Text('Don’t have an account? Sign up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
