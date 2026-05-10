// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class AuthApi {
//   static const String baseUrl = "https://open-go6b.onrender.com";

//   static Future<Map<String, dynamic>> signup(
//     String email,
//     String password,
//   ) async {
//     final response = await http.post(
//       Uri.parse("$baseUrl/signup"),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({"email": email, "password": password}),
//     );

//     // ✅ Check status before decoding
//     if (response.statusCode != 200) {
//       throw Exception("Server error: ${response.statusCode}");
//     }

//     final data = jsonDecode(response.body);
//     return data;
//   }

//   static Future<Map<String, dynamic>> login(
//     String email,
//     String password,
//   ) async {
//     final response = await http.post(
//       Uri.parse("$baseUrl/login"),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({"email": email, "password": password}),
//     );

//     // ✅ Check status before decoding
//     if (response.statusCode != 200) {
//       throw Exception("Server error: ${response.statusCode}");
//     }

//     final data = jsonDecode(response.body);
//     return data;
//   }
// }
