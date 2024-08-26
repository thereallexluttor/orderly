// ignore_for_file: unused_element, unused_field

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

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
    try {
      await FirebaseFirestore.instance
          .collection('Orderly')
          .doc('Users')
          .collection('users')
          .doc(userId)
          .update({'photo': imageUrl});
      print("Imagen de perfil actualizada exitosamente en Firestore.");
    } catch (e) {
      print("Error al actualizar la imagen de perfil en Firestore: $e");
    }
  }

  Future<void> _updateUserName(String userId, String newName) async {
    try {
      await FirebaseFirestore.instance
          .collection('Orderly')
          .doc('Users')
          .collection('users')
          .doc(userId)
          .update({'name': newName});
      print("Nombre de usuario actualizado exitosamente en Firestore.");
    } catch (e) {
      print("Error al actualizar el nombre de usuario en Firestore: $e");
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      // Subir la imagen a Firebase Storage
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          String fileName = '${user.uid}_${DateTime.now().millisecondsSinceEpoch}';
          Reference storageReference = FirebaseStorage.instance
              .ref()
              .child('profile_images')
              .child(fileName);

          UploadTask uploadTask = storageReference.putFile(_image!);
          await uploadTask.whenComplete(() => null);

          String downloadUrl = await storageReference.getDownloadURL();
          print("URL de descarga obtenida: $downloadUrl");

          // Actualizar la imagen de perfil en Firestore
          await _updateProfileImage(user.uid, downloadUrl);
          setState(() {}); // Refrescar la UI para mostrar la nueva imagen
        } catch (e) {
          print('Error al subir la imagen a Firebase Storage: $e');
        }
      }
    } else {
      print('No se seleccionó ninguna imagen.');
    }
  }

  void _showEditNameDialog(String currentName) {
    TextEditingController _nameController = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Nombre'),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre de usuario',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                String newName = _nameController.text.trim();
                if (newName.isNotEmpty) {
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await _updateUserName(user.uid, newName);
                    setState(() {});  // Refrescar la UI para mostrar el nuevo nombre
                  }
                }
                Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
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
        backgroundColor: Colors.white,
        centerTitle: true,  // Centrar el título
        title: const Text(
          'Información personal 👨🏻',
          style: TextStyle(
              fontFamily: "Poppins", fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Colors.white, // Fondo blanco para la pantalla
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

          return SingleChildScrollView( // Solución para el desbordamiento
            child: Padding(
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
                              : const AssetImage('assets/default_avatar.png')
                          as ImageProvider,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.purple,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.blue,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        userData['name'] ?? 'N/A',
                        style: const TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditNameDialog(userData['name'] ?? ''),
                      ),
                    ],
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
              fontFamily: "Poppins",
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(
                fontFamily: "Poppins",
                fontSize: 12,
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
