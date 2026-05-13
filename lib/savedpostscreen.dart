import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_ui/homepage.dart';
import 'package:open_ui/riverpod/likestaeprovider.dart';
import 'package:open_ui/riverpod/postshowprovider.dart';
import 'package:open_ui/riverpod/save_post_provider.dart';
import 'package:open_ui/riverpod/save_post_show.provider.dart';
import 'package:open_ui/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_ui/widgets/blogpostshimmer.dart';
import 'package:open_ui/widgets/bottombar.dart';

import 'blopostcontentcard.dart';

class SavedPostsScreen extends ConsumerStatefulWidget {
  const SavedPostsScreen({super.key});

  @override
  ConsumerState<SavedPostsScreen> createState() => _SavedPostsScreenState();
}

class _SavedPostsScreenState extends ConsumerState<SavedPostsScreen> {
  int _loggedUserId = 0;

  @override
  void initState() {
    super.initState();
    _loadLoggedUserId();
  }

  Future<void> _loadLoggedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return;
    try {
      final user = await ProfileShowApi.getProfile(token);
      if (mounted) setState(() => _loggedUserId = user.id);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final savedPostsAsync = ref.watch(savedPostsListProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        elevation: 0,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0, top: 8, bottom: 6),
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            ),
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
          "Saved Posts",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          savedPostsAsync.when(
            loading: () => const BlogPostShimmer(),
            error: (e, _) => Center(
              child: Text(
                e.toString(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            data: (savedPosts) {
              if (savedPosts.isEmpty) {
                return const Center(
                  child: Text(
                    "No saved posts",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                );
              }

              WidgetsBinding.instance.addPostFrameCallback((_) {
                for (final post in savedPosts) {
                  final postId = post["id"] is int
                      ? post["id"] as int
                      : int.tryParse(post["id"].toString()) ?? 0;
                  ref
                      .read(likeStateProvider.notifier)
                      .init(
                        postId,
                        isLiked: post["is_liked"] == true,
                        likeCount: post["likes_count"] is int
                            ? post["likes_count"] as int
                            : int.tryParse(
                                    post["likes_count"]?.toString() ?? "0",
                                  ) ??
                                  0,
                      );
                }
              });

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(savedPostsListProvider);
                  await ref.read(savedPostsListProvider.future);
                },
                child: ListView.builder(
                  itemCount: savedPosts.length,
                  padding: const EdgeInsets.only(bottom: 120),
                  itemBuilder: (context, index) {
                    final post = savedPosts[index];
                    return _SavedPostCard(
                      key: ValueKey(post["id"]),
                      post: post,
                      loggedUserId: _loggedUserId,
                    );
                  },
                ),
              );
            },
          ),
          const CustomBottomBar(selectedIndex: 2),
        ],
      ),
    );
  }
}

class _SavedPostCard extends ConsumerStatefulWidget {
  final dynamic post;
  final int loggedUserId;

  const _SavedPostCard({
    super.key,
    required this.post,
    required this.loggedUserId,
  });

  @override
  ConsumerState<_SavedPostCard> createState() => _SavedPostCardState();
}

class _SavedPostCardState extends ConsumerState<_SavedPostCard> {
  late final PageController _controller;
  double _currentPage = 0;

  bool _isUnsaving = false;
  bool _isLikeLoading = false;

  late final int _postId;

