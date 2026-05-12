class UserModel {
  final int id;
  final String email;
  final String? name;
  final String? username;
  final String? profileImage;
  final String? profileTitle;
  final String? profileDescription;

  final List<dynamic>? posts; // ✅ REQUIRED

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.username,
    this.profileImage,
    this.profileTitle,
    this.profileDescription,
    this.posts,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      username: json['username'],
      profileImage: json['image_url'], // or profile_image (your backend)
      profileTitle: json['profile_title'],
      profileDescription: json['profile_description'],

      // ✅ IMPORTANT
      posts: json['posts'] ?? [],
    );
  }
}