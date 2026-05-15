import 'package:open_ui/model/user_model.dart';

class TaskSolutionModel {
  final String id;
  final String content;
  final UserModel user;
  final String? parentId;
  final List<TaskSolutionModel> replies;
  final DateTime? createdAt; // ✅ ADD THIS

  TaskSolutionModel({
    required this.id,
    required this.content,
    required this.user,
    this.parentId,
    this.replies = const [],
    this.createdAt, // ✅ ADD THIS
  });

  factory TaskSolutionModel.fromJson(Map<String, dynamic> json) {
    return TaskSolutionModel(
      id: json['id'].toString(),
      content: json['content'],
      user: UserModel.fromJson(json['user']),
      parentId: json['parent_id']?.toString(),
      replies: (json['replies'] as List<dynamic>?)
              ?.map((r) => TaskSolutionModel.fromJson(r))
              .toList() ??
          [],
      // ✅ ADD THIS
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
}