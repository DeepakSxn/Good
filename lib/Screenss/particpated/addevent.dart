import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class AddEventScreen extends StatefulWidget {
  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  String location = '';
  DateTime? date; // Selected event date
  File? _imageFile;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  static Future<String?> uploadImageToCloudinary(File imageFile) async {
    final cloudinaryUrl = "https://api.cloudinary.com/v1_1/your_cloud_name/image/upload";
    final uploadPreset = "your_upload_preset";

    final request = http.MultipartRequest("POST", Uri.parse(cloudinaryUrl))
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath("file", imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);
      return jsonResponse["secure_url"];
    } else {
      print("Failed to upload image to Cloudinary: ${response.statusCode}");
      return null;
    }
  }

  Future<void> _submitEvent() async {
    if (_formKey.currentState!.validate() && date != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        _formKey.currentState!.save();
        String? imageUrl;

        // Upload image if selected
        if (_imageFile != null) {
          imageUrl = await compute(uploadImageToCloudinary, _imageFile!);
        }

        // Store event details in Firestore
        await FirebaseFirestore.instance.collection('events').add({
          'title': title,
          'description': description,
          'date': Timestamp.fromDate(date!), // Convert date to Firestore Timestamp
          'location': location,
          'imageUrl': imageUrl,
          'createdBy': 'user_id', // Replace with actual user ID
        });

        Navigator.pop(context); // Go back to the previous screen after submission
      } catch (e) {
        print("Error creating event: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to create event. Please try again.")),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields and select a date")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Event"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: "Title"),
                      validator: (value) => value!.isEmpty ? "Title is required" : null,
                      onSaved: (value) => title = value!,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Description"),
                      validator: (value) => value!.isEmpty ? "Description is required" : null,
                      onSaved: (value) => description = value!,
                      maxLines: 3,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Location"),
                      validator: (value) => value!.isEmpty ? "Location is required" : null,
                      onSaved: (value) => location = value!,
                    ),
                    ListTile(
                      title: Text(date == null ? "Select Date" : "Date: ${date!.toLocal()}"),
                      trailing: Icon(Icons.calendar_today),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            date = pickedDate;
                          });
                        }
                      },
                    ),
                    if (_imageFile != null) Image.file(_imageFile!),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: Text("Pick Event Image"),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitEvent,
                      child: Text("Create Event"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
