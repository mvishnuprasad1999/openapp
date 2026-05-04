class UserModel {
  final int id;
  final String email;
  final String? name;
  final String? username;
  final String? profileImage;
  final String? profileTitle;
  final String? profileDescription;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.username,
    this.profileImage,
    this.profileTitle,
    this.profileDescription,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name:json['name'],
      username: json['username'],
      profileImage: json['profile_image'],
      profileTitle: json['profile_title'],
      profileDescription: json['profile_description'],
    );
  }
}
