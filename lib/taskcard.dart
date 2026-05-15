import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:open_ui/model/taskmodel.dart';
import 'package:open_ui/taskcommandpage.dart';
import 'package:url_launcher/url_launcher.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(),
          _buildTaskImage(),
          _buildTitle(),
          _buildContent(),
          _buildBottomBar(context),
        ],
      ),
    );
  }

  // ───────────────── PROFILE HEADER ─────────────────
  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF5C6BC0), width: 2),
              gradient: const LinearGradient(
                colors: [Color(0xFF3949AB), Color(0xFF1565C0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: ClipOval(
              child: task.user.profileImage.isNotEmpty
                  ? Image.network(
                      task.user.profileImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return _fallbackAvatar();
                      },
                    )
                  : _fallbackAvatar(),
            ),
          ),

          const SizedBox(width: 10),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.user.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),

              Text(
                "@${task.user.username}",
                style: const TextStyle(
                  color: Color(0xFF82B1FF),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const Spacer(),

          const Icon(Icons.more_horiz_rounded, color: Colors.white54, size: 22),
        ],
      ),
    );
  }

  Widget _fallbackAvatar() {
    return Container(
      color: const Color(0xFF3949AB),
      child: Center(
        child: Text(
          task.user.name.isNotEmpty ? task.user.name[0].toUpperCase() : "?",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  // ───────────────── TASK IMAGE ─────────────────
  Widget _buildTaskImage() {
    if (task.images.isEmpty) {
      return Container(
        height: 160,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A237E), Color(0xFF283593), Color(0xFF1565C0)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -30,
              left: -20,
              child: _blob(120, const Color(0xFF3949AB)),
            ),

            Positioned(
              bottom: -40,
              right: -10,
              child: _blob(100, const Color(0xFF1A237E)),
            ),

            Positioned(top: 16, right: 20, child: _PhonePreviewCard()),

            Positioned(
              bottom: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  "@${task.user.username}",
                  style: const TextStyle(
                    color: Color(0xFF82B1FF),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Image.network(
        task.images.first.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            color: Colors.grey.shade900,
            child: const Center(
              child: Icon(Icons.broken_image, color: Colors.white54, size: 45),
            ),
          );
        },
      ),
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
    );
  }

  // ───────────────── TITLE ─────────────────
  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Text(
        task.title.replaceAll('\n', ' '),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w800,
          height: 1.3,
        ),
      ),
    );
  }

  // ───────────────── CONTENT (with clickable links) ─────────────────
  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: _buildRichContent(task.content),
    );
  }

  /// Parses plain text and turns URLs into tappable links.
  Widget _buildRichContent(String text) {
    final urlRegex = RegExp(r'https?://[^\s]+', caseSensitive: false);

    final spans = <TextSpan>[];
    int lastEnd = 0;

    for (final match in urlRegex.allMatches(text)) {
      // Plain text before the URL
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }

      final url = match.group(0)!;
      spans.add(
        TextSpan(
          text: url,
          style: const TextStyle(
            color: Color(0xFF82B1FF),
            decoration: TextDecoration.underline,
            decorationColor: Color(0xFF82B1FF),
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              final uri = Uri.tryParse(url);
              if (uri != null && await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
        ),
      );

      lastEnd = match.end;
    }

    // Remaining plain text after last URL
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return RichText(
      textAlign: TextAlign.justify,
      text: TextSpan(
        style: const TextStyle(
          color: Color(0xFFB0B0C8),
          fontSize: 13,
          height: 1.55,
        ),
        children: spans,
      ),
    );
  }

  // ───────────────── BOTTOM BAR ─────────────────
  Widget _buildBottomBar(BuildContext context) {
    // Format timestamp — falls back gracefully if task.createdAt is null
    final String timestamp = _formatTimestamp(task.createdAt);

    return Column(
      children: [
        Divider(color: Colors.white.withOpacity(0.08), thickness: 1, height: 1),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          child: Row(
            children: [
              // ── Timestamp (bottom-left) ──
              Text(
                timestamp,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(),

              // ── Comment button ──
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TaskCommentPage(task: task),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A3E),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF3A3A50),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.mode_comment_outlined,
                        color: Colors.white70,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Comment',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // ── Bookmark button ──
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A3E),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF3A3A50),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.bookmark_rounded,
                      color: Colors.white70,
                      size: 22,
                    ),
                  ),

                  Positioned(
                    top: -6,
                    right: -6,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Formats a nullable DateTime into a readable timestamp string.
  String _formatTimestamp(DateTime? dt) {
    if (dt == null) return '';
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;
    return '$day/$month/$year  $hour:$minute';
  }
}

// ───────────────── PHONE PREVIEW CARD ─────────────────
class _PhonePreviewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 130,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 18,
            color: const Color(0xFFF5F5F5),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '4:12',
                  style: TextStyle(fontSize: 8, color: Colors.black87),
                ),
                Row(
                  children: const [
                    Icon(
                      Icons.signal_cellular_alt,
                      size: 8,
                      color: Colors.black87,
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.battery_full, size: 8, color: Colors.black87),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hi David!',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const Text(
                  '8 tasks for today, Monday',
                  style: TextStyle(fontSize: 7, color: Colors.black45),
                ),
                const SizedBox(height: 6),
                _previewRow('9:00', 'Daily stand-up', const Color(0xFF5C6BC0)),
                const SizedBox(height: 4),
                _previewRow(
                  '10:30',
                  'New UI Kit for the app',
                  const Color(0xFF26A69A),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _previewRow(String time, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time,
                style: const TextStyle(fontSize: 7, color: Colors.black45),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 7.5, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
