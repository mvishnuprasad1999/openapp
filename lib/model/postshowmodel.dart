class Post {
  final int id;
  final String title;
  final String content;
  final String username;
  final List<String> images;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.username,
    required this.images,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;

    return Post(
      id: json['id'] ?? 0,
      title: json['title'] ?? "",
      content: json['content'] ?? "",

      /// ✅ USERNAME FIXED
      username: user?['username'] ?? "",

      /// ✅ IMAGES
      images: (json['images'] as List?)
              ?.map((e) => e['image_url'] as String)
              .toList() ??
          [],
    );
  }
}