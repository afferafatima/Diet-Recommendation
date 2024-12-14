import 'package:flutter/material.dart';
import 'first.dart';
import 'sign_up.dart';
import 'sign_in.dart';
import 'weightage.dart';
import 'activity.dart';
import 'profile.dart';
import 'allergies.dart';
import 'final.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Explore App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: '/first',
      routes: {
        '/first': (context) => FrontPage(),
        '/signup': (context) => SignUpScreen(),
        '/signin': (context) => SignInScreen(),
        '/profile': (context) => PersonalInfoScreen(),
        '/home': (context) => HeightWeightScreen(),
        '/activity': (context) => ActivityLevelScreen(),
        '/allergies': (context) => FoodAllergiesScreen(),
        '/final': (context) => FinalPageScreen(),
      },
    );
  }
}
