import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_ui/riverpod/save_post_show.provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_ui/services/save_post_api.dart';
import 'package:open_ui/widgets/blogpostshimmer.dart';
import 'package:open_ui/widgets/bottombar.dart';

import 'blopostcontentcard.dart';

class SavedPostsScreen extends ConsumerWidget {
  const SavedPostsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedPostsAsync = ref.watch(savedPostsListProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Saved Posts",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
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
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(savedPostsListProvider);
                },
                child: ListView.builder(
                  itemCount: savedPosts.length,
                  padding: const EdgeInsets.only(bottom: 120),
                  itemBuilder: (context, index) {
                    final post = savedPosts[index];
                    return _SavedPostCard(post: post);
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

  const _SavedPostCard({required this.post});

  @override
  ConsumerState<_SavedPostCard> createState() => _SavedPostCardState();
}

class _SavedPostCardState extends ConsumerState<_SavedPostCard> {
  late final PageController _controller;
  double _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 1);

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

  List<String> _extractImageUrls(dynamic rawImages) {
    if (rawImages == null || rawImages is! List || rawImages.isEmpty) {
      return [];
    }

    return rawImages
        .map<String>((img) {
          if (img is Map) {
            return img["image_url"]?.toString() ?? "";
          }
          return img.toString();
        })
        .where((url) => url.isNotEmpty)
        .toList();
  }

  Future<void> _unsavePost(BuildContext context, dynamic post) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) return;

      await SavePostApi.savePost(
        postId: post["id"],
        token: token,
      );

      ref.invalidate(savedPostsListProvider);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post unsaved")),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final List<String> images = _extractImageUrls(post["images"]);
    final indicatorCount = images.isEmpty ? 1 : images.length;

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Column(
        children: [
          Stack(
            children: [
              /// IMAGE SLIDER
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
                            setState(() {
                              _currentPage = value.toDouble();
                            });
                          },
                          itemBuilder: (context, imgIndex) {
                            final url = images[imgIndex];

                            return Image.network(
                              url,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  "assets/images/blogpostcardsample.png",
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                );
                              },
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
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

                      /// GRADIENT OVERLAY
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

              /// RIGHT SIDE BUTTONS
              Positioned(
                top: 28,
                right: 18,
                child: Column(
                  children: [
                    /// UNSAVE BUTTON
                    GestureDetector(
                      onTap: () => _unsavePost(context, post),
                      child: SizedBox(
                        height: 42,
                        width: 42,
                        child: Center(
                          child: SvgPicture.asset(
                            "assets/images/unsvae.svg",
                            height: 42,
                            width: 42,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// LIKE BUTTON
                    Column(
                      children: [
                        SizedBox(
                          height: 42,
                          width: 42,
                          child: Center(
                            child: SvgPicture.asset(
                              "assets/images/like.svg",
                              height: 42,
                              width: 42,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${post["likes_count"] ?? 0}",
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

              /// SLIDER PAGE INDICATOR
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

          /// TEXT CONTENT CARD
          BlogContentCard(
            source: post["user"]?["username"] ?? post["username"] ?? "Unknown",
            title: post["title"] ?? "",
            content: post["content"] ?? "",
          ),
        ],
      ),
    );
  }
}