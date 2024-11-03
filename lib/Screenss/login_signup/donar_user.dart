import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:good/auth.dart'; // Make sure to import AuthScreen

class DonorAuthForm extends StatefulWidget {
  @override
  _DonorAuthFormState createState() => _DonorAuthFormState();
}

class _DonorAuthFormState extends State<DonorAuthForm> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Save donor information to Firestore
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
          'role': 'donor',
        });

        // Navigate back to the login page after successful signup
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AuthScreen())); // Redirect to AuthScreen

      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Signup failed: ${e.toString()}")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: "Email"),
              validator: (value) => value!.isEmpty ? 'Email is required' : null,
              onSaved: (value) => email = value!,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
              validator: (value) => value!.isEmpty ? 'Password is required' : null,
              onSaved: (value) => password = value!,
            ),
            // Add more fields as needed
            ElevatedButton(
              onPressed: _submit,
              child: Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
