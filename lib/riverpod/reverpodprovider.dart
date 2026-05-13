import 'package:flutter_riverpod/legacy.dart';
import 'package:open_ui/model/user_model.dart';
import 'package:open_ui/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

final followingProvider =
    StateNotifierProvider<FollowingNotifier, List<UserModel>>(
  (ref) => FollowingNotifier(),
);

class FollowingNotifier extends StateNotifier<List<UserModel>> {
  FollowingNotifier() : super([]) {
    loadFollowing();
  }

  void addFollowingUser(UserModel user) {
    final alreadyExists = state.any((item) => item.id == user.id);

    if (alreadyExists) return;

    state = [user, ...state];
  }

  Future<void> loadFollowing() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("token");

      if (token == null) return;

      final users = await FollowApi.getFollowingUsers(
        token: token,
      );

      state = users;
    } catch (e) {
      print(e);
    }
  }

  Future<void> unfollowUser(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("token");

      if (token == null) return;

      state = state.where((user) => user.id != userId).toList();

      await FollowApi.unfollowUser(
        userId: userId,
        token: token,
      );
      await loadFollowing();
      
    } catch (e) {
      print(e);
    }
  }
}
