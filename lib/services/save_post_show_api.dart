// // lib/services/save_post_api.dart

// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class SavePostShowApi {
//   static const String baseUrl =
//       "https://open-go6b.onrender.com";

//   /// SAVE POST
//   static Future<void> savePost({
//     required int postId,
//     required String token,
//   }) async {
//     final response = await http.post(
//       Uri.parse("$baseUrl/save/$postId"),
//       headers: {
//         "Authorization": "Bearer $token",
//       },
//     );

//     if (response.statusCode != 200 &&
//         response.statusCode != 201) {
//       throw Exception("Failed to save post");
//     }
//   }

//   /// GET SAVED POSTS
//   static Future<List<dynamic>> getSavedPosts({
//     required String token,
//   }) async {
//     final response = await http.get(
//       Uri.parse("$baseUrl/saved-posts"),
//       headers: {
//         "Authorization": "Bearer $token",
//       },
//     );

//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception("Failed to load saved posts");
//     }
//   }
// }