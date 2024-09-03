import 'package:flutter/material.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../../StoreHomePage/StoreItemCard.dart';  // Importa tu widget StoreItemCard desde su ruta

class ChatScreen extends StatefulWidget {
  final String apiKey =
      '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';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messageJsons = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  late OpenAI openAI;
  String? jsonContextText;

  @override
  void initState() {
    super.initState();
    openAI = OpenAI.instance.build(
      token: widget.apiKey,
      baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 12)),
      enableLog: true,
    );
    _loadJsonContext();
  }

  Future<void> _loadJsonContext() async {
    try {
      final String response = await rootBundle.loadString('lib/assets/items_data.json');
      final data = json.decode(response) as List<dynamic>;

      final List<String> itemsAsText = data.map((item) {
        return '''
        Producto: ${item['nombre']}
        Categoría: ${item['category']}
        Especificaciones: ${item['especificaciones']}
        Compatible con: ${item['compatible']}
        Precio: ${item['precio']}
        Valoración: ${item['valoracion']}
        Ventas: ${item['ventas']}
        Stock: ${item['stock']}
        Descuento: ${item['discount']}
        Cashback: ${item['cash_back']}
        Reviews: ${item['reviews']}
        Foto del producto: ${item['foto_producto']}
        ''';
      }).toList();

      setState(() {
        jsonContextText = itemsAsText.join('\n\n');
      });

      print("Contexto JSON cargado correctamente.");
    } catch (e) {
      print('Error cargando el contexto JSON: $e');
    }
  }

  Future<String> _classifyMessageWithGPT(String userMessage) async {
    print("Clasificando el mensaje del usuario...");

    final List<Map<String, String>> messages = [
      {
        'role': 'system',
        'content':
        'Eres un asistente de chatbot. Clasifica el mensaje del usuario como "conversación casual" o "solicitud de productos".'
            ' Si el mensaje incluye palabras como "tienes", "vendes", o menciona productos específicos, clasifícalo como solicitud de productos.'
      },
      {
        'role': 'user',
        'content': userMessage,
      }
    ];

    final request = ChatCompleteText(
      messages: messages,
      maxToken: 1000,
      model: Gpt4oMiniChatModel(),
    );

    final response = await openAI.onChatCompletion(request: request);
    final classification =
        response?.choices.first.message?.content.toLowerCase().trim() ??
            'conversación casual';

    print("Clasificación del mensaje: $classification");
    return classification;
  }

  String cleanJsonResponse(String response) {
    print("Limpiando la respuesta JSON...");
    response = response.replaceAll(RegExp(r'```json'), '');
    response = response.replaceAll(RegExp(r'```'), '');
    return response.trim();
  }

  List<Map<String, dynamic>>? extractJsonFromResponse(String assistantMessage) {
    print("Intentando extraer JSON de la respuesta...");

    // Validación básica para asegurarse de que el JSON es completo
    if (assistantMessage.contains('[') && assistantMessage.contains(']')) {
      final jsonStart = assistantMessage.indexOf('[');
      final jsonString = assistantMessage.substring(jsonStart);

      try {
        final List<dynamic> jsonObject = json.decode(jsonString);
        return jsonObject.map((item) => item as Map<String, dynamic>).toList();
      } catch (e) {
        print('Error al analizar el JSON: $e');
        return null;
      }
    } else {
      print('No se encontró un JSON completo en la respuesta.');
      return null;
    }
  }

  Future<String?> _generateFollowUpText(
      String userMessage, List<Map<String, dynamic>> products) async {
    print("Generando texto de seguimiento...");

    final List<Map<String, String>> messages = [
      {
        'role': 'system',
        'content':
        'Eres un asistente de ventas que acaba de mostrar algunos productos. da informacion corta y consisa. no des textos largos, prefiero textos cortos y consisos.'

            '\n\nAquí están los productos disponibles que usaras como contexto para tus respuestas pero, no usaras esta informacion para responder con grandes textos. estas tratando de vender, por tanto '
            'tus respuestas son cortas y muy claras. no divages. tambien ten en cuenta los elementos como los descuentos que pueden incidir en el precio real del producto.'
            ':\n\n$jsonContextText'
      },
      {
        'role': 'user',
        'content':
        'Los productos mostrados fueron: ${products.map((p) => p['nombre']).join(', ')}. '
      },
      {
        'role': 'user',
        'content': userMessage,
      }
    ];

    final request = ChatCompleteText(
      messages: messages,
      maxToken: 500,
      model: Gpt4oMiniChatModel(),
    );

    final response = await openAI.onChatCompletion(request: request);
    return response?.choices.first.message?.content;
  }

  void _sendMessage() async {
    final userMessage = _controller.text;
    if (userMessage.isEmpty || jsonContextText == null) {
      print("Mensaje del usuario vacío o contexto JSON no cargado.");
      return;
    }

    // Ocultar el teclado al enviar un mensaje
    FocusScope.of(context).unfocus();

    setState(() {
      _controller.clear();
      _isLoading = true;
    });

    try {
      final classification = await _classifyMessageWithGPT(userMessage);

      List<Map<String, String>> messages;

      if (classification.contains('solicitud de productos')) {
        print("Generando mensaje del sistema para solicitud de productos...");
        messages = [
          {
            'role': 'system',
            'content':
            'Eres un asistente de ventas. Si la pregunta del usuario es sobre un producto específico o alguna consulta general, su nombre, categoría, o un filtro como precio, responde en formato JSON siguiendo este formato: '
                '[{ "nombre": "Nombre del Producto", "category": "Categoría", "especificaciones": "Especificaciones detalladas", "compatible": "Compatibilidad", "precio": 10000, "valoracion": 4.5, '
                '"ventas": 50, "stock": 20, "discount": 10, "foto_producto": "URL", "status": "disponible", "delivery_fee_status": true, "cash_back": true, "reviews": { "user1": "Reseña 1", "user2": "Reseña 2" }}]\n\n'
                '\n\nAquí están los productos disponibles:\n\n$jsonContextText'
          },
          {
            'role': 'user',
            'content': userMessage,
          }
        ];
      } else {
        print("Generando mensaje del sistema para conversación casual...");
        messages = [
          {
            'role': 'system',
            'content':
            'Eres un asistente de chatbot que puede responder preguntas casuales sobre productos. Proporciona información relevante como cantidad en stock, valoraciones, y otras especificaciones importantes. '
                'No uses formato JSON para este tipo de respuestas.'
          },
          {
            'role': 'user',
            'content': userMessage,
          }
        ];
      }

      final request = ChatCompleteText(
        messages: messages,
        maxToken: 1000,
        model: Gpt4oMiniChatModel(),
      );

      print("Enviando solicitud a GPT...");
      final response = await openAI.onChatCompletion(request: request);
      String assistantMessage =
          response?.choices.first.message?.content ?? 'Lo siento, no entendí eso.';

      // Limpia delimitadores de JSON si es necesario
      assistantMessage = cleanJsonResponse(assistantMessage);
      print("Respuesta del asistente: $assistantMessage");

      // Extraer JSON de la respuesta
      List<Map<String, dynamic>>? productJsonList =
      extractJsonFromResponse(assistantMessage);

      // Generar y agregar texto de seguimiento relacionado con los productos si es necesario
      final followUpText = await _generateFollowUpText(userMessage, productJsonList ?? []);
      if (followUpText != null && followUpText.isNotEmpty) {
        setState(() {
          _messageJsons.add({
            'user_message': userMessage,
            'response': {
              'text': followUpText,
              'products': [],
              'animation_controller': AnimationController(
                vsync: this,
                duration: const Duration(milliseconds: 500),
              )
            },
          });
          // Iniciar la animación
          _messageJsons.last['response']['animation_controller'].forward();
        });
      }

      if (productJsonList != null && productJsonList.isNotEmpty) {
        // Luego muestra las StoreItemCard
        setState(() {
          _messageJsons.add({
            'user_message': userMessage,
            'response': {
              'text': null,
              'products': productJsonList,
              'animation_controller': AnimationController(
                vsync: this,
                duration: const Duration(milliseconds: 500),
              )
            },
          });
          // Iniciar la animación
          _messageJsons.last['response']['animation_controller'].forward();
        });
      }

      _scrollToBottom();

    } catch (e) {
      print("Error durante el proceso de mensaje: $e");
      setState(() {
        _messageJsons.add({
          'user_message': userMessage,
          'response': {'error': 'Error: $e'},
        });
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Chat with AI🧠', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20),
        centerTitle: true,  // Centro el título en la AppBar
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              itemCount: _messageJsons.length,
              itemBuilder: (context, index) {
                final response = _messageJsons[index]['response'];
                final text = response['text'] ?? '';  // Asegurar que text no sea nulo
                final products = (response['products'] as List<dynamic>?)
                    ?.map((item) => item as Map<String, dynamic>)
                    .toList();
                final animationController = response['animation_controller'] as AnimationController?;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (text.isNotEmpty && animationController != null)
                      FadeTransition(
                        opacity: animationController.drive(CurveTween(curve: Curves.easeIn)),
                        child: ListTile(
                          title: Text(
                            'User Message: ${_messageJsons[index]['user_message']}',
                            style: const TextStyle(fontFamily: 'Poppins'),
                          ),
                          subtitle: Text(
                            'Response: $text',
                            style: const TextStyle(fontFamily: 'Poppins'),
                          ),
                        ),
                      ),
                    if (products != null && products.isNotEmpty && animationController != null)
                      FadeTransition(
                        opacity: animationController.drive(CurveTween(curve: Curves.easeIn)),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(), // Evitar el desplazamiento dentro de la GridView
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // Número de columnas
                            mainAxisSpacing: 8.0, // Espacio vertical entre elementos
                            crossAxisSpacing: 8.0, // Espacio horizontal entre elementos
                            childAspectRatio: 0.6, // Relación de aspecto de los elementos
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, gridIndex) {
                            final product = products[gridIndex];
                            return StoreItemCard(itemData: product);
                          },
                        ),
                      ),
                  ],
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
                      hintText: 'Escribe tu mensaje...',
                      hintStyle: TextStyle(fontFamily: 'Poppins'),
                    ),
                    style: const TextStyle(fontFamily: 'Poppins'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isLoading || jsonContextText == null ? null : _sendMessage,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var message in _messageJsons) {
      final controller = message['response']['animation_controller'] as AnimationController?;
      controller?.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }
}
