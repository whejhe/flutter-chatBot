import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

Logger _log = Logger('MyApp');

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    _log.info('${record.level.name}: ${record.time}: ${record.message}');
  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  void _sendMessageToRasa() async {
    _log.info('Enviando mensaje a Rasa...');
    final message = _textController.text.trim();
    if (message.isNotEmpty) {
      setState(() {
        _messages.add(ChatMessage(
          text: message,
          isMe: true,
        ));
        _textController.clear();
      });
      _isLoading = true;
      _log.info('Mensaje enviado: $message');
      final response = await http.post(
        Uri.parse('http://localhost:5005/conversations/default/respond'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );
      _log.info('Respuesta de Rasa: ${response.statusCode}');
      _isLoading = false;
      if (response.statusCode == 200) {
        _log.info('Respuesta de Rasa: ${response.body}');
        final responseData = jsonDecode(response.body);
        final botResponse = responseData['messages'][0]['content'];
        setState(() {
          _messages.add(ChatMessage(
            text: botResponse,
            isMe: false,
          ));
        });
      } else {
        _log.info('Error al enviar mensaje: ${response.statusCode}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al enviar mensaje'),
            ),
          );
        }
      }
    }
  }

  void _sendVoiceMessage() async {
    // Implementar la lógica para enviar un mensaje de voz a Rasa
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat App'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ChatMessageWidget(_messages[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Escribe un mensaje',
                    ),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _sendMessageToRasa,
                  child: Text('Enviar'),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _sendVoiceMessage,
                  child: Icon(Icons.mic),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isMe;

  ChatMessage({required this.text, required this.isMe});
}

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageWidget(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: message.isMe ? Colors.blue : Colors.grey,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.text,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
