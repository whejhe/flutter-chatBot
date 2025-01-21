import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RasaClient {
  final String _rasaUrl = 'http://localhost:5005/webhooks/rest/webhook';

  Future<String> sendMessage(String message) async {
    final response = await http.post(Uri.parse(_rasaUrl), body: {'message': message});
    final jsonData = jsonDecode(response.body);
    return jsonData['text'];
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _rasaClient = RasaClient();
  final _textController = TextEditingController();

  void _sendMessage() async {
    final message = _textController.text;
    final response = await _rasaClient.sendMessage(message);
    setState(() {
      _textController.text = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rasa Chatbot'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _textController,
          ),
          ElevatedButton(
            onPressed: _sendMessage,
            child: Text('Enviar'),
          ),
        ],
      ),
    );
  }
}