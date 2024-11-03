import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String organizationName = '';
  String registrationNumber = '';

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserData();
  }

  Future<void> _fetchCurrentUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        email = userDoc['email'];
        organizationName = userDoc['organizationName'] ?? '';
        registrationNumber = userDoc['registrationNumber'] ?? '';
      });
    }
  }

  Future<void> _updateProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'email': email,
        'organizationName': organizationName,
        'registrationNumber': registrationNumber,
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                initialValue: email,
                validator: (value) => value!.isEmpty ? 'Email is required' : null,
                onSaved: (value) => email = value!,
              ),
              if (organizationName.isNotEmpty) ...[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Organization Name'),
                  initialValue: organizationName,
                  onSaved: (value) => organizationName = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Registration Number'),
                  initialValue: registrationNumber,
                  onSaved: (value) => registrationNumber = value!,
                ),
              ],
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _updateProfile();
                  }
                },
                child: Text('Update Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
