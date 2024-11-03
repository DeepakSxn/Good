import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:good/auth.dart';
import 'package:good/Screenss/login_signup/onboarding.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Event App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: OnboardingScreen(), // Set SplashScreen as the home widget
    );
  }
}
