import 'package:http/http.dart' as http;
import 'dart:convert';

class RasaChatbot {
  // final String rasaUrl = 'http://localhost:5005';

  Future<String> sendMessage(String message) async {
    final String rasaUrl =
        'http://localhost:5005/conversations/default/respond';
    final response = await http.post(
      Uri.parse(rasaUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': message}),
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Error al enviar mensaje');
    }
  }
}
