// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'package:open_ui/riverpod/likestaeprovider.dart';
// import 'package:open_ui/riverpod/postshowprovider.dart';
// import 'package:open_ui/riverpod/save_post_provider.dart';
// import 'package:open_ui/riverpod/save_post_show.provider.dart';
// import 'package:open_ui/services/api_services.dart';
// import 'package:open_ui/widgets/blogpostshimmer.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'blopostcontentcard.dart';

// class BlogPosImagetCard extends ConsumerStatefulWidget {
//   const BlogPosImagetCard({super.key});

//   @override
//   ConsumerState<BlogPosImagetCard> createState() => _BlogPosImagetCardState();
// }

// class _BlogPosImagetCardState extends ConsumerState<BlogPosImagetCard> {
//   @override
//   Widget build(BuildContext context) {
//     final postsAsync = ref.watch(postsProvider);

//     return postsAsync.when(
//       loading: () => const BlogPostShimmer(),
//       error: (e, _) => Center(child: Text(e.toString())),
//       data: (posts) {
//         final currentUsername = "YOUR_LOGGED_USER_NAME";
//         final sortedPosts = [...posts];

//         sortedPosts.sort((a, b) {
//           final aIsMine = a.username == currentUsername;
//           final bIsMine = b.username == currentUsername;

//           if (aIsMine && !bIsMine) return -1;
//           if (!aIsMine && bIsMine) return 1;

//           return b.id.compareTo(a.id);
//         });

//         // Seed like state after build completes to avoid modifying provider during build
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           for (final post in sortedPosts) {
//             ref.read(likeStateProvider.notifier).init(
//                   post.id,
//                   isLiked: post.isLiked,
//                   likeCount: post.likesCount,
//                 );
//           }
//         });

//         return ListView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: sortedPosts.length,
//           itemBuilder: (context, index) {
//             final post = sortedPosts[index];
//             return _PostCard(
//               key: ValueKey(post.id),
//               post: post,
//             );
//           },
//         );
//       },
//     );
//   }
// }

// class _PostCard extends ConsumerStatefulWidget {
//   final dynamic post;

//   const _PostCard({
//     super.key,
//     required this.post,
//   });

//   @override
//   ConsumerState<_PostCard> createState() => _PostCardState();
// }

// class _PostCardState extends ConsumerState<_PostCard> {
//   late final PageController _controller;
//   double _currentPage = 0;

//   bool _isLikeLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _controller = PageController(viewportFraction: 1);
//     _controller.addListener(() {
//       if (!mounted) return;
//       setState(() {
//         _currentPage = _controller.page ?? 0;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   bool _isNetworkImage(String image) {
//     return image.startsWith("http://") || image.startsWith("https://");
//   }

//   int _toInt(dynamic value) {
//     if (value == null) return 0;
//     if (value is int) return value;
//     return int.tryParse(value.toString()) ?? 0;
//   }

//   Future<void> _toggleLike(BuildContext context) async {
//     if (_isLikeLoading) return;

//     final postId = widget.post.id as int;
//     final likeNotifier = ref.read(likeStateProvider.notifier);
//     final currentState = ref.read(likeStateProvider)[postId];

//     if (currentState == null) return;

//     final wasLiked = currentState.isLiked;
//     final oldCount = currentState.likeCount;

//     // Optimistic update in shared provider
//     likeNotifier.update(
//       postId,
//       isLiked: !wasLiked,
//       likeCount: wasLiked
//           ? (oldCount - 1).clamp(0, 999999)
//           : oldCount + 1,
//     );

//     setState(() => _isLikeLoading = true);

//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString("token");

//       if (token == null) throw Exception("User not logged in");

//       final result = wasLiked
//           ? await PostActionApi.unlikePost(postId: postId, token: token)
//           : await PostActionApi.likePost(postId: postId, token: token);

//       final updatedLikeCount =
//           result["likes_count"] ?? result["likesCount"] ?? result["like_count"];
//       final updatedIsLiked =
//           result["is_liked"] ?? result["isLiked"] ?? result["liked"];

//       if (!mounted) return;

//       // Update shared provider with server truth
//       likeNotifier.update(
//         postId,
//         isLiked: updatedIsLiked != null ? updatedIsLiked == true : !wasLiked,
//         likeCount: updatedLikeCount != null ? _toInt(updatedLikeCount) : (wasLiked ? (oldCount - 1).clamp(0, 999999) : oldCount + 1),
//       );

//       ref.invalidate(postsProvider);
//     } catch (e) {
//       if (mounted) {
//         // Rollback
//         likeNotifier.update(postId, isLiked: wasLiked, likeCount: oldCount);
//       }

//       if (!context.mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString())),
//       );
//     } finally {
//       if (mounted) setState(() => _isLikeLoading = false);
//     }
//   }

//   void _showSavedOverlay(BuildContext context) {
//     final overlay = Overlay.of(context);

//     final overlayEntry = OverlayEntry(
//       builder: (context) => Positioned(
//         top: MediaQuery.of(context).padding.top + 20,
//         left: 0,
//         right: 0,
//         child: Material(
//           color: Colors.transparent,
//           child: Center(
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.85),
//                 borderRadius: BorderRadius.circular(30),
//               ),
//               child: const Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.check_circle, color: Colors.green, size: 26),
//                   SizedBox(width: 8),
//                   Text(
//                     "Post saved",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );

//     overlay.insert(overlayEntry);
//     Future.delayed(const Duration(seconds: 2), () => overlayEntry.remove());
//   }

//   @override
//   Widget build(BuildContext context) {
//     final post = widget.post;
//     final postId = post.id as int;

//     // Watch shared like state — rebuilds when liked/unliked from either screen
//     final likeMap = ref.watch(likeStateProvider);
//     final likeState = likeMap[postId];
//     final isLiked = likeState?.isLiked ?? post.isLiked;
//     final likeCount = likeState?.likeCount ?? post.likesCount;

//     final List images = post.images.isNotEmpty
//         ? post.images
//         : ['assets/images/blogpostcardsample.png'];

//     return Padding(
//       padding: const EdgeInsets.all(2.0),
//       child: Column(
//         children: [
//           Stack(
//             children: [
//               Container(
//                 margin: const EdgeInsets.all(5.0),
//                 height: 200,
//                 width: double.infinity,
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(38),
//                   child: Stack(
//                     children: [
//                       PageView.builder(
//                         controller: _controller,
//                         physics: const PageScrollPhysics(),
//                         scrollDirection: Axis.horizontal,
//                         itemCount: images.length,
//                         onPageChanged: (value) {
//                           setState(() {
//                             _currentPage = value.toDouble();
//                           });
//                         },
//                         itemBuilder: (context, imgIndex) {
//                           final img = images[imgIndex].toString();

//                           return _isNetworkImage(img)
//                               ? Image.network(
//                                   img,
//                                   width: double.infinity,
//                                   height: double.infinity,
//                                   fit: BoxFit.cover,
//                                   filterQuality: FilterQuality.high,
//                                 )
//                               : Image.asset(
//                                   img,
//                                   width: double.infinity,
//                                   height: double.infinity,
//                                   fit: BoxFit.cover,
//                                   filterQuality: FilterQuality.high,
//                                 );
//                         },
//                       ),
//                       Positioned.fill(
//                         child: IgnorePointer(
//                           child: DecoratedBox(
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 begin: Alignment.centerLeft,
//                                 end: Alignment.centerRight,
//                                 colors: [
//                                   Colors.black.withOpacity(0.15),
//                                   Colors.transparent,
//                                   Colors.black.withOpacity(0.55),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               Positioned(
//                 top: 28,
//                 right: 18,
//                 child: Column(
//                   children: [
//                     Consumer(
//                       builder: (context, ref, _) {
//                         final savedPosts = ref.watch(savedPostsProvider);
//                         final isSaved = savedPosts.contains(post.id);

//                         return GestureDetector(
//                           onTap: () async {
//                             try {
//                               final notifier =
//                                   ref.read(savedPostsProvider.notifier);
//                               await notifier.savePost(post.id);
//                               ref.invalidate(savedPostsListProvider);
//                               if (!context.mounted) return;
//                               _showSavedOverlay(context);
//                             } catch (e) {
//                               if (!context.mounted) return;
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(content: Text(e.toString())),
//                               );
//                             }
//                           },
//                           child: SizedBox(
//                             height: 42,
//                             width: 42,
//                             child: Center(
//                               child: isSaved
//                                   ? const Icon(
//                                       Icons.bookmark,
//                                       color: Colors.white,
//                                       size: 34,
//                                     )
//                                   : SvgPicture.asset(
//                                       "assets/images/save.svg",
//                                       height: 42,
//                                       width: 42,
//                                     ),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 12),
//                     Column(
//                       children: [
//                         GestureDetector(
//                           onTap: () => _toggleLike(context),
//                           child: SizedBox(
//                             height: 42,
//                             width: 42,
//                             child: Center(
//                               child: _isLikeLoading
//                                   ? const SizedBox(
//                                       height: 24,
//                                       width: 24,
//                                       child: CircularProgressIndicator(
//                                         color: Colors.blue,
//                                         strokeWidth: 2,
//                                       ),
//                                     )
//                                   : SvgPicture.asset(
//                                       "assets/images/like.svg",
//                                       height: 42,
//                                       width: 42,
//                                       colorFilter: isLiked
//                                           ? const ColorFilter.mode(
//                                               Colors.blue,
//                                               BlendMode.srcIn,
//                                             )
//                                           : null,
//                                     ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           likeCount.toString(),
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.w700,
//                             shadows: [
//                               Shadow(
//                                 blurRadius: 6,
//                                 color: Colors.black.withOpacity(0.5),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               Positioned(
//                 bottom: 20,
//                 left: 125,
//                 right: 125,
//                 child: LayoutBuilder(
//                   builder: (context, constraints) {
//                     final totalWidth = constraints.maxWidth;
//                     final segmentWidth = images.length == 1
//                         ? totalWidth
//                         : totalWidth / images.length;

//                     return Stack(
//                       children: [
//                         Container(
//                           height: 3,
//                           width: totalWidth,
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.5),
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                         AnimatedPositioned(
//                           duration: const Duration(milliseconds: 250),
//                           curve: Curves.easeOut,
//                           left: images.length == 1
//                               ? 0
//                               : _currentPage * segmentWidth,
//                           child: Container(
//                             height: 3,
//                             width: segmentWidth,
//                             decoration: BoxDecoration(
//                               color: Colors.pink,
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                         ),
//                       ],
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//           // post is of type Post from createpostshowmodel.dart
// BlogContentCard(
//   loggedUserId: loggedUserId,           // your logged-in user's ID
//   postAuthorId: post.user?.id ?? post.id, // ← the person who wrote the post
//   source: post.username,
//   title: post.title,
//   content: post.content,
//   profileImage: post.profileImage,
// ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:open_ui/riverpod/likestaeprovider.dart';
import 'package:open_ui/riverpod/postshowprovider.dart';
import 'package:open_ui/riverpod/save_post_provider.dart';
import 'package:open_ui/riverpod/save_post_show.provider.dart';
import 'package:open_ui/services/api_services.dart';
import 'package:open_ui/widgets/blogpostshimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'blopostcontentcard.dart';

class BlogPosImagetCard extends ConsumerStatefulWidget {
  const BlogPosImagetCard({super.key});

  @override
  ConsumerState<BlogPosImagetCard> createState() => _BlogPosImagetCardState();
}

class _BlogPosImagetCardState extends ConsumerState<BlogPosImagetCard> {
  int? _loggedUserId;

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
      if (mounted) {
        setState(() => _loggedUserId = user.id);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(postsProvider);

    return postsAsync.when(
      loading: () => const BlogPostShimmer(),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (posts) {
        final sortedPosts = [...posts];
        sortedPosts.sort((a, b) => b.id.compareTo(a.id));

        WidgetsBinding.instance.addPostFrameCallback((_) {
          for (final post in sortedPosts) {
            ref
                .read(likeStateProvider.notifier)
                .init(
                  post.id,
                  isLiked: post.isLiked,
                  likeCount: post.likesCount,
                );
          }
        });

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedPosts.length,
          itemBuilder: (context, index) {
            final post = sortedPosts[index];
            return _PostCard(
              key: ValueKey(post.id),
              post: post,
              loggedUserId: _loggedUserId ?? 0,
            );
          },
        );
      },
    );
  }
}

class _PostCard extends ConsumerStatefulWidget {
  final dynamic post;
  final int loggedUserId;

  const _PostCard({super.key, required this.post, required this.loggedUserId});

  @override
  ConsumerState<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<_PostCard> {
  late final PageController _controller;
  double _currentPage = 0;
  bool _isLikeLoading = false;

  @override
  void initState() {
    super.initState();
    // ✅ FIX 1: removed viewportFraction (defaults to 1.0) — explicit 1.0
    //           causes sub-pixel rounding that stutters; omitting it is cleaner.
    _controller = PageController();
    // ✅ FIX 2: listener drives the indicator; no setState needed in onPageChanged.
    _controller.addListener(() {
      if (!mounted) return;
      final page = _controller.page ?? 0;
      if ((page - _currentPage).abs() > 0.001) {
        setState(() => _currentPage = page);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isNetworkImage(String image) {
    return image.startsWith("http://") || image.startsWith("https://");
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  Future<void> _toggleLike(BuildContext context) async {
    if (_isLikeLoading) return;

    final postId = widget.post.id as int;
    final likeNotifier = ref.read(likeStateProvider.notifier);
    final currentState = ref.read(likeStateProvider)[postId];

    if (currentState == null) return;

    final wasLiked = currentState.isLiked;
    final oldCount = currentState.likeCount;

    likeNotifier.update(
      postId,
      isLiked: !wasLiked,
      likeCount: wasLiked ? (oldCount - 1).clamp(0, 999999) : oldCount + 1,
    );

    setState(() => _isLikeLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) throw Exception("User not logged in");

      final result = wasLiked
          ? await PostActionApi.unlikePost(postId: postId, token: token)
          : await PostActionApi.likePost(postId: postId, token: token);

      final updatedLikeCount =
          result["likes_count"] ?? result["likesCount"] ?? result["like_count"];
      final updatedIsLiked =
          result["is_liked"] ?? result["isLiked"] ?? result["liked"];

      if (!mounted) return;

      likeNotifier.update(
        postId,
        isLiked: updatedIsLiked != null ? updatedIsLiked == true : !wasLiked,
        likeCount: updatedLikeCount != null
            ? _toInt(updatedLikeCount)
            : (wasLiked ? (oldCount - 1).clamp(0, 999999) : oldCount + 1),
      );

      ref.invalidate(postsProvider);
    } catch (e) {
      if (mounted) {
        likeNotifier.update(postId, isLiked: wasLiked, likeCount: oldCount);
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLikeLoading = false);
    }
  }

  void _showSavedOverlay(BuildContext context) {
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
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 26),
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
    Future.delayed(const Duration(seconds: 2), () => overlayEntry.remove());
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final postId = post.id as int;

    final int authorId = post.user?.id ?? postId;

    final likeMap = ref.watch(likeStateProvider);
    final likeState = likeMap[postId];
    final isLiked = likeState?.isLiked ?? post.isLiked;
    final likeCount = likeState?.likeCount ?? post.likesCount;

    final List images = post.images.isNotEmpty
        ? post.images
        : ['assets/images/blogpostcardsample.png'];

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                margin: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(38),
                ),
                child: SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(36),
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: _controller,
                          // ✅ FIX 3: BouncingScrollPhysics gives a natural,
                          //           fluid feel; no janky snapping.
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          scrollDirection: Axis.horizontal,
                          itemCount: images.length,
                          // ✅ FIX 4: onPageChanged REMOVED — the controller
                          //           listener above already updates _currentPage
                          //           every frame, so a second setState here was
                          //           causing a double-rebuild that broke smoothness.
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
              ),
              Positioned(
                top: 28,
                right: 18,
                child: Column(
                  children: [
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
                              ref.invalidate(savedPostsListProvider);
                              if (!context.mounted) return;
                              _showSavedOverlay(context);
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
          BlogContentCard(
            userId: post.user?.id ?? 0,
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