  @override
  void initState() {
    super.initState();

    _controller = PageController(viewportFraction: 1);

    _postId = widget.post["id"] is int
        ? widget.post["id"] as int
        : int.tryParse(widget.post["id"].toString()) ?? 0;

    _controller.addListener(() {
      if (!mounted) return;
      setState(() {
        _currentPage = _controller.page ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  List<String> _extractImageUrls(dynamic rawImages) {
    if (rawImages == null || rawImages is! List || rawImages.isEmpty) {
      return [];
    }
    return rawImages
        .map<String>((img) {
          if (img is Map) return img["image_url"]?.toString() ?? "";
          return img.toString();
        })
        .where((url) => url.isNotEmpty)
        .toList();
  }

  void _showTopOverlay({
    required BuildContext context,
    required String message,
    required IconData icon,
    required Color iconColor,
  }) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.85),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: iconColor, size: 26),
                  const SizedBox(width: 8),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () => overlayEntry.remove());
  }

  Future<void> _toggleLike(BuildContext context) async {
    if (_isLikeLoading) return;

    final likeNotifier = ref.read(likeStateProvider.notifier);
    final currentState = ref.read(likeStateProvider)[_postId];

    if (currentState == null) return;

    final wasLiked = currentState.isLiked;
    final oldCount = currentState.likeCount;

    likeNotifier.update(
      _postId,
      isLiked: !wasLiked,
      likeCount: wasLiked ? (oldCount - 1).clamp(0, 999999) : oldCount + 1,
    );

    setState(() => _isLikeLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      if (token == null) throw Exception("User not logged in");

      final result = wasLiked
          ? await PostActionApi.unlikePost(postId: _postId, token: token)
          : await PostActionApi.likePost(postId: _postId, token: token);

      final updatedLikeCount =
          result["likes_count"] ?? result["likesCount"] ?? result["like_count"];
      final updatedIsLiked =
          result["is_liked"] ?? result["isLiked"] ?? result["liked"];

      if (!mounted) return;

      likeNotifier.update(
        _postId,
        isLiked: updatedIsLiked != null ? updatedIsLiked == true : !wasLiked,
        likeCount: updatedLikeCount != null
            ? _toInt(updatedLikeCount)
            : (wasLiked ? (oldCount - 1).clamp(0, 999999) : oldCount + 1),
      );

      ref.invalidate(postsProvider);
    } catch (e) {
      if (mounted) {
        likeNotifier.update(_postId, isLiked: wasLiked, likeCount: oldCount);
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLikeLoading = false);
    }
  }

  Future<void> _unsavePost(BuildContext context, dynamic post) async {
    if (_isUnsaving) return;
    setState(() => _isUnsaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      if (token == null) throw Exception("User not logged in");

      await SavePostApi.unsavePost(postId: _postId, token: token);

      ref.read(savedPostsProvider.notifier).unsavePostLocal(_postId);
      ref.invalidate(savedPostsListProvider);
      ref.invalidate(postsProvider);

      if (!context.mounted) return;

      _showTopOverlay(
        context: context,
        message: "Post unsaved",
        icon: Icons.check_circle,
        iconColor: Colors.green,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isUnsaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final List<String> images = _extractImageUrls(post["images"]);
    final indicatorCount = images.isEmpty ? 1 : images.length;

    final likeMap = ref.watch(likeStateProvider);
    final likeState = likeMap[_postId];
    final isLiked = likeState?.isLiked ?? (post["is_liked"] == true);
    final likeCount = likeState?.likeCount ?? _toInt(post["likes_count"]);

    // Author ID — the person who wrote this saved post
    final int authorId = post["user"] != null
        ? _toInt(post["user"]["id"])
        : _toInt(post["user_id"]);

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                margin: const EdgeInsets.all(5.0),
                height: 200,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(38),
                  child: Stack(
                    children: [
                      if (images.isEmpty)
                        Image.asset(
                          "assets/images/blogpostcardsample.png",
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        )
                      else
                        PageView.builder(
                          controller: _controller,
                          physics: const PageScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemCount: images.length,
                          onPageChanged: (value) {
                            setState(() => _currentPage = value.toDouble());
                          },
                          itemBuilder: (context, imgIndex) {
                            final url = images[imgIndex];
                            return Image.network(
                              url,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                    "assets/images/blogpostcardsample.png",
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
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
                    GestureDetector(
                      onTap: () => _unsavePost(context, post),
                      child: SizedBox(
                        height: 42,
                        width: 42,
                        child: Center(
                          child: _isUnsaving
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : SvgPicture.asset(
                                  "assets/images/unsvae.svg",
                                  height: 42,
                                  width: 42,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
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
                                      child: CircularProgressIndicator(
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
                        const SizedBox(height: 2),
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
                    final segmentWidth = indicatorCount == 1
                        ? totalWidth
                        : totalWidth / indicatorCount;

                    return Stack(
                      children: [
                        Container(
                          height: 3,
                          width: totalWidth,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                          left: indicatorCount == 1
                              ? 0
                              : _currentPage * segmentWidth,
                          child: Container(
                            height: 3,
                            width: segmentWidth,
                            decoration: BoxDecoration(
                              color: Colors.pink,
                              borderRadius: BorderRadius.circular(10),
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

          // ✅ loggedUserId = who is viewing, authorId = who wrote the post
          BlogContentCard(
            // initiallyFollowing: post.isFollowing,
            userId:
                authorId, // already computed above as _toInt(post["user"]["id"])
            source: post["user"]?["username"] ?? post["username"] ?? "Unknown",
            title: post["title"] ?? "",
            content: post["content"] ?? "",
            profileImage: post["user"]?["profile_image"],
          ),
        ],
      ),
    );
  }
}
