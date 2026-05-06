import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_ui/riverpod/postshowprovider.dart';
import 'blopostcontentcard.dart';

class BlogPosImagetCard extends ConsumerStatefulWidget {
  const BlogPosImagetCard({super.key});

  @override
  ConsumerState<BlogPosImagetCard> createState() => _BlogPosImagetCardState();
}

class _BlogPosImagetCardState extends ConsumerState<BlogPosImagetCard> {
  late final PageController _controller;
  double _page = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();

    _controller.addListener(() {
      if (mounted) {
        setState(() {
          _page = _controller.page ?? 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(postsProvider);

    return postsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),

      data: (posts) {
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];

            final images = post.images.isNotEmpty
                ? post.images
                : ['assets/images/blogpostcardsample.png'];

            /// ✅ EACH CARD HAS ITS OWN CONTROLLER
            final PageController controller = PageController();
            double currentPage = 0;

            controller.addListener(() {
              currentPage = controller.page ?? 0;
            });

            return StatefulBuilder(
              builder: (context, setState) {
                controller.addListener(() {
                  setState(() {
                    currentPage = controller.page ?? 0;
                  });
                });

                return Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          /// ✅ IMAGE SLIDER (WORKS NOW)
                          Container(
                            margin: const EdgeInsets.all(5.0),
                            height: 408,
                            width: double.infinity,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(38),
                              child: PageView.builder(
                                controller: controller,
                                itemCount: images.length,
                                itemBuilder: (context, imgIndex) {
                                  final img = images[imgIndex];

                                  return img.startsWith("http")
                                      ? Image.network(img, fit: BoxFit.cover)
                                      : Image.asset(img, fit: BoxFit.cover);
                                },
                              ),
                            ),
                          ),

                          /// ✅ SLIDER INDICATOR (SMOOTH)
                          Positioned(
                            bottom: 20,
                            left: 125,
                            right: 125,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final totalWidth = constraints.maxWidth;
                                final segmentWidth = totalWidth / images.length;

                                final clampedPage = currentPage.clamp(
                                  0.0,
                                  (images.length - 1).toDouble(),
                                );

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
                                    Transform.translate(
                                      offset: Offset(
                                        clampedPage * segmentWidth,
                                        0,
                                      ),
                                      child: Container(
                                        height: 3,
                                        width: segmentWidth,
                                        decoration: BoxDecoration(
                                          color: Colors.pink,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
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

                      /// TEXT
                      BlogContentCard(
                        source: post.username,
                        title: post.title,
                        content: post.content,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
