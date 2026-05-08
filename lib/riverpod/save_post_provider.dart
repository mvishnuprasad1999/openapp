
import 'package:flutter_riverpod/legacy.dart';
import 'package:open_ui/services/save_post_api.dart';
import 'package:shared_preferences/shared_preferences.dart';



final savedPostsProvider =
    StateNotifierProvider<SavePostNotifier, Set<int>>(
  (ref) => SavePostNotifier(),
);

class SavePostNotifier extends StateNotifier<Set<int>> {
  SavePostNotifier() : super({});

  Future<void> savePost(int postId) async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString("token");

    if (token == null) {
      throw Exception("User not logged in");
    }

    await SavePostApi.savePost(
      postId: postId,
      token: token,
    );

    /// update local UI instantly
    state = {...state, postId};
  }

  bool isSaved(int postId) {
    return state.contains(postId);
  }
}