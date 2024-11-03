import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final Timestamp date;
  final String createdBy;
  final String imageUrl;
  final String description;
  final String location;
  final String title;

  Event({
    required this.date,
    required this.createdBy,
    required this.imageUrl,
    required this.description,
    required this.location,
    required this.title,
  });

  // Factory method to create an Event from Firestore Document
  factory Event.fromDocument(DocumentSnapshot doc) {
    return Event(
      date: doc['date'],
      createdBy: doc['createdBy'],
      imageUrl: doc['imageUrl'],
      description: doc['description'],
      location: doc['location'],
      title: doc['title'],
    );
  }
}
