import 'package:http/http.dart' as http;

class SavePostApi {
  static const String baseUrl =
      "https://open-go6b.onrender.com";

  /// SAVE POST ONLY
  static Future<void> savePost({
    required int postId,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/save/$postId"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception("Failed to save post");
    }
  }
}