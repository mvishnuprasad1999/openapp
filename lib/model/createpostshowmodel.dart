import 'user_model.dart';

class Post {
  final int id;
  final String title;
  final String content;

  final UserModel? user;

  final List<String> images;

  final int likesCount;
  final int savesCount;

  final bool isLiked;
  final bool isSaved;
  final bool isFollowing;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.user,
    required this.images,
    required this.likesCount,
    required this.savesCount,
    required this.isLiked,
    required this.isSaved,
    required this.isFollowing,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? 0,

      title: json['title'] ?? "",

      content: json['content'] ?? "",

      user: json['user'] != null
          ? UserModel.fromJson(json['user'])
          : null,

      images: (json['images'] as List?)
              ?.map((e) => e['image_url'].toString())
              .toList() ??
          [],

      likesCount: json['likes_count'] ?? 0,
      savesCount: json['saves_count'] ?? 0,

      isLiked: json['is_liked'] ?? false,
      isSaved: json['is_saved'] ?? false,
      isFollowing: json['is_following'] ?? false,
    );
  }

  Post copyWith({
    int? likesCount,
    int? savesCount,
    bool? isLiked,
    bool? isSaved,
    bool? isFollowing,
  }) {
    return Post(
      id: id,
      title: title,
      content: content,
      user: user,
      images: images,

      likesCount: likesCount ?? this.likesCount,
      savesCount: savesCount ?? this.savesCount,

      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}