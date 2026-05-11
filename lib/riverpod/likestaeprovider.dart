import 'package:flutter_riverpod/legacy.dart';

class LikeState {
  final bool isLiked;
  final int likeCount;

  const LikeState({required this.isLiked, required this.likeCount});

  LikeState copyWith({bool? isLiked, int? likeCount}) {
    return LikeState(
      isLiked: isLiked ?? this.isLiked,
      likeCount: likeCount ?? this.likeCount,
    );
  }
}

class LikeStateNotifier extends StateNotifier<Map<int, LikeState>> {
  LikeStateNotifier() : super({});

  void init(int postId, {required bool isLiked, required int likeCount}) {
    // Only initialize if not already tracked (avoids overwriting live state)
    if (!state.containsKey(postId)) {
      state = {
        ...state,
        postId: LikeState(isLiked: isLiked, likeCount: likeCount),
      };
    }
  }

  void update(int postId, {required bool isLiked, required int likeCount}) {
    state = {
      ...state,
      postId: LikeState(isLiked: isLiked, likeCount: likeCount),
    };
  }

  LikeState? get(int postId) => state[postId];
}

final likeStateProvider =
    StateNotifierProvider<LikeStateNotifier, Map<int, LikeState>>(
  (ref) => LikeStateNotifier(),
);