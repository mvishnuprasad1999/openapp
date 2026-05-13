
import 'package:flutter_riverpod/legacy.dart';
import 'package:open_ui/model/user_model.dart';
import 'package:open_ui/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

final followingProvider =
    StateNotifierProvider<FollowingNotifier, List<UserModel>>(
  (ref) => FollowingNotifier(),
);

class FollowingNotifier extends StateNotifier<List<UserModel>> {
  FollowingNotifier() : super([]);

  final Set<int> _unfollowedIds = {};

  // =========================
  // LOAD FOLLOWING USERS
  // =========================
  Future<void> loadFollowing() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) return;

      final users = await FollowApi.getFollowingUsers(
        token: token,
      );

      // remove locally unfollowed users
      state = users
          .where((user) => !_unfollowedIds.contains(user.id))
          .toList();
    } catch (e) {
      print("LOAD FOLLOWING ERROR: $e");
    }
  }

  // =========================
  // CHECK FOLLOWING
  // =========================
  bool isFollowing(int userId) {
    return state.any((e) => e.id == userId);
  }

  // =========================
  // FOLLOW USER
  // =========================
  Future<void> followUser(UserModel user) async {
    final oldState = [...state];

    // remove from unfollow cache
    _unfollowedIds.remove(user.id);

    // instant UI update
    if (!isFollowing(user.id)) {
      state = [user, ...state];
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        state = oldState;
        return;
      }

      await FollowApi.followUser(
        userId: user.id,
        token: token,
      );

      // refresh from backend
      await loadFollowing();
    } catch (e) {
      state = oldState;
      print("FOLLOW ERROR: $e");
    }
  }

  // =========================
  // UNFOLLOW USER
  // =========================
  Future<void> unfollowUser(int userId) async {
    final oldState = [...state];

    // prevent re-adding
    _unfollowedIds.add(userId);

    // instant remove from UI
    state = state.where((e) => e.id != userId).toList();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        _unfollowedIds.remove(userId);
        state = oldState;
        return;
      }

      await FollowApi.unfollowUser(
        userId: userId,
        token: token,
      );

      // refresh latest server state
      await loadFollowing();
    } catch (e) {
      _unfollowedIds.remove(userId);
      state = oldState;

      print("UNFOLLOW ERROR: $e");
    }
  }
}