import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_ui/riverpod/postshowprovider.dart';
import 'package:open_ui/riverpod/save_post_provider.dart';
import 'package:open_ui/riverpod/save_post_show.provider.dart';
import 'package:open_ui/widgets/blogpostshimmer.dart';

import 'blopostcontentcard.dart';

class BlogPosImagetCard extends ConsumerStatefulWidget {
  const BlogPosImagetCard({super.key});

  @override
  ConsumerState<BlogPosImagetCard> createState() => _BlogPosImagetCardState();
}

class _BlogPosImagetCardState extends ConsumerState<BlogPosImagetCard> {
  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(postsProvider);

    return postsAsync.when(
      loading: () => const BlogPostShimmer(),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (posts) {
        final currentUsername = "YOUR_LOGGED_USER_NAME";
        final sortedPosts = [...posts];

        sortedPosts.sort((a, b) {
          final aIsMine = a.username == currentUsername;
          final bIsMine = b.username == currentUsername;

          if (aIsMine && !bIsMine) return -1;
          if (!aIsMine && bIsMine) return 1;

          return b.id.compareTo(a.id);
        });

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedPosts.length,
          itemBuilder: (context, index) {
            final post = sortedPosts[index];
            return _PostCard(post: post);
          },
        );
      },
    );
  }
}

class _PostCard extends StatefulWidget {
  final dynamic post;

  const _PostCard({required this.post});

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  late final PageController _controller;
  double _currentPage = 0;

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

  bool _isNetworkImage(String image) {
    return image.startsWith("http://") || image.startsWith("https://");
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    final List images = post.images.isNotEmpty
        ? post.images
        : ['assets/images/blogpostcardsample.png'];

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
                      /// PAGE VIEW
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
                          final img = images[imgIndex].toString();

                          return _isNetworkImage(img)
                              ? Image.network(
                                  img,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  filterQuality: FilterQuality.high,
                                )
                              : Image.asset(
                                  img,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  filterQuality: FilterQuality.high,
                                );
                        },
                      ),

                      /// BLACK OVERLAY
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
                    /// SAVE BUTTON
                    Consumer(
                      builder: (context, ref, _) {
                        final savedPosts = ref.watch(savedPostsProvider);
                        final isSaved = savedPosts.contains(post.id);

                        return GestureDetector(
                          onTap: () async {
                            try {
                              final notifier = ref.read(
                                savedPostsProvider.notifier,
                              );

                              await notifier.savePost(post.id);

                              ref.refresh(savedPostsListProvider);

                              if (!context.mounted) return;

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
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.85),
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                              size: 26,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              "Post saved",
                                              style: TextStyle(
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

                              Future.delayed(const Duration(seconds: 2), () {
                                overlayEntry.remove();
                              });
                            } catch (e) {
                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          },
                          child: SizedBox(
                            height: 42,
                            width: 42,
                            child: Center(
                              child: isSaved
                                  ? const Icon(
                                      Icons.bookmark,
                                      color: Colors.white,
                                      size: 34,
                                    )
                                  : SvgPicture.asset(
                                      "assets/images/save.svg",
                                      height: 42,
                                      width: 42,
                                    ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    /// LIKE BUTTON + COUNT
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
                          "100",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            shadows: [
                              Shadow(
                                blurRadius: 6,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /// SLIDER INDICATOR
              Positioned(
                bottom: 20,
                left: 125,
                right: 125,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final totalWidth = constraints.maxWidth;
                    final segmentWidth = images.length == 1
                        ? totalWidth
                        : totalWidth / images.length;

                    return Stack(
                      children: [
                        /// BG LINE
                        Container(
                          height: 3,
                          width: totalWidth,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),

                        /// ACTIVE LINE
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                          left: images.length == 1
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

          /// TEXT CONTENT
          /// TEXT CONTENT
          BlogContentCard(
            source: post.username,
            title: post.title,
            content: post.content,
            profileImage: post.profileImage,
          ),
        ],
      ),
    );
  }
}
