import 'package:flutter/material.dart';

class OrderlyAi extends StatefulWidget {
  const OrderlyAi({super.key});

  @override
  _OrderlyAiState createState() => _OrderlyAiState();
}

class _OrderlyAiState extends State<OrderlyAi> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];

  void _sendMessage(String text) {
    if (text.isNotEmpty) {
      setState(() {
        _messages.add({'user': text});
      });
      _controller.clear();
      _sendToAi(text);
    }
  }

  void _sendToAi(String userMessage) {
    // Simula una respuesta de la IA después de un pequeño retraso.
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add({'ai': 'Esto es una respuesta simulada de la IA para: $userMessage'});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message.containsKey('user');
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.purple[200] : Colors.yellow[200],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(15),
                        topRight: const Radius.circular(15),
                        bottomLeft: isUser ? const Radius.circular(15) : const Radius.circular(0),
                        bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(15),
                      ),
                    ),
                    child: Text(
                      isUser ? message['user']! : message['ai']!,
                      style: const TextStyle(
                        fontSize: 10,
                        fontFamily: 'Poppins', // Usando la fuente Poppins
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      hintStyle: const TextStyle(
                        fontFamily: 'Poppins', // Fuente para el texto de pista
                        fontSize: 12
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Poppins', // Fuente para el texto del campo
                      fontSize: 12,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(_controller.text),
                  color: Colors.deepPurple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
