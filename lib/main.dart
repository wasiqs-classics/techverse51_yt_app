import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'onboarding.dart'; // Replace with the import path of your home or onboarding page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Techverse 51',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: OnboardingPage(), // Replace with your onboarding page
    );
  }
}
