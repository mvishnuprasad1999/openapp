import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:open_ui/model/user_model.dart';


class ProfileShowApi {
  static const String baseUrl = "https://open-go6b.onrender.com";

  static Future<UserModel> getProfile(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/me"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch profile");
    }

    final data = jsonDecode(response.body);
    return UserModel.fromJson(data);
  }
}