// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:orderly/homepage/ProductPurchase/ProductChat/ProductChat.dart';

class ChatInfoScreen extends StatefulWidget {
  const ChatInfoScreen({super.key});

  @override
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
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Chats 📨',
          style: TextStyle(fontFamily: "Poppins", fontSize: 13, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
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
                return _buildNoConversationsUI(); // Devuelve el UI de no conversaciones
              }
              var chatInfoMap = chatInfo['chatInfo'] as Map<String, dynamic>?;

              if (chatInfoMap == null || chatInfoMap.isEmpty) {
                return _buildNoConversationsUI(); // Devuelve el UI de no conversaciones
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

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredChatInfo.length,
                      itemBuilder: (context, index) {
                        var entry = filteredChatInfo[index];
                        var key = entry.key;
                        var value = entry.value as Map<String, dynamic>;
                        var messageTime = value['hora'] != null
                            ? (value['hora'] as Timestamp).toDate()
                            : DateTime.now();

                        // Condicional para mostrar mensaje_vendedor si no está vacío, de lo contrario mostrar mensaje
                        String subtitleText = (value['mensaje_vendedor'] != null && value['mensaje_vendedor'].isNotEmpty)
                            ? value['mensaje_vendedor']
                            : (value['mensaje'] ?? '');

                        return Column(
                          children: [
                            Card(
                              color: Colors.white,
                              elevation: 0,
                              margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                                leading: Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 20, // Reducir el tamaño de la imagen
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
                                    if (value['mensaje_vendedor'] != null && value['mensaje_vendedor'].isNotEmpty)
                                      Positioned(
                                        top: -6,
                                        right: 0,
                                        child: Container(
                                          padding: EdgeInsets.all(5), // Tamaño de la notificación ajustado
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            '!',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12, // Tamaño de la fuente ajustado
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                title: Text(
                                  value['nombre'] ?? '',
                                  style: const TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 9, // Tamaño de la fuente reducido
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  subtitleText,
                                  style: TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 9, // Tamaño de la fuente reducido
                                    color: Colors.grey[600],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Text(
                                  "${messageTime.hour}:${messageTime.minute.toString().padLeft(2, '0')}",
                                  style: TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 10, // Tamaño de la fuente reducido
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
                            const Divider(indent: 0, height: 1), // Divider al final de cada Card
                          ],
                        );
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

  Widget _buildNoConversationsUI() {
    return Container(
      child: Center(
        child: Text(
          'No hay conversaciones',
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: 12,
            color: Colors.grey,
          ),
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
