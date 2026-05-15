import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:open_ui/model/task_solution_model.dart';
import 'package:open_ui/model/taskmodel.dart';
import 'package:open_ui/services/api_services.dart';
import 'package:open_ui/taskcard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class TaskCommentPage extends StatefulWidget {
  final TaskModel task;

  const TaskCommentPage({
    super.key,
    required this.task,
  });

  @override
  State<TaskCommentPage> createState() => _TaskCommentPageState();
}

class _TaskCommentPageState extends State<TaskCommentPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late List<TaskSolutionModel> _solutions;
  late TaskModel _task;

  bool _isPosting = false;
  TaskSolutionModel? _replyingTo;

  final Set<String> _expandedReplies = {};

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _solutions = widget.task.solutions;
    _fetchLatest();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _safeUsername(String? username) {
    final value = username?.trim();
    if (value == null || value.isEmpty) {
      return "User";
    }
    return value;
  }

  Future<void> _fetchLatest() async {
    try {
      final tasks = await TaskApi.getTasks();
      final updatedTask = tasks.firstWhere((e) => e.id == widget.task.id);

      if (!mounted) return;

      setState(() {
        _task = updatedTask;
        _solutions = updatedTask.solutions;
      });
    } catch (_) {}
  }

  void _startReply(TaskSolutionModel solution) {
    setState(() {
      _replyingTo = solution;
    });

    _focusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyingTo = null;
    });

    _controller.clear();
    _focusNode.unfocus();
  }

  Future<void> _postSolution() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isPosting) return;

    setState(() {
      _isPosting = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null || token.isEmpty) {
        throw Exception("Token not found");
      }

      final String? parentId = _replyingTo?.id;

      await TaskSolutionApi.addSolution(
        taskId: widget.task.id,
        content: text,
        token: token,
        parentId: parentId,
      );

      if (parentId != null && parentId.isNotEmpty) {
        _expandedReplies.add(parentId);
      }

      final tasks = await TaskApi.getTasks();
      final updatedTask = tasks.firstWhere((e) => e.id == widget.task.id);

      if (!mounted) return;

      setState(() {
        _task = updatedTask;
        _solutions = updatedTask.solutions;
        _controller.clear();
        _replyingTo = null;
      });

      _focusNode.unfocus();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isPosting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final replyingUsername = _safeUsername(_replyingTo?.user.username);

    return Scaffold(
      backgroundColor: const Color(0xFF12121C),
      body: SafeArea(
        child: Column(
          children: [
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
                        color: const Color(0xFF2A2A3E),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TaskCard(task: _task),
                    const SizedBox(height: 20),
                    if (_solutions.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E2E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF2A2A3E),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            "No solutions yet",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ..._solutions.map((solution) {
                      final replies = solution.replies;
                      final isExpanded =
                          _expandedReplies.contains(solution.id);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _CommentBox(
                            solution: solution,
                            isReplying: _replyingTo?.id == solution.id,
                            onReply: () => _startReply(solution),
                          ),
                          if (replies.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 62,
                                bottom: 6,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isExpanded) {
                                      _expandedReplies.remove(solution.id);
                                    } else {
                                      _expandedReplies.add(solution.id);
                                    }
                                  });
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 1,
                                      color: Colors.white24,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isExpanded
                                          ? "Hide replies"
                                          : "View ${replies.length} ${replies.length == 1 ? "reply" : "replies"}",
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (replies.isNotEmpty && isExpanded)
                            Padding(
                              padding: const EdgeInsets.only(left: 50),
                              child: Column(
                                children: replies
                                    .map((reply) => _ReplyBox(reply: reply))
                                    .toList(),
                              ),
                            ),
                        ],
                      );
                    }),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildInputBar(replyingUsername),
    );
  }

  Widget _buildInputBar(String replyingUsername) {
    return Container(
      padding: EdgeInsets.only(
        left: 14,
        right: 14,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 14,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF12121C),
        border: Border(
          top: BorderSide(
            color: Color(0xFF1E1E2E),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_replyingTo != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2E),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF82B1FF).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF82B1FF),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Replying to $replyingUsername",
                          style: const TextStyle(
                            color: Color(0xFF82B1FF),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _replyingTo?.content ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _cancelReply,
                    child: const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white38,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E2E),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF2A2A3E),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                    maxLines: null,
                    minLines: 1,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: _replyingTo != null
                          ? "Reply to $replyingUsername..."
                          : "Post your solution for the task",
                      hintStyle: const TextStyle(
                        color: Color(0xFF6B6B80),
                        fontSize: 13,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _isPosting ? null : _postSolution,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF82B1FF).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF82B1FF).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: _isPosting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: Color(0xFF82B1FF),
                            size: 20,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// NEW FEATURE 1 — Clickable URL helper
// ─────────────────────────────────────────────

