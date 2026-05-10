import 'package:flutter_riverpod/legacy.dart';
import 'package:open_ui/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

final savedPostsProvider = StateNotifierProvider<SavePostNotifier, Set<int>>(
  (ref) => SavePostNotifier(),
);

class SavePostNotifier extends StateNotifier<Set<int>> {
  SavePostNotifier() : super({}) {
    loadSavedPosts();
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    return int.parse(value.toString());
  }

  Future<void> loadSavedPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      state = {};
      return;
    }

    final savedPosts = await SavePostShowApi.getSavedPosts(token: token);

    final savedIds = savedPosts.map<int>((post) {
      return _toInt(post["id"]);
    }).toSet();

    state = savedIds;
  }

  Future<void> savePost(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      throw Exception("User not logged in");
    }

    if (state.contains(postId)) {
      return;
    }

    await SavePostApi.savePost(
      postId: postId,
      token: token,
    );

    state = {...state, postId};
  }

  void unsavePostLocal(int postId) {
    state = {...state}..remove(postId);
  }

  bool isSaved(int postId) {
    return state.contains(postId);
  }
}
