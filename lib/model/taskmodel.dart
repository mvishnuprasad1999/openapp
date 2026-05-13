class TaskModel {
  final String id;
  final String category;
  final String title;
  final String description;
  final List<String> features;
  final int likes;
  final String? previewImageUrl;
 
  const TaskModel({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.features,
    required this.likes,
    this.previewImageUrl,
  });
}
 