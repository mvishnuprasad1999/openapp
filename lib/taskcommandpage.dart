import 'package:flutter/material.dart';
import 'package:open_ui/model/taskmodel.dart';
import 'package:open_ui/taskcard.dart';


// ── Simple model for a solution comment ──────────────────────────────────────
class SolutionComment {
  final String username;
  final String avatarLabel;
  final Color avatarColor;
  final String text;
  final String link;

  const SolutionComment({
    required this.username,
    required this.avatarLabel,
    required this.avatarColor,
    required this.text,
    required this.link,
  });
}

// ── Page ─────────────────────────────────────────────────────────────────────
class TaskCommentPage extends StatefulWidget {
  final TaskModel task;

  const TaskCommentPage({super.key, required this.task});

  @override
  State<TaskCommentPage> createState() => _TaskCommentPageState();
}

class _TaskCommentPageState extends State<TaskCommentPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // Dummy comment data — replace with real data source
  final List<SolutionComment> _comments = const [
    SolutionComment(
      username: 'appm',
      avatarLabel: 'AP',
      avatarColor: Color(0xFF5C6BC0),
      text:
          'Created a clean project structure using the MVVM (Model-View-ViewModel) or Clean Architecture pattern.',
      link: 'https://github.com/FlutterDev-Practice/task_manager_mvvm',
    ),
    SolutionComment(
      username: 'devraj',
      avatarLabel: 'DR',
      avatarColor: Color(0xFF26A69A),
      text: 'look this solution i improved it so looks good',
      link: 'https://github.com/FlutterDev-Practice/task_manager_mvvm',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12121C),
      body: SafeArea(
        child: Column(
          children: [
            // ── Back button ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFF2A2A3E), width: 1),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Scrollable content ───────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Task card (same widget reused)
                    TaskCard(task: widget.task),
                    const SizedBox(height: 20),

                    // Solution comments list
                    ..._comments.map((c) => _CommentBox(comment: c)),

                    // Extra bottom padding so FAB doesn't overlap last card
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ── "Post your solution" input bar ────────────────────────────────────
      bottomNavigationBar: _buildInputBar(),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 14,
        right: 14,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 14,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF12121C),
        border: Border(top: BorderSide(color: Color(0xFF1E1E2E), width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2E),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: const Color(0xFF2A2A3E), width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'post your solution for the task',
                        hintStyle: TextStyle(
                          color: Color(0xFF6B6B80),
                          fontSize: 13,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  // Attachment icon
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.attach_file_rounded,
                      color: Colors.white38,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Single comment / solution box ─────────────────────────────────────────────
class _CommentBox extends StatelessWidget {
  final SolutionComment comment;

  const _CommentBox({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A3E), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Column(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: comment.avatarColor,
                ),
                child: Center(
                  child: Text(
                    comment.avatarLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                comment.username,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                // Link
                Text(
                  comment.link,
                  style: const TextStyle(
                    color: Color(0xFF82B1FF),
                    fontSize: 11,
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xFF82B1FF),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Reply button
          GestureDetector(
            onTap: () {},
            child: const Text(
              'Replay',
              style: TextStyle(
                color: Color(0xFF82B1FF),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}