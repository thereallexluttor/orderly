// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class ProductChat extends StatefulWidget {
  final Map<String, dynamic> itemData;

  const ProductChat(this.itemData, {super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProductChatState createState() => _ProductChatState();
}

class _ProductChatState extends State<ProductChat> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isFirstMessage = true;
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _scrollToBottom();
      }
    });
    _checkIfFirstMessage();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _checkIfFirstMessage() async {
    var user = _auth.currentUser;
    if (user != null) {
      var userDocRef = _firestore.collection('Orderly').doc('Users').collection('users').doc(user.uid);
      var userDocSnapshot = await userDocRef.get();
      if (userDocSnapshot.exists) {
        var chatInfo = userDocSnapshot.data()?['chatInfo'] as Map<String, dynamic>? ?? {};
        _isFirstMessage = !chatInfo.values.any((existingChat) {
          return existingChat['nombre'] == widget.itemData['nombre'] &&
                 existingChat['foto_producto'] == widget.itemData['foto_producto'] &&
                 existingChat['ruta_chat'] == widget.itemData['ruta_chat'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.itemData['nombre'],
          style: const TextStyle(fontFamily: "Poppins", fontSize: 13),
        ),
      ),
      body: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(seconds: 1),
        child: Column(
          children: [
            Expanded(
              child: _buildMessageList(),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.doc(widget.itemData['ruta_chat']).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var chatData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
        var userMessages = chatData[_auth.currentUser?.uid] ?? {};
        var sortedKeys = userMessages.keys.toList()..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });

        return ListView.builder(
          controller: _scrollController,
          itemCount: sortedKeys.length,
          itemBuilder: (context, index) {
            var key = sortedKeys[index];
            var messageData = userMessages[key] as Map<String, dynamic>;
            var message = messageData['message'];
            var userType = messageData['user'];
            var timestamp = messageData['timestamp'] != null ? (messageData['timestamp'] as Timestamp).toDate() : DateTime.now();
            var formattedTime = "${timestamp.hour}:${timestamp.minute} ${timestamp.day}/${timestamp.month}/${timestamp.year}";

            bool isCustomer = userType == 'Customer';
            bool isSeller = userType == 'Seller';

            return Align(
              alignment: isCustomer ? Alignment.centerRight : Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    color: isCustomer ? Colors.green[100] : Colors.yellow[100],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: isCustomer ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Text(
                        message,
                        style: const TextStyle(fontFamily: "Poppins", fontSize: 12),),
                      Text(formattedTime, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      height: 50,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              
              decoration: InputDecoration(
                hintText: 'Escribe tu mensaje',
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                hoverColor: Colors.blueAccent,
                fillColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 15,
            backgroundColor: Colors.purple,
            child: IconButton(
              icon: const Icon(Icons.send, size: 15, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;
    var user = _auth.currentUser;
    if (user == null) return;

    var messageText = _controller.text;
    _controller.clear();

    var chatRef = _firestore.doc(widget.itemData['ruta_chat']);
    var snapshot = await chatRef.get();

    if (!snapshot.exists) {
      await chatRef.set({user.uid: {}});
    }

    var userMessages = snapshot.data()? [user.uid] as Map<String, dynamic>? ?? {};
    var messageCount = userMessages.length;
    var messageData = {
      'message': messageText,
      'timestamp': FieldValue.serverTimestamp(),
      'user': 'Customer',
    };
    userMessages[(messageCount + 1).toString()] = messageData;

    await chatRef.update({user.uid: userMessages});

    if (_isFirstMessage) {
      await _updateUserChatInfo(messageText);
      _isFirstMessage = false;
    } else {
      await _updateMessageInUserChatInfo(messageText);
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _updateUserChatInfo(String messageText) async {
    var user = _auth.currentUser;
    if (user == null) return;

    var userDocRef = _firestore.collection('Orderly').doc('Users').collection('users').doc(user.uid);

    var chatData = {
      'nombre': widget.itemData['nombre'],
      'foto_producto': widget.itemData['foto_producto'],
      'ruta_chat': widget.itemData['ruta_chat'],
      'mensaje': messageText,
      'hora': FieldValue.serverTimestamp(),
    };

    var userDocSnapshot = await userDocRef.get();
    if (userDocSnapshot.exists) {
      var chatInfo = userDocSnapshot.data()?['chatInfo'] as Map<String, dynamic>? ?? {};

      // Verificar si los datos ya existen
      bool exists = false;
      chatInfo.forEach((key, existingChat) {
        if (existingChat['nombre'] == chatData['nombre'] &&
            existingChat['foto_producto'] == chatData['foto_producto'] &&
            existingChat['ruta_chat'] == chatData['ruta_chat']) {
          exists = true;
        }
      });

      if (!exists) {
        var chatInfoCount = chatInfo.length;
        chatInfo[(chatInfoCount + 1).toString()] = chatData;
        await userDocRef.update({'chatInfo': chatInfo});
      }
    } else {
      await userDocRef.set({
        'chatInfo': {
          '1': chatData,
        }
      });
    }
  }

  Future<void> _updateMessageInUserChatInfo(String messageText) async {
    var user = _auth.currentUser;
    if (user == null) return;

    var userDocRef = _firestore.collection('Orderly').doc('Users').collection('users').doc(user.uid);

    var userDocSnapshot = await userDocRef.get();
    if (userDocSnapshot.exists) {
      var chatInfo = userDocSnapshot.data()?['chatInfo'] as Map<String, dynamic>? ?? {};

      chatInfo.forEach((key, existingChat) {
        if (existingChat['nombre'] == widget.itemData['nombre'] &&
            existingChat['foto_producto'] == widget.itemData['foto_producto'] &&
            existingChat['ruta_chat'] == widget.itemData['ruta_chat']) {
          existingChat['mensaje'] = messageText;
          existingChat['hora'] = FieldValue.serverTimestamp();
        }
      });

      await userDocRef.update({'chatInfo': chatInfo});
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(home: ProductChat({'nombre': 'Chat', 'ruta_chat': 'chats/your_chat_document', 'foto_producto': 'path_to_product_photo'})));
}
