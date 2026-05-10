import 'user_model.dart';

class Post {
  final int id;
  final String title;
  final String content;
  final String username;

  final UserModel? user;

  final String? profileImage;

  final List<String> images;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.username,
    required this.images,
    this.user,
    this.profileImage,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final userJson =
        json['user'] as Map<String, dynamic>?;

    return Post(
      id: json['id'] ?? 0,
      title: json['title'] ?? "",
      content: json['content'] ?? "",

      username:
          userJson?['username'] ?? "unknown",

      user: userJson != null
          ? UserModel.fromJson(userJson)
          : null,

      profileImage:
          userJson?['profile_image'],

      images: (json['images'] as List?)
              ?.map(
                (e) =>
                    e['image_url'].toString(),
              )
              .toList() ??
          [],
    );
  }
}