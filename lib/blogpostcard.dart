import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_ui/blopostcontentcard.dart';
import 'package:open_ui/widgets/bottombar.dart';

class BlogPosImagetCard extends StatelessWidget {
  const BlogPosImagetCard({super.key});

  static const String _source = 'vp007';
  static const String _title =
      'Oracle reportedly initiated one of the largest mass layoffs in its history';
  static const String _content =
      "Oracle's 2026 workforce reduction has impacted approximately 30,000 employees globally—roughly 18% of its staff—as the company aggressively pivots its resources toward AI infrastructure and automated code generation. The layoffs have been particularly significant in India, where an estimated 12,000 roles were cut, and across the Oracle Health division. This restructuring reflects a strategic shift where Oracle is leveraging advanced AI models to streamline product development, allowing them to replace traditional engineering and sales roles with leaner, AI-driven teams focused on high-growth cloud services. Further announcements are expected in the coming weeks as the company realigns its global workforce strategy to match aggressive cloud expansion goals.";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                margin: const EdgeInsets.all(5.0),
                height: 408,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(38),
                  border: Border.all(color: Colors.white, width: 5),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/blogpostcardsample.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(5.0),
                height: 408,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(38),
                  border: Border.all(color: const Color(0xFF605E5E), width: 5),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.black.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 20,
                top: 20,
                child: IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset(
                    'assets/images/save.svg',
                    width: 50,
                    height: 50,
                  ),
                ),
              ),
              Positioned(
                right: 28,
                top: 82,
                child: IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset(
                    'assets/images/like.svg',
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
              Positioned(
                right: 39,
                top: 130,
                child: Text(
                  "100",
                  style: GoogleFonts.lexend(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),

          const BlogContentCard(
            source: _source,
            title: _title,
            content: _content,
          ),
       
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
