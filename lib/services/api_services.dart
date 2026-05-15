import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:open_ui/model/createpostshowmodel.dart';
import 'package:open_ui/model/taskmodel.dart';
import 'package:open_ui/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';

// =========================
// AUTH API
// =========================
class AuthApi {
  static Future<Map<String, dynamic>> signup(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/signup"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode != 200) {
      throw Exception("Server error: ${response.statusCode}");
    }

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode != 200) {
      throw Exception("Server error: ${response.statusCode}");
    }

    return jsonDecode(response.body);
  }
}

// =========================
// CHAT API
// =========================
class ChatApi {
  static Future<String> sendMessage({
    required String query,
    required List<Map<String, String>> history,
  }) async {
    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/chat"),
      headers: {"Content-Type": "application/json"},
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

// =========================
// PROFILE CREATE API
// =========================
class CreateProfileApi {
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
      Uri.parse("${ApiConfig.baseUrl}/create-profile"),
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



// =========================
// POST UPLOAD API
// =========================
class PostUploadApi {
  static Future<void> createPost({
    required String token,
    required String title,
    required String content,
    required List<File> files,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("${ApiConfig.baseUrl}/create-post"),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['title'] = title;
    request.fields['content'] = content;

    for (var file in files) {
      request.files.add(
        await http.MultipartFile.fromPath('files', file.path),
      );
    }

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception("Post upload failed: $body");
    }
  }
}

// // =========================
// // POSTS API
// // =========================
// class PostApi {
//   static Future<List<Post>> getPosts() async {
//     final res = await http.get(
//       Uri.parse("${ApiConfig.baseUrl}/posts"),
//     );

//     if (res.statusCode != 200) {
//       throw Exception("Failed to load posts");
//     }

//     final data = jsonDecode(res.body) as List;
//     return data.map((e) => Post.fromJson(e)).toList();
//   }
// }

// =========================
// POSTS of logined user
// =========================

class MyPostApi {
  static Future<List<Post>> getMyPosts({
    required String token,
  }) async {
    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/my-posts"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load my posts");
    }

    final data = jsonDecode(res.body) as List;

    return data.map((e) => Post.fromJson(e)).toList();
  }
}

/// =========================
/// POST FETCH API
/// =========================

class PostApi {
  /// ALL POSTS
  static Future<List<Post>> getPosts() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString("token");

    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/posts"),
      headers: {
        if (token != null)
          "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load posts");
    }

    final data = jsonDecode(res.body) as List;

    return data
        .map((e) => Post.fromJson(e))
        .toList();
  }

  /// LOGGED USER POSTS
  static Future<List<Post>> getMyPosts({
    required String token,
  }) async {
    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/my-posts"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load my posts");
    }

    final data = jsonDecode(res.body) as List;

    return data
        .map((e) => Post.fromJson(e))
        .toList();
  }

  /// ANY USER POSTS
static Future<List<Post>> getUserPosts({
    required String token,
    required int userId,
  }) async {
    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/user-posts/$userId"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load user posts");
    }

    final data = jsonDecode(res.body) as List;

    return data.map((e) => Post.fromJson(e)).toList();
  }
}

/// =========================
/// POST ACTION API
/// =========================
class PostActionApi {
  /// DELETE POST
  static Future<void> deletePost({
    required int postId,
    required String token,
  }) async {
    final res = await http.delete(
      Uri.parse("${ApiConfig.baseUrl}/post/$postId"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode != 200) {
      throw Exception("Delete failed: ${res.body}");
    }
  }

  /// LIKE POST (example endpoint)
static Future<Map<String, dynamic>> likePost({
  required int postId,
  required String token,
}) async {
  final res = await http.post(
    Uri.parse("${ApiConfig.baseUrl}/like/$postId"),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  if (res.statusCode != 200 && res.statusCode != 201) {
    throw Exception("Like failed: ${res.body}");
  }

  if (res.body.isEmpty) return {};

  return jsonDecode(res.body);
}

static Future<Map<String, dynamic>> unlikePost({
  required int postId,
  required String token,
}) async {
  final res = await http.delete(
    Uri.parse("${ApiConfig.baseUrl}/like/$postId"),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  if (res.statusCode != 200 && res.statusCode != 204) {
    throw Exception("Unlike failed: ${res.body}");
  }

  if (res.body.isEmpty) return {};

  return jsonDecode(res.body);
}


  /// SAVE POST
  static Future<void> savePost({
    required int postId,
    required String token,
  }) async {
    final res = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/save/$postId"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode != 200) {
      throw Exception("Save failed");
    }
  }
}
// =========================
// PROFILE SHOW API
// =========================
// =========================
// PROFILE SHOW API
// =========================

class ProfileShowApi {

  /// LOGGED-IN USER PROFILE
  static Future<UserModel> getProfile(String token) async {
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/me"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch profile");
    }

    return UserModel.fromJson(
      jsonDecode(response.body),
    );
  }

