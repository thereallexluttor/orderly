import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:orderly/homepage/ProductPurchase/ProductChat/ProductChat.dart';

class ChatInfoScreen extends StatefulWidget {
  @override
  _ChatInfoScreenState createState() => _ChatInfoScreenState();
}

class _ChatInfoScreenState extends State<ChatInfoScreen> {
  TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    super.dispose();
  }

  _onSearchTextChanged() {
    setState(() {
      _searchText = _searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _getUserChatInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No chat info found.'));
          } else {
            var chatInfo = snapshot.data!.data() as Map<String, dynamic>?;
            if (chatInfo == null || chatInfo.isEmpty) {
              return Center(child: Text('No chat info found.'));
            }
            var chatInfoMap = chatInfo['chatInfo'] as Map<String, dynamic>;

            // Convertimos y ordenamos las entradas por la variable `hora`
            var sortedChatInfo = chatInfoMap.entries.toList();
            sortedChatInfo.sort((a, b) {
              var aTime = (a.value['hora'] as Timestamp).toDate();
              var bTime = (b.value['hora'] as Timestamp).toDate();
              return bTime.compareTo(aTime); // Orden descendente
            });

            // Filtramos los resultados en función del texto de búsqueda
            var filteredChatInfo = sortedChatInfo.where((entry) {
              var value = entry.value as Map<String, dynamic>;
              var nombre = value['nombre'] as String;
              return nombre.toLowerCase().contains(_searchText.toLowerCase());
            }).toList();

            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: "Search",
                      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredChatInfo.length,
                    itemBuilder: (context, index) {
                      var entry = filteredChatInfo[index];
                      var key = entry.key;
                      var value = entry.value as Map<String, dynamic>;
                      var messageTime = (value['hora'] as Timestamp).toDate();

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(value['foto_producto']),
                          ),
                          title: Text(
                            value['nombre'],
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            value['mensaje'],
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 14,
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
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Future<DocumentSnapshot> _getUserChatInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userDocRef = FirebaseFirestore.instance
          .collection('Orderly')
          .doc('Users')
          .collection('users')
          .doc(user.uid);
      return await userDocRef.get();
    }
    throw FirebaseAuthException(
      code: 'USER_NOT_LOGGED_IN',
      message: 'User not logged in',
    );
  }
}
