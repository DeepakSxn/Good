import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:good/Screenss/MainScreen.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKeySignup = GlobalKey<FormState>();
  final _formKeyLogin = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String organizationName = '';
  String registrationNumber = '';
  bool isNGO = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (_formKeySignup.currentState!.validate()) {
      _formKeySignup.currentState!.save();
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Save additional NGO data in Firestore
        if (isNGO) {
          await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
            'email': email,
            'organizationName': organizationName,
            'registrationNumber': registrationNumber,
            'role': 'ngo',
          });
        } else {
          // For donors, you can add different data or just set the role
          await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
            'email': email,
            'role': 'donor',
          });
        }

        // Navigate to the Event Feed after successful signup
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AuthScreen()));
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Signup failed: ${e.toString()}")));
      }
    }
  }

  Future<void> _login() async {
    if (_formKeyLogin.currentState!.validate()) {
      _formKeyLogin.currentState!.save();
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
        // Navigate to Event Feed Screen
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen()));
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login failed: ${e.toString()}")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login/Signup'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Login'),
            Tab(text: 'Signup'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Login Tab
          _buildLoginTab(),

          // Signup Tab
          _buildSignupTab(),
        ],
      ),
    );
  }

  Widget _buildLoginTab() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKeyLogin,
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Email'),
              validator: (value) => value!.isEmpty ? 'Email is required' : null,
              onSaved: (value) => email = value!,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (value) => value!.isEmpty ? 'Password is required' : null,
              onSaved: (value) => password = value!,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignupTab() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKeySignup,
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Email'),
              validator: (value) => value!.isEmpty ? 'Email is required' : null,
              onSaved: (value) => email = value!,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (value) => value!.isEmpty ? 'Password is required' : null,
              onSaved: (value) => password = value!,
            ),
            SwitchListTile(
              title: Text('Are you an NGO?'),
              value: isNGO,
              onChanged: (value) {
                setState(() {
                  isNGO = value;
                });
              },
            ),
            if (isNGO) ...[
              TextFormField(
                decoration: InputDecoration(labelText: 'Organization Name'),
                validator: (value) => value!.isEmpty ? 'Organization name is required' : null,
                onSaved: (value) => organizationName = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Registration Number'),
                validator: (value) => value!.isEmpty ? 'Registration number is required' : null,
                onSaved: (value) => registrationNumber = value!,
              ),
            ],
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signup,
              child: Text('Signup'),
            ),
          ],
        ),
      ),
    );
  }
}