  /// PARTICULAR USER PROFILE
  static Future<UserModel> getUserProfile({
    required int userId,
    required String token,
  }) async {

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/user/$userId"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to fetch user profile: ${response.body}",
      );
    }

    return UserModel.fromJson(
      jsonDecode(response.body),
    );
  }
}
// =========================
// FOLLOW API,unfollow,user id based follower get
// =========================

class FollowApi {
  static Future<Map<String, dynamic>> followUser({
    required int userId,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/follow/$userId"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to follow user: ${response.body}");
    }

    if (response.body.isEmpty) return {};

    return jsonDecode(response.body);
  }

static Future<void> unfollowUser({
  required int userId,
  required String token,
}) async {
  final response = await http.delete(
    Uri.parse("${ApiConfig.baseUrl}/follow/$userId"),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  if (response.statusCode != 200 && response.statusCode != 204) {
    throw Exception(
      "Failed to unfollow user: ${response.statusCode} ${response.body}",
    );
  }
}

  static Future<List<UserModel>> getFollowingUsers({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/following"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load following users: ${response.body}");
    }

    final data = jsonDecode(response.body) as List;

    return data.map((e) => UserModel.fromJson(e)).toList();
  }

static Future<List<UserModel>> getUserFollowing({
  required int userId,
  required String token,
}) async {
  final response = await http.get(
    Uri.parse("${ApiConfig.baseUrl}/user-following/$userId"),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  if (response.statusCode != 200) {
    throw Exception("Failed to load user following: ${response.body}");
  }

  final data = jsonDecode(response.body) as List;
  return data.map((e) => UserModel.fromJson(e)).toList();
}
}

// =========================
// Save and Unsave Api
// =========================

class SavePostApi {
  static Future<void> savePost({
    required int postId,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/save/$postId"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to save post: ${response.body}");
    }
  
  }

  static Future<void> unsavePost({
    required int postId,
    required String token,
  }) async {
    final response = await http.delete(
      Uri.parse("${ApiConfig.baseUrl}/save/$postId"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Failed to unsave post: ${response.body}");
    }
  }
}


// =========================
// SAVE POST SHOW API
// =========================
class SavePostShowApi {
  static Future<void> savePost({
    required int postId,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/save/$postId"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception("Failed to save post");
    }
  }

  static Future<List<dynamic>> getSavedPosts({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/saved-posts"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load saved posts");
    }
  }
}
// =========================
// TASK UPLOAD API
// =========================

class TaskUploadApi {
  static Future<void> createTask({
    required String token,
    required String title,
    required String content,
    required List<File> files,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("${ApiConfig.baseUrl}/create-task"),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['title'] = title;
    request.fields['content'] = content;

    /// MULTIPLE IMAGES
    for (var file in files) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'files',
          file.path,
        ),
      );
    }

    final response = await request.send();

    final body = await response.stream.bytesToString();

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception("Task upload failed: $body");
    }
  }
}

// =========================
// TASK FETCH API
// =========================

class TaskApi {

  static Future<List<TaskModel>> getTasks() async {
    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/tasks"),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load tasks");
    }

    final data = jsonDecode(res.body) as List;

    return data
        .map((e) => TaskModel.fromJson(e))
        .toList();
  }
}

// =========================
// TASK SOLUTION API
// =========================

class TaskSolutionApi {
  /// ADD SOLUTION / REPLY
static Future<void> addSolution({
  required int taskId,
  required String content,
  required String token,
  String? parentId,
}) async {
  final request = http.MultipartRequest(
    'POST',
    Uri.parse("${ApiConfig.baseUrl}/task-solution/$taskId"),
  );

  request.headers['Authorization'] = 'Bearer $token';
  request.fields['content'] = content;

  if (parentId != null && parentId.isNotEmpty) {
    request.fields['parent_id'] = parentId;
  }

  final response = await request.send();
  final body = await response.stream.bytesToString();

  if (response.statusCode != 200 && response.statusCode != 201) {
    throw Exception("Failed to add solution: $body");
  }
}


  /// GET TASKS AGAIN (refresh)
  static Future<List<TaskModel>> refreshTasks() async {
    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/tasks"),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load tasks");
    }

    final data = jsonDecode(res.body) as List;

    return data.map((e) => TaskModel.fromJson(e)).toList();
  }
}