// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../model/createpostmodel.dart';

// class PostApi {
//   static const String baseUrl = "https://open-go6b.onrender.com";

//   static Future<List<Post>> getPosts() async {
//     final res = await http.get(Uri.parse("$baseUrl/posts"));

//     if (res.statusCode != 200) {
//       throw Exception("Failed to load posts");
//     }

//     final data = jsonDecode(res.body) as List;

//     return data.map((e) => Post.fromJson(e)).toList();
//   }
// }