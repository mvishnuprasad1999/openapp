import 'task_solution_model.dart';

class TaskImage {
  final int id;
  final String imageUrl;

  TaskImage({required this.id, required this.imageUrl});

  factory TaskImage.fromJson(Map<String, dynamic> json) {
    return TaskImage(id: json["id"], imageUrl: json["image_url"] ?? "");
  }
}

class TaskUser {
  final int id;
  final String name;
  final String username;
  final String profileImage;

  TaskUser({
    required this.id,
    required this.name,
    required this.username,
    required this.profileImage,
  });

  factory TaskUser.fromJson(Map<String, dynamic> json) {
    return TaskUser(
      id: json["id"],
      name: json["name"] ?? "",
      username: json["username"] ?? "",
      profileImage: json["profile_image"] ?? "",
    );
  }
}

class TaskModel {
  final int id;
  final String title;
  final String content;

  final TaskUser user;

  final List<TaskImage> images;

  /// TASK SOLUTIONS
  final List<TaskSolutionModel> solutions;

  /// CREATED TIME
  final DateTime? createdAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.content,
    required this.user,
    required this.images,
    required this.solutions,
    this.createdAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json["id"],

      title: json["title"] ?? "",

      content: json["content"] ?? "",

      user: TaskUser.fromJson(json["user"]),

      images:
          (json["images"] as List?)
              ?.map((e) => TaskImage.fromJson(e))
              .toList() ??
          [],

      /// SOLUTIONS
      solutions:
          (json["solutions"] as List?)
              ?.map((e) => TaskSolutionModel.fromJson(e))
              .toList() ??
          [],

      /// CREATED AT
      createdAt: json["created_at"] != null
          ? DateTime.tryParse(json["created_at"])
          : null,
    );
  }
}
