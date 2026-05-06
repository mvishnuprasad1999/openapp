import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatApi {
  static const String baseUrl = "https://open-go6b.onrender.com";

  static Future<String> sendMessage({
    required String query,
    required List<Map<String, String>> history,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/chat"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "query": query,
        "history": history,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["answer"];
    } else {
      throw Exception("Chat failed: ${response.body}");
    }
  }
}