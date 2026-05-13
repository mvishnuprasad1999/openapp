import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_ui/model/user_model.dart';
import 'package:open_ui/riverpod/Perticular_profile_show_provider.dart';
import 'package:open_ui/riverpod/likestaeprovider.dart';
import 'package:open_ui/riverpod/postshowprovider.dart';
import 'package:open_ui/services/api_services.dart';
import 'package:open_ui/widgets/blogpostshimmer.dart';

import 'blopostcontentcard.dart';

class UserPostsScreen extends ConsumerWidget {
  final int userId;

  const UserPostsScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileShowProvider(userId));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0, top: 8, bottom: 6),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Container(
                width: 40,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
        title: const Text(
          "User Posts",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: profileAsync.when(
        loading: () => const BlogPostShimmer(),

        error: (e, _) => Center(
          child: Text(
            e.toString(),
            style: const TextStyle(color: Colors.white),
          ),
        ),

        data: (user) {
          final posts = user.posts ?? [];

          WidgetsBinding.instance.addPostFrameCallback((_) {
            for (final post in posts) {
              final postId = post is Map
                  ? (post["id"] is int
                      ? post["id"] as int
                      : int.tryParse(post["id"].toString()) ?? 0)
                  : (post.id is int ? post.id as int : 0);

              final isLiked = post is Map
                  ? post["is_liked"] == true
                  : (post.isLiked ?? false);

              final likeCount = post is Map
                  ? (post["likes_count"] is int
                      ? post["likes_count"] as int
                      : int.tryParse(
                              post["likes_count"]?.toString() ?? "0") ??
                          0)
                  : (post.likesCount ?? 0);

              ref.read(likeStateProvider.notifier).init(
                    postId,
                    isLiked: isLiked,
                    likeCount: likeCount,
                  );
            }
          });

          if (posts.isEmpty) {
            return const Center(
              child: Text(
                "No posts yet",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(profileShowProvider(userId));
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 40),
              itemCount: posts.length,
              itemBuilder: (context, i) {
                return _UserPostCard(
                  post: posts[i],
                  user: user,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _UserPostCard extends ConsumerStatefulWidget {
  final dynamic post;
  final UserModel user;

  const _UserPostCard({
    required this.post,
    required this.user,
  });

  @override
  ConsumerState<_UserPostCard> createState() => _UserPostCardState();
}

class _UserPostCardState extends ConsumerState<_UserPostCard> {
  late final PageController _controller;
  double _currentPage = 0;
  bool _isLikeLoading = false;

  late final int _postId;

  @override
  void initState() {
    super.initState();

    _controller = PageController(viewportFraction: 1);

    final post = widget.post;
    final raw = _read(post, "id");

    _postId = raw is int
        ? raw
        : int.tryParse(raw?.toString() ?? "") ?? 0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  dynamic _read(dynamic obj, String key) {
    if (obj is Map) return obj[key];

    try {
      switch (key) {
        case "id":
          return obj.id;

        case "title":
          return obj.title;

        case "content":
          return obj.content;

        case "images":
          return obj.images;

        case "likes_count":
          return obj.likesCount;

        case "is_liked":
          return obj.isLiked;

        case "username":
          return obj.username;

        case "profile_image":
          return obj.profileImage;

        case "user":
          return obj.user;
      }
    } catch (_) {}

    return null;
  }

  List<String> _images(dynamic raw) {
    if (raw is! List || raw.isEmpty) return [];

    return raw
        .map<String>((img) {
          if (img is Map) {
            return img["image_url"]?.toString() ?? "";
          }

          try {
            return img.imageUrl?.toString() ?? "";
          } catch (_) {
            return img.toString();
          }
        })
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> _toggleLike(BuildContext context) async {
    if (_isLikeLoading) return;

    final likeNotifier = ref.read(likeStateProvider.notifier);

    final currentState =
        ref.read(likeStateProvider)[_postId];

    if (currentState == null) return;

    final wasLiked = currentState.isLiked;
    final oldCount = currentState.likeCount;

    likeNotifier.update(
      _postId,
      isLiked: !wasLiked,
      likeCount:
          wasLiked ? (oldCount - 1).clamp(0, 999999) : oldCount + 1,
    );

    setState(() => _isLikeLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("token");

      if (token == null) {
        throw Exception("User not logged in");
      }

      final result = wasLiked
          ? await PostActionApi.unlikePost(
              postId: _postId,
              token: token,
            )
          : await PostActionApi.likePost(
              postId: _postId,
              token: token,
            );

      final updatedLikeCount =
          result["likes_count"] ??
              result["likesCount"] ??
              result["like_count"];

      final updatedIsLiked =
          result["is_liked"] ??
              result["isLiked"] ??
              result["liked"];

      likeNotifier.update(
        _postId,
        isLiked: updatedIsLiked == true,
        likeCount: updatedLikeCount is int
            ? updatedLikeCount
            : int.tryParse(updatedLikeCount.toString()) ??
                oldCount,
      );

      ref.invalidate(postsProvider);
    } catch (e) {
      likeNotifier.update(
        _postId,
        isLiked: wasLiked,
        likeCount: oldCount,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isLikeLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    final images = _images(_read(post, "images"));

    final count = images.isEmpty ? 1 : images.length;

    final likeMap = ref.watch(likeStateProvider);

    final likeState = likeMap[_postId];

    final isLiked =
        likeState?.isLiked ??
            (_read(post, "is_liked") == true);

    final likeCount =
        likeState?.likeCount ??
            ((_read(post, "likes_count") is int
                    ? _read(post, "likes_count") as int
                    : int.tryParse(
                            _read(post, "likes_count")
                                    ?.toString() ??
                                "0") ??
                        0));

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                margin: const EdgeInsets.all(5),
                height: 200,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(38),
                  child: Stack(
                    children: [
                      images.isEmpty
                          ? Image.asset(
                              "assets/images/blogpostcardsample.png",
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : PageView.builder(
                              controller: _controller,
                              itemCount: images.length,
                              onPageChanged: (value) {
                                setState(() {
                                  _currentPage = value.toDouble();
                                });
                              },
                              itemBuilder: (context, i) {
                                return Image.network(
                                  images[i],
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) {
                                    return Image.asset(
                                      "assets/images/blogpostcardsample.png",
                                      fit: BoxFit.cover,
                                    );
                                  },
                                );
                              },
                            ),

                      Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.black.withOpacity(0.15),
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.55),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                top: 28,
                right: 18,
                child: Column(
                  children: [
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () => _toggleLike(context),
                          child: SizedBox(
                            height: 42,
                            width: 42,
                            child: Center(
                              child: _isLikeLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child:
                                          CircularProgressIndicator(
                                        color: Colors.blue,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : SvgPicture.asset(
                                      "assets/images/like.svg",
                                      height: 42,
                                      width: 42,
                                      colorFilter: isLiked
                                          ? const ColorFilter.mode(
                                              Colors.blue,
                                              BlendMode.srcIn,
                                            )
                                          : null,
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          likeCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Positioned(
                bottom: 20,
                left: 125,
                right: 125,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final totalWidth = constraints.maxWidth;

                    final segmentWidth = count == 1
                        ? totalWidth
                        : totalWidth / count;

                    return Stack(
                      children: [
                        Container(
                          height: 3,
                          width: totalWidth,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                        ),

                        AnimatedPositioned(
                          duration:
                              const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                          left: count == 1
                              ? 0
                              : _currentPage * segmentWidth,
                          child: Container(
                            height: 3,
                            width: segmentWidth,
                            decoration: BoxDecoration(
                              color: Colors.pink,
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),

          BlogContentCard(
            // initiallyFollowing: post.isFollowing,
            userId: widget.user.id ?? 0,
            source: widget.user.username ?? "",
            title: _read(post, "title")?.toString() ?? "",
            content: _read(post, "content")?.toString() ?? "",
            profileImage: widget.user.profileImage,
          ),
        ],
      ),
    );
  }
}