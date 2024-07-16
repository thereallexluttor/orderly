// ignore_for_file: unused_element, unused_field

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final ImagePicker _picker = ImagePicker();
  File? _image;

  Future<Map<String, dynamic>?> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('Orderly')
        .doc('Users')
        .collection('users')
        .doc(user.uid)
        .get();

    if (userDoc.exists) {
      return userDoc.data() as Map<String, dynamic>?;
    }
    return null;
  }

  Future<void> _updateProfileImage(String userId, String imageUrl) async {
    await FirebaseFirestore.instance
        .collection('Orderly')
        .doc('Users')
        .collection('users')
        .doc(userId)
        .update({'photo': imageUrl});
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      // Simulating an upload process
      await Future.delayed(const Duration(seconds: 2));
      String fakeImageUrl = 'https://via.placeholder.com/150'; // Replace with actual upload logic

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _updateProfileImage(user.uid, fakeImageUrl);
        setState(() {}); // Refresh the UI
      }
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'N/A';
    }
    DateTime date = timestamp.toDate();
    return DateFormat.yMMMMd().add_jm().format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informacion personal 👨🏻',
        style: TextStyle(fontFamily: "Poppins", fontSize: 14, fontWeight: FontWeight.bold),),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No user data found.'));
          }

          Map<String, dynamic> userData = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: userData['photo'] != null
                            ? NetworkImage(userData['photo'])
                            : const AssetImage('assets/default_avatar.png') as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: -10,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, color: Colors.blue),
                          onPressed: _pickImage,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    userData['name'] ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _buildUserInfoRow('Email:', userData['email']),
                _buildDivider(),
                _buildUserInfoRow('Gender:', userData['gender']),
                _buildDivider(),
                _buildUserInfoRow('Phone Number:', userData['phoneNumber']),
                _buildDivider(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserInfoRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey.shade400,
      thickness: 1,
      height: 20,
    );
  }
}
