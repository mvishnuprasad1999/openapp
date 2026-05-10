import 'dart:io';
import 'package:flutter_riverpod/legacy.dart';
import 'package:open_ui/services/api_services.dart';


final postUploadProvider =
    StateNotifierProvider<PostUploadNotifier, bool>((ref) {
  return PostUploadNotifier();
});

class PostUploadNotifier extends StateNotifier<bool> {
  PostUploadNotifier() : super(false);

  Future<void> uploadPost({
    required String token,
    required String title,
    required String content,
    required List<File> files,
  }) async {
    try {
      state = true;

      await PostUploadApi.createPost(
        token: token,
        title: title,
        content: content,
        files: files,
      );
    } finally {
      state = false;
    }
  }
}