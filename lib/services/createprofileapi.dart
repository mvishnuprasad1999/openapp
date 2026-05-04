import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CreateProfileApi {
  static const String baseUrl = "https://open-go6b.onrender.com";

  static Future<Map<String, dynamic>> createProfile({
    required String token,
    required String name,
    required String username,
    required String title,
    required String description,
    File? imageFile,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("$baseUrl/create-profile"),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['name'] = name;
    request.fields['username'] = username;
    request.fields['profile_title'] = title;
    request.fields['profile_description'] = description;

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      );
    }

    final response = await request.send();
    final responseData = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception("Profile creation failed: ${response.statusCode}");
    }

    return jsonDecode(responseData);
  }
}