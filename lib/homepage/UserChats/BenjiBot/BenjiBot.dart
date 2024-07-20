import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String apiKey;
  final String assistantId;
  final String apiUrl = 'https://api.openai.com/v1/';

  OpenAIService({required this.apiKey, required this.assistantId});

  Future<String> createThread() async {
    final response = await http.post(
      Uri.parse('${apiUrl}threads/create'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['id'];
    } else {
      throw Exception('Failed to create thread');
    }
  }

  Future<String> sendMessageAndGetResponse(String threadId, String content) async {
    // Enviar el mensaje
    await http.post(
      Uri.parse('${apiUrl}threads/$threadId/messages'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'role': 'user',
        'content': content,
      }),
    );

    // Iniciar la ejecución del asistente
    await http.post(
      Uri.parse('${apiUrl}threads/$threadId/runs'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'assistant_id': assistantId,
      }),
    );

    // Obtener los mensajes del hilo
    final response = await http.get(
      Uri.parse('${apiUrl}threads/$threadId/messages'),
      headers: {
        'Authorization': 'Bearer $apiKey',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'][0]['content']['text']['value'];
    } else {
      throw Exception('Failed to get response');
    }
  }
}

class ChatScreen extends StatefulWidget {
  final String apiKey = 'sk-proj-Z5RweYz2YEqASoM0Jw7lT3BlbkFJGNN6BXg62ef3lb4IUsOC';
  final String assistantId = 'asst_IO88pGqRqB0xwwLiuTBiblsb';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  late OpenAIService openAIService;
  String? threadId;

  @override
  void initState() {
    super.initState();
    openAIService = OpenAIService(apiKey: widget.apiKey, assistantId: widget.assistantId);
    _createThread();
  }

  Future<void> _createThread() async {
    try {
      final id = await openAIService.createThread();
      setState(() {
        threadId = id;
      });
    } catch (e) {
      print('Error creating thread: $e');
    }
  }

  Future<String> fetchMessage(String userMessage) async {
    if (threadId == null) {
      await _createThread();
    }

    try {
      return await openAIService.sendMessageAndGetResponse(threadId!, userMessage);
    } catch (e) {
      return 'Error: $e';
    }
  }

  void _sendMessage() async {
    final userMessage = _controller.text;
    if (userMessage.isEmpty) {
      return;
    }

    setState(() {
      _messages.add({'role': 'user', 'content': userMessage});
      _controller.clear();
      _isLoading = true;
    });

    final assistantMessage = await fetchMessage(userMessage);

    setState(() {
      _messages.add({'role': 'assistant', 'content': assistantMessage});
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with BenjiBot'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blueAccent : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      message['content'] ?? '',
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isLoading ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ChatScreen(),
  ));
}
