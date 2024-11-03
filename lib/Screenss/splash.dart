import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:good/Screenss/MainScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:good/auth.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    // Simulate a loading delay for the splash screen
    await Future.delayed(Duration(seconds: 2));

    // Check if user is logged in
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // If user is logged in, retrieve user role from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      String role = userDoc['role'] ?? 'donor'; // Default to 'donor' if role is not set

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MainScreen(
           
          ),
        ),
      );
    } else {
      // If not logged in, navigate to Auth Screen or Login Page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => AuthScreen(), // Replace with your auth screen
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(), // Loading indicator
            SizedBox(height: 20),
            Text("Initializing..."),
          ],
        ),
      ),
    );
  }
}