/// Parses [text] and returns a [TextSpan] where every URL is tappable.
/// Non-URL segments keep the provided [defaultStyle].
TextSpan buildClickableText(
  String text, {
  required TextStyle defaultStyle,
  TextStyle? urlStyle,
}) {
  final urlPattern = RegExp(
    r'https?://[^\s]+',
    caseSensitive: false,
  );

  final effectiveUrlStyle = urlStyle ??
      defaultStyle.copyWith(
        color: const Color(0xFF82B1FF),
        decoration: TextDecoration.underline,
        decorationColor: const Color(0xFF82B1FF),
      );

  final matches = urlPattern.allMatches(text);
  if (matches.isEmpty) {
    return TextSpan(text: text, style: defaultStyle);
  }

  final spans = <TextSpan>[];
  int cursor = 0;

  for (final match in matches) {
    if (match.start > cursor) {
      spans.add(TextSpan(
        text: text.substring(cursor, match.start),
        style: defaultStyle,
      ));
    }

    final url = match.group(0)!;
    spans.add(TextSpan(
      text: url,
      style: effectiveUrlStyle,
      recognizer: TapGestureRecognizer()
        ..onTap = () async {
          final uri = Uri.tryParse(url);
          if (uri != null && await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
    ));

    cursor = match.end;
  }

  if (cursor < text.length) {
    spans.add(TextSpan(
      text: text.substring(cursor),
      style: defaultStyle,
    ));
  }

  return TextSpan(children: spans);
}

// ─────────────────────────────────────────────
// NEW FEATURE 2 — Timestamp formatter
// ─────────────────────────────────────────────

/// Returns a human-friendly relative timestamp, e.g. "2h ago", "just now".
/// Falls back to an absolute "MMM d, yyyy • HH:mm" string for older posts.
///
/// Expects [TaskSolutionModel] to expose a `createdAt` field of type [DateTime].
/// If your model stores it differently, adjust the accessor below.
String formatTimestamp(DateTime? dateTime) {
  if (dateTime == null) return '';

  final months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  final h = dateTime.hour.toString().padLeft(2, '0');
  final m = dateTime.minute.toString().padLeft(2, '0');

  // Always show: "14 May 2026 • 14:31"
  return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year} • $h:$m';
}

// ─────────────────────────────────────────────
// _CommentBox — now with clickable URLs + timestamp
// ─────────────────────────────────────────────

class _CommentBox extends StatelessWidget {
  final TaskSolutionModel solution;
  final bool isReplying;
  final VoidCallback onReply;

  const _CommentBox({
    required this.solution,
    required this.isReplying,
    required this.onReply,
  });

  String _safeUsername(String? username) {
    final value = username?.trim();
    if (value == null || value.isEmpty) return "User";
    return value;
  }

  String _initials(String username) {
    if (username.length >= 2) return username.substring(0, 2).toUpperCase();
    return username.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final username = _safeUsername(solution.user.username);
    final initials = _initials(username);

    // ── NEW: timestamp string ──────────────────
    final timestamp = formatTimestamp(solution.createdAt);

    // ── NEW: content text style (unchanged from original) ──
    const contentStyle = TextStyle(
      color: Colors.white,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      height: 1.4,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: isReplying
            ? const Color(0xFF1A1A30)
            : const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isReplying
              ? const Color(0xFF82B1FF).withOpacity(0.5)
              : const Color(0xFF2A2A3E),
          width: isReplying ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar column — unchanged
          Column(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueGrey,
                ),
                child: Center(
                  child: Text(
                    initials,
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
                username,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── NEW: clickable URL text ──────────────
                RichText(
                  text: buildClickableText(
                    solution.content,
                    defaultStyle: contentStyle,
                  ),
                ),
                const SizedBox(height: 6),
                // ── NEW: timestamp row ───────────────────
                if (timestamp.isNotEmpty)
                  Text(
                    timestamp,
                    style: const TextStyle(
                      color: Colors.white24,
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: onReply,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      color: isReplying
                          ? const Color(0xFF82B1FF)
                          : Colors.white38,
                      fontSize: 12,
                      fontWeight:
                          isReplying ? FontWeight.w700 : FontWeight.w500,
                    ),
                    child: const Text("Reply"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// _ReplyBox — now with clickable URLs + timestamp
// ─────────────────────────────────────────────

class _ReplyBox extends StatelessWidget {
  final TaskSolutionModel reply;

  const _ReplyBox({required this.reply});

  String _safeUsername(String? username) {
    final value = username?.trim();
    if (value == null || value.isEmpty) return "User";
    return value;
  }

  String _initials(String username) {
    if (username.length >= 2) return username.substring(0, 2).toUpperCase();
    return username.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final username = _safeUsername(reply.user.username);
    final initials = _initials(username);

    // ── NEW: timestamp string ──────────────────
    final timestamp = formatTimestamp(reply.createdAt);

    // ── NEW: content text style (unchanged from original) ──
    const contentStyle = TextStyle(
      color: Colors.white,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      height: 1.4,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF181826),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFF252538),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar column — unchanged
          Column(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF3A3A5C),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                username,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 9,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── NEW: clickable URL text ──────────────
                RichText(
                  text: buildClickableText(
                    reply.content,
                    defaultStyle: contentStyle,
                  ),
                ),
                // ── NEW: timestamp ───────────────────────
                if (timestamp.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    timestamp,
                    style: const TextStyle(
                      color: Colors.white24,
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}