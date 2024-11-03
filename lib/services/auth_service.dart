import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> signUpUser(String email, String password) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Additional user-related data can be stored in Firestore if needed
    print('User registered: ${userCredential.user?.uid}');
  } catch (e) {
    print('Failed to register user: $e');
  }
}
Future<void> signUpNgo(String email, String password, String ngoName) async {
  try {
    UserCredential ngoCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    print('NGO registered: ${ngoCredential.user?.uid}');
    // Store additional NGO data in Firestore
  } catch (e) {
    print('Failed to register NGO: $e');
  }
}


Future<void> saveUserData(String uid, Map<String, dynamic> data) async {
  await FirebaseFirestore.instance.collection('users').doc(uid).set(data);
}

Future<void> saveNgoData(String uid, Map<String, dynamic> data) async {
  await FirebaseFirestore.instance.collection('ngos').doc(uid).set(data);
}
Future<void> login(String email, String password) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    print('Logged in: ${userCredential.user?.uid}');
  } catch (e) {
    print('Failed to log in: $e');
  }
}
