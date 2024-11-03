import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchEventsScreen extends StatefulWidget {
  @override
  _SearchEventsScreenState createState() => _SearchEventsScreenState();
}

class _SearchEventsScreenState extends State<SearchEventsScreen> {
  String _searchQuery = '';
  List<DocumentSnapshot> _events = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _searchEvents() async {
    if (_searchQuery.isNotEmpty) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('title', isGreaterThanOrEqualTo: _searchQuery)
          .where('title', isLessThanOrEqualTo: _searchQuery + '\uf8ff')
          .get();

      setState(() {
        _events = snapshot.docs;
      });
    } else {
      setState(() {
        _events = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search Events"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _searchEvents(); // Perform search whenever the query changes
              },
              decoration: InputDecoration(
                labelText: "Search by Title",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: _events.isNotEmpty
                  ? ListView.builder(
                      itemCount: _events.length,
                      itemBuilder: (context, index) {
                        var event = _events[index];
                        String formattedDate;
                        Timestamp timestamp = event['date'];
                        formattedDate = "${timestamp.toDate().year}-${(timestamp.toDate().month).toString().padLeft(2, '0')}-${(timestamp.toDate().day).toString().padLeft(2, '0')}";

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event['title'],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text("Location: ${event['location']}"),
                                Text("Date: $formattedDate"),
                                SizedBox(height: 10),
                                Text(event['description']),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Center(child: Text("No events found")),
            ),
          ],
        ),
      ),
    );
  }
}
