import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_ui/riverpod/reverpodprovider.dart';

// <-- your provider file

class BlogContentCard extends ConsumerStatefulWidget {
  final String source;
  final String title;
  final String content;
  final String? profileImage;

  const BlogContentCard({
    super.key,
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

  static TextStyle get _contentStyle => GoogleFonts.lexend(
    fontSize: 13,
    height: 1.4,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
    color: const Color(0xFFB8B8B8),
  );

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width - 16 - 24;

    final chunks = ref.watch(
      blogChunkProvider(
        BlogChunkParams(content: widget.content, maxWidth: maxWidth),
      ),
    );

    final double slideHeight =
        (_contentStyle.fontSize! * (_contentStyle.height ?? 1.0) * 12)
            .toDouble();

    return Container(
      margin: const EdgeInsets.all(8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                CircleAvatar(
                  radius: 18,
                  backgroundImage:
                      widget.profileImage != null &&
                          widget.profileImage!.isNotEmpty
                      ? NetworkImage(widget.profileImage!)
                      : const AssetImage('assets/images/userlogo.jpg')
                            as ImageProvider,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.source,
                    style: GoogleFonts.lexend(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFC79443),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: SvgPicture.asset(
                    'assets/images/blogfollow.svg',
                    width: 40,
                    height: 40,
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
                color: const Color(0xFF00C3D0),
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(height: 8),

          /// CONTENT
          if (chunks.isEmpty)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text("Loading..."),
            )
          else if (chunks.length == 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                chunks.first,
                textAlign: TextAlign.justify,
                style: _contentStyle,
              ),
            )
          else
            SizedBox(
              height: slideHeight,
              child: PageView.builder(
                controller: _pageController,
                itemCount: chunks.length,
                onPageChanged: (i) {
                  setState(() => _currentPage = i);
                },
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    chunks[i],
                    textAlign: TextAlign.justify,
                    style: _contentStyle,
                  ),
                ),
              ),
            ),

          /// DOTS
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
                          ? const Color(0xFF2027E4)
                          : const Color(0xFFD1D5DB),
                    ),
                  ),
                );
              }),
            ),
          ],

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
