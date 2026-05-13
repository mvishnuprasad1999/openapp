class UserModel {
  final int id;
  final String email;
  final String? name;
  final String? username;
  final String? profileImage;
  final String? profileTitle;
  final String? profileDescription;

  final List<dynamic>? posts;

  final bool isFollowing;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.username,
    this.profileImage,
    this.profileTitle,
    this.profileDescription,
    this.posts,
    required this.isFollowing,
  });

  factory UserModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserModel(
      id: json['id'] ?? 0,

      email: json['email'] ?? "",

      name: json['name'],
      username: json['username'],

      /// FIXED HERE
      profileImage:
          json['image_url'] ??
          json['profile_image'],

      profileTitle:
          json['profile_title'],

      profileDescription:
          json['profile_description'],

      posts: json['posts'] ?? [],

      isFollowing:
          json['is_following'] ?? false,
    );
  }
}