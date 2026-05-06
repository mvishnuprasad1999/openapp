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
    final user = json['user'];

    return Post(
      id: json['id'] ?? 0,
      title: json['title'] ?? "",
      content: json['content'] ?? "",

      /// ✅ FIX HERE
      username: user != null ? (user['username'] ?? "unknown") : "unknown",

      /// ✅ SAFE IMAGES
      images: (json['images'] as List?)
              ?.map((e) => e['image_url'] as String? ?? "")
              .where((e) => e.isNotEmpty)
              .toList() ??
          [],
    );
  }
}