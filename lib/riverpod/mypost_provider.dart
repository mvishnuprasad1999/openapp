import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:open_ui/model/createpostshowmodel.dart';
import 'package:open_ui/riverpod/auth_provider.dart';
import 'package:open_ui/riverpod/postshowprovider.dart';
import 'package:open_ui/services/api_services.dart';

final myPostsProvider = StateNotifierProvider.family<
    MyPostsNotifier,
    AsyncValue<List<Post>>,
    int>((ref, userId) {
  return MyPostsNotifier(ref, userId);
});

class MyPostsNotifier extends StateNotifier<AsyncValue<List<Post>>> {
  final Ref ref;
  final int userId;

  MyPostsNotifier(this.ref, this.userId)
      : super(const AsyncLoading()) {
    loadPosts();
  }

  Future<void> loadPosts() async {
    state = const AsyncLoading();

    try {
      final auth = ref.read(authProvider);

      if (auth.token == null) {
        state = AsyncError(
          "No token",
          StackTrace.current,
        );
        return;
      }

      /// FETCH POSTS OF SPECIFIC USER
      final data = await PostApi.getUserPosts(
        token: auth.token!,
        userId: userId,
      );

      state = AsyncData(data);
    } catch (e) {
      state = AsyncError(
        e,
        StackTrace.current,
      );
    }
  }

  Future<void> deletePost(int postId) async {
    final previousState = state;

    final auth = ref.read(authProvider);

    if (auth.token == null) {
      throw Exception("No token");
    }

    /// OPTIMISTIC DELETE
    state = state.whenData(
      (posts) => posts
          .where((post) => post.id != postId)
          .toList(),
    );

    try {
      await PostActionApi.deletePost(
        postId: postId,
        token: auth.token!,
      );

      /// REFRESH HOME POSTS
      ref.invalidate(postsProvider);
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }
}
