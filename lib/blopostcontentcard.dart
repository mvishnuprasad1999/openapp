import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_ui/model/user_model.dart';
import 'package:open_ui/perticularuserprofile.dart';
import 'package:open_ui/riverpod/followinguser_provider.dart';

class BlogContentCard extends ConsumerStatefulWidget {
  final int userId;
  final String source;
  final String title;
  final String content;
  final String? profileImage;

  const BlogContentCard({
    super.key,
    required this.userId,
    required this.source,
    required this.title,
    required this.content,
    required this.profileImage,
  });

  @override
  ConsumerState<BlogContentCard> createState() => _BlogContentCardState();
}

class _BlogContentCardState extends ConsumerState<BlogContentCard> {
  final PageController _pageController = PageController();

  int _currentPage = 0;
  bool _loadingFollow = false;

  static TextStyle get _contentStyle => GoogleFonts.lexend(
        fontSize: 13,
        height: 1.4,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
        color: const Color(0xFFB8B8B8),
      );

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(followingProvider.notifier).loadFollowing();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _toggleFollow(bool isFollowing) async {
    if (_loadingFollow) return;

    setState(() {
      _loadingFollow = true;
    });

    final notifier = ref.read(followingProvider.notifier);

    try {
      if (isFollowing) {
        await notifier.unfollowUser(widget.userId);
      } else {
        await notifier.followUser(
          UserModel(
            id: widget.userId,
            email: '',
            name: widget.source,
            username: widget.source,
            profileImage: widget.profileImage,
            profileTitle: widget.title,
            profileDescription: '',
            posts: const [],
            isFollowing: true,
          ),
        );
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _loadingFollow = false;
      });
    }
  }

  List<String> _splitContentIntoChunks({
    required String content,
    required double maxWidth,
    required TextStyle style,
    int maxLines = 12,
  }) {
    final cleanContent = content.trim();

    if (cleanContent.isEmpty) return [];

    final words = cleanContent.split(RegExp(r'\s+'));
    final chunks = <String>[];

    final painter = TextPainter(
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
    );

    String currentChunk = '';

    for (final word in words) {
      final testChunk = currentChunk.isEmpty ? word : '$currentChunk $word';

      painter.text = TextSpan(text: testChunk, style: style);
      painter.layout(maxWidth: maxWidth);

      if (painter.didExceedMaxLines) {
        if (currentChunk.isNotEmpty) {
          chunks.add(currentChunk);
        }

        currentChunk = word;
      } else {
        currentChunk = testChunk;
      }
    }

    if (currentChunk.isNotEmpty) {
      chunks.add(currentChunk);
    }

    return chunks;
  }

  @override
  Widget build(BuildContext context) {
    final isFollowing =
        ref.watch(followingProvider.notifier).isFollowing(widget.userId);

    final maxWidth = MediaQuery.of(context).size.width - 16 - 24;

    final chunks = _splitContentIntoChunks(
      content: widget.content,
      maxWidth: maxWidth,
      style: _contentStyle,
    );

    final double slideHeight =
        (_contentStyle.fontSize! * (_contentStyle.height ?? 1.0) * 12)
            .toDouble();

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6C3FC5),
            Color(0xFF1A1A2E),
            Color(0xFF4B2A9E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C3FC5).withOpacity(0.35),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: const Color(0xFF0E0E1C),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),

            /// HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                children: [
                  /// PROFILE IMAGE with Hero + tap navigation
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PerticularProfileShowScreen(
                            userId: widget.userId,
                          ),
                        ),
                      );
                    },
                    child: Hero(
                      tag: "user_${widget.userId}",
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF7C3AED),
                              Color(0xFF4F27B3),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7C3AED).withOpacity(0.45),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.transparent,
                          backgroundImage: widget.profileImage != null &&
                                  widget.profileImage!.isNotEmpty
                              ? NetworkImage(widget.profileImage!)
                              : const AssetImage('assets/images/userlogo.jpg')
                                  as ImageProvider,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  /// USERNAME
                  Expanded(
                    child: Text(
                      widget.source,
                      style: GoogleFonts.lexend(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFFFFFF),
                      ),
                    ),
                  ),

                  /// FOLLOW BUTTON with loading + toggle logic
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: GestureDetector(
                      key: ValueKey(isFollowing),
                      onTap: () => _toggleFollow(isFollowing),
                      child: Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: isFollowing
                              ? null
                              : const LinearGradient(
                                  colors: [
                                    Color(0xFF7C3AED),
                                    Color(0xFF3B82F6),
                                  ],
                                ),
                          color: isFollowing
                              ? const Color(0xFF24242E)
                              : null,
                          border: Border.all(
                            color: isFollowing
                                ? Colors.white12
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_loadingFollow)
                              const SizedBox(
                                height: 14,
                                width: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            else
                              Icon(
                                isFollowing ? Icons.check : Icons.add,
                                size: 16,
                                color: Colors.white,
                              ),
                            const SizedBox(width: 6),
                            Text(
                              isFollowing ? "Following" : "Follow",
                              style: GoogleFonts.lexend(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// TITLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                widget.title,
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFFFFF),
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 8),

            /// CONTENT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: chunks.isEmpty
                  ? const SizedBox()
                  : chunks.length == 1
                      ? Text(
                          chunks.first,
                          textAlign: TextAlign.justify,
                          style: _contentStyle,
                        )
                      : SizedBox(
                          height: slideHeight,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: chunks.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              return Text(
                                chunks[index],
                                textAlign: TextAlign.justify,
                                style: _contentStyle,
                              );
                            },
                          ),
                        ),
            ),

            /// DOTS INDICATOR
            if (chunks.length > 1) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(chunks.length, (i) {
                  return GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        i,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _currentPage
                            ? const Color(0xFF7C3AED)
                            : const Color(0xFF3A3A5C),
                      ),
                    ),
                  );
                }),
              ),
            ],

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}