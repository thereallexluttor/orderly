// ignore_for_file: file_names, unused_local_variable

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';
import 'chat_service.dart';
import 'image_service.dart';
import 'dart:convert';

class ProductChat extends StatefulWidget {
  final Map<String, dynamic> itemData;

  const ProductChat(this.itemData, {super.key});

  @override
  _ProductChatState createState() => _ProductChatState();
}

class _ProductChatState extends State<ProductChat> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  final AuthService _authService = AuthService();
  final ChatService _chatService = ChatService();
  final ImageService _imageService = ImageService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          widget.itemData['nombre'],
          style: const TextStyle(fontFamily: "Poppins", fontSize: 13),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: _chatService.getChatStream(widget.itemData['ruta_chat']),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var chatData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
                var userMessages = chatData[_authService.currentUser?.uid] ?? {};
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
                    var base64Image = messageData['image'];
                    var userType = messageData['user'];
                    var timestamp = messageData['timestamp'] != null ? (messageData['timestamp'] as Timestamp).toDate() : DateTime.now();
                    var formattedTime = "${timestamp.hour}:${timestamp.minute} ${timestamp.day}/${timestamp.month}/${timestamp.year}";

                    bool isCustomer = userType == 'Customer';

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
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            crossAxisAlignment: isCustomer ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              if (base64Image != null)
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FullScreenImage(base64Image: base64Image),
                                      ),
                                    );
                                  },
                                  child: Image.memory(base64Decode(base64Image)),
                                ),
                              if (message != null)
                                Text(
                                  message,
                                  style: const TextStyle(fontFamily: "Poppins", fontSize: 12),
                                ),
                              Text(formattedTime, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      height: 50,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: _sendImage,
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'Escribe tu mensaje',
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
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
    var user = _authService.currentUser;
    if (user == null) return;

    var messageText = _controller.text;
    _controller.clear();

    var messageData = {
      'message': messageText,
      'timestamp': FieldValue.serverTimestamp(),
      'user': 'Customer',
    };

    await _chatService.sendMessage(widget.itemData['ruta_chat'], user.uid, messageData);
    _scrollToBottom();
  }

  void _sendImage() async {
    var user = _authService.currentUser;
    if (user == null) return;

    var base64Image = await _imageService.pickImageAndConvertToBase64();
    if (base64Image == null) return;

    var messageData = {
      'image': base64Image,
      'timestamp': FieldValue.serverTimestamp(),
      'user': 'Customer',
    };

    await _chatService.sendMessage(widget.itemData['ruta_chat'], user.uid, messageData);
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
}

class FullScreenImage extends StatelessWidget {
  final String base64Image;

  const FullScreenImage({Key? key, required this.base64Image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Image.memory(base64Decode(base64Image)),
      ),
    );
  }
}

