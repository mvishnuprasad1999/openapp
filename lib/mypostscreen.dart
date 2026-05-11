import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_ui/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_ui/model/user_model.dart';
import 'package:open_ui/riverpod/mypost_provider.dart';
import 'package:open_ui/widgets/blogpostshimmer.dart';
import 'package:open_ui/widgets/bottombar.dart';

import 'blopostcontentcard.dart';

class MyPostsScreen extends ConsumerWidget {
  final int userId;

  const MyPostsScreen({
    super.key,
    required this.userId,
  });

  Future<UserModel?> _getLoggedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null || token.isEmpty) return null;
    return ProfileShowApi.getProfile(token);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(myPostsProvider(userId));

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
          "My Posts",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<UserModel?>(
        future: _getLoggedUser(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const BlogPostShimmer();
          }

          final loggedUser = userSnapshot.data;

          return Stack(
            children: [
              posts.when(
                loading: () => const BlogPostShimmer(),
                error: (e, _) => Center(
                  child: Text(
                    "Error: $e",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                data: (data) {
                  if (data.isEmpty) {
                    return const Center(
                      child: Text(
                        "No posts yet",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      await ref
                          .read(myPostsProvider(userId).notifier)
                          .loadPosts();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 120),
                      itemCount: data.length,
                      itemBuilder: (context, i) {
                        return _MyPostCard(
                          post: data[i],
                          loggedUser: loggedUser,
                          fallbackUserId: userId,
                        );
                      },
                    ),
                  );
                },
              ),
              const CustomBottomBar(selectedIndex: 3),
            ],
          );
        },
      ),
    );
  }
}

class _MyPostCard extends ConsumerStatefulWidget {
  final dynamic post;
  final UserModel? loggedUser;
  final int fallbackUserId;

  const _MyPostCard({
    required this.post,
    required this.loggedUser,
    required this.fallbackUserId,
  });

  @override
  ConsumerState<_MyPostCard> createState() => _MyPostCardState();
}

class _MyPostCardState extends ConsumerState<_MyPostCard> {
  late final PageController _controller;
  double _currentPage = 0;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 1);
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
          if (img is Map) return img["image_url"]?.toString() ?? "";
          try {
            return img.imageUrl?.toString() ?? "";
          } catch (_) {
            return img.toString();
          }
        })
        .where((e) => e.isNotEmpty)
        .toList();
  }

  int _loggedUserId() {
    final loggedUser = widget.loggedUser;
    final id = loggedUser == null ? null : _read(loggedUser, "id");
    if (id is int) return id;
    if (id != null) return int.tryParse(id.toString()) ?? widget.fallbackUserId;
    return widget.fallbackUserId;
  }

  String _loggedUsername() {
    final loggedUser = widget.loggedUser;
    if (loggedUser == null) return "Unknown";
    return _read(loggedUser, "username")?.toString() ?? "Unknown";
  }

  String? _loggedProfileImage() {
    final loggedUser = widget.loggedUser;
    if (loggedUser == null) return null;
    return _read(loggedUser, "profile_image")?.toString();
  }

  /// Gets the author ID from the post — works for both Map and typed Post
  int _authorId() {
    final post = widget.post;
    // Try post.user.id first (typed Post object)
    try {
      final user = post.user;
      if (user != null) {
        final id = user.id;
        if (id is int) return id;
        return int.tryParse(id.toString()) ?? _loggedUserId();
      }
    } catch (_) {}
    // Try map access
    if (post is Map) {
      final user = post["user"];
      if (user is Map) {
        final id = user["id"];
        if (id is int) return id;
        return int.tryParse(id?.toString() ?? "") ?? _loggedUserId();
      }
      final uid = post["user_id"];
      if (uid is int) return uid;
      return int.tryParse(uid?.toString() ?? "") ?? _loggedUserId();
    }
    // Fallback: these are MY posts so author = logged user
    return _loggedUserId();
  }

  Future<void> _delete(int postId) async {
    if (_isDeleting) return;
    setState(() => _isDeleting = true);
    try {
      await ref
          .read(myPostsProvider(_loggedUserId()).notifier)
          .deletePost(postId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text("Post deleted"),
            ],
          ),
          backgroundColor: Colors.black,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Delete failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final images = _images(_read(post, "images"));
    final count = images.isEmpty ? 1 : images.length;
    final postId = _read(post, "id");

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
                              physics: const PageScrollPhysics(),
                              scrollDirection: Axis.horizontal,
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
                                  errorBuilder: (_, __, ___) => Image.asset(
                                    "assets/images/blogpostcardsample.png",
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.grey[900],
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.pink,
                                          strokeWidth: 2,
                                        ),
                                      ),
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
                    GestureDetector(
                      onTap: postId == null || _isDeleting
                          ? null
                          : () => _delete(postId),
                      child: SizedBox(
                        height: 42,
                        width: 42,
                        child: Center(
                          child: _isDeleting
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.pink,
                                    strokeWidth: 2,
                                  ),
                                )
                              : SvgPicture.asset(
                                  "assets/images/deletepost.svg",
                                  height: 42,
                                  width: 42,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Column(
                      children: [
                        SvgPicture.asset(
                          "assets/images/like.svg",
                          height: 42,
                          width: 42,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "${_read(post, "likes_count") ?? 0}",
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
                    final segmentWidth =
                        count == 1 ? totalWidth : totalWidth / count;
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
                          left: count == 1 ? 0 : _currentPage * segmentWidth,
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

          // ✅ _authorId() safely reads user.id from both Map and typed Post
          BlogContentCard(
            userId: _authorId(),
            source: _read(post, "username")?.toString() ?? _loggedUsername(),
            title: _read(post, "title")?.toString() ?? "",
            content: _read(post, "content")?.toString() ?? "",
            profileImage: _read(post, "profile_image")?.toString() ??
                _loggedProfileImage(),
          ),
        ],
      ),
    );
  }
}