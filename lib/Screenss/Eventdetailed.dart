import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailScreen extends StatelessWidget {
  final DocumentSnapshot event;

  const EventDetailScreen({Key? key, required this.event}) : super(key: key);

  Future<void> _registerForEvent(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You must be logged in to register for an event.")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(event.id)
          .collection('registrations')
          .add({'userId': user.uid, 'timestamp': FieldValue.serverTimestamp()});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Successfully registered for the event!")),
      );
    } catch (e) {
      print("Failed to register: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to register: ${e.toString()}")),
      );
    }
  }

  Future<void> _donate(BuildContext context) async {
    const String upiUrl = 'upi://pay?pa=legand192837-1@oksbi&pn=Your%20Name&mc=1234&tid=transactionid&am=10&cu=INR&tn=Donation%20for%20Event';

    if (await canLaunch(upiUrl)) {
      await launch(upiUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not launch UPI payment app.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Timestamp timestamp = event['date'];
    String formattedDate =
        "${timestamp.toDate().year}-${(timestamp.toDate().month).toString().padLeft(2, '0')}-${(timestamp.toDate().day).toString().padLeft(2, '0')}";

    return Scaffold(
      appBar: AppBar(
        title: Text(event['title']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: event.id,
              child: Image.network(
                event['imageUrl'],
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              (loadingProgress.expectedTotalBytes ?? 1)
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(child: Text('Error loading image'));
                },
              ),
            ),
            SizedBox(height: 16),
            Text(
              event['title'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("Location: ${event['location']}"),
            Text("Date: $formattedDate"),
            SizedBox(height: 16),
            Text(
              event['description'],
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _registerForEvent(context),
              child: Text("Register for Event"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _donate(context),
              child: Text("Donate Now"),
            ),
          ],
        ),
      ),
    );
  }
}
