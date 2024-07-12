// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:orderly/homepage/ProductPurchase/ProductChat/ProductChat.dart';

class ChatInfoScreen extends StatefulWidget {
  const ChatInfoScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ChatInfoScreenState createState() => _ChatInfoScreenState();
}

class _ChatInfoScreenState extends State<ChatInfoScreen> {
  final String _searchText = "";
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chats',
          style: TextStyle(fontFamily: "Poppins", fontSize: 15),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0), // Altura de la línea
          child: Container(
            color: Colors.purple, // Color de la línea
            height: 4.0, // Grosor de la línea
          ),
        ),
      ),
      backgroundColor: Colors.white, // Establece el color de fondo en blanco
      body: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(seconds: 1),
        child: StreamBuilder<DocumentSnapshot>(
          stream: _getUserChatInfoStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || !snapshot.data!.exists) {
              return Container(); // Devuelve un contenedor vacío si no hay datos o si no existe
            } else {
              var data = snapshot.data!.data();
              if (data == null) {
                return Container(); // Devuelve un contenedor vacío si no hay datos
              }
              var chatInfo = data as Map<String, dynamic>?;
              if (chatInfo == null || chatInfo.isEmpty) {
                return Container(); // Devuelve un contenedor vacío si no hay chat info
              }
              var chatInfoMap = chatInfo['chatInfo'] as Map<String, dynamic>?;

              if (chatInfoMap == null || chatInfoMap.isEmpty) {
                return Container(); // Devuelve un contenedor vacío si no hay chat info map
              }

              // Convertimos y ordenamos las entradas por la variable hora
              var sortedChatInfo = chatInfoMap.entries.toList();
              sortedChatInfo.sort((a, b) {
                var aTime = a.value['hora'] != null
                    ? (a.value['hora'] as Timestamp).toDate()
                    : DateTime.now();
                var bTime = b.value['hora'] != null
                    ? (b.value['hora'] as Timestamp).toDate()
                    : DateTime.now();
                return bTime.compareTo(aTime); // Orden descendente
              });

              // Filtramos los resultados en función del texto de búsqueda
              var filteredChatInfo = sortedChatInfo.where((entry) {
                var value = entry.value as Map<String, dynamic>;
                var nombre = value['nombre'] as String? ?? "";
                return nombre.toLowerCase().contains(_searchText.toLowerCase());
              }).toList();

              if (filteredChatInfo.isEmpty) {
                return Container(); // Devuelve un contenedor vacío si no hay mensajes después del filtro
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredChatInfo.length + 1, // +1 para la card adicional
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Card(
                            elevation: 0,
                            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                              leading: const CircleAvatar(
                                radius: 25,
                                backgroundImage: NetworkImage('https://www.shutterstock.com/image-vector/ai-stars-icon-artificial-intelligence-600nw-2351532151.jpg'),
                              ),
                              title: const Text(
                                'Chat AI',
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Aquí puedes hablar con nuestra IA para búsquedas personalizadas 🥸',
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () {
                                // Acción al hacer tap en la card de Chat AI
                              },
                            ),
                          );
                        } else {
                          var entry = filteredChatInfo[index - 1]; // Restar 1 para los datos originales
                          var key = entry.key;
                          var value = entry.value as Map<String, dynamic>;
                          var messageTime = value['hora'] != null
                              ? (value['hora'] as Timestamp).toDate()
                              : DateTime.now();

                          return Column(
                            children: [
                              Card(
                                color: Colors.white,
                                elevation: 0,
                                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                                  leading: CircleAvatar(
                                    radius: 25,
                                    backgroundImage: CachedNetworkImageProvider(value['foto_producto']),
                                    onBackgroundImageError: (_, __) => const Icon(Icons.image),
                                    child: ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: value['foto_producto'],
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                        errorWidget: (context, url, error) => const Icon(Icons.image),
                                        fadeInDuration: const Duration(milliseconds: 500),
                                        fadeOutDuration: const Duration(milliseconds: 500),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    value['nombre'] ?? '',
                                    style: const TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    value['mensaje'] ?? '',
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: Text(
                                    "${messageTime.hour}:${messageTime.minute.toString().padLeft(2, '0')}",
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProductChat(value),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const Divider(indent: 90, height: 3,), // Divider al final de cada Card
                            ],
                          );
                        }
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Stream<DocumentSnapshot> _getUserChatInfoStream() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userDocRef = FirebaseFirestore.instance
          .collection('Orderly')
          .doc('Users')
          .collection('users')
          .doc(user.uid);
      return userDocRef.snapshots();
    }
    throw FirebaseAuthException(
      code: 'USER_NOT_LOGGED_IN',
      message: 'User not logged in',
    );
  }
}
