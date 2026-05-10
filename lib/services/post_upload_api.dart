// import 'dart:io';
// import 'package:http/http.dart' as http;

// class PostUploadApi {
//   static const String baseUrl = "https://open-go6b.onrender.com";

//   static Future<void> createPost({
//     required String token,
//     required String title,
//     required String content,
//     required List<File> files,
//   }) async {
//     var request = http.MultipartRequest(
//       'POST',
//       Uri.parse("$baseUrl/create-post"),
//     );

//     request.headers['Authorization'] = 'Bearer $token';

//     request.fields['title'] = title;
//     request.fields['content'] = content;

//     for (var file in files) {
//       request.files.add(
//         await http.MultipartFile.fromPath(
//           'files',
//           file.path,
//         ),
//       );
//     }

//     final response = await request.send();

//     final body = await response.stream.bytesToString();

//     if (response.statusCode != 200 && response.statusCode != 201) {
//       throw Exception("Post upload failed: $body");
//     }
//   }
// }