import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_ui/riverpod/chat_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _CompanionScreenState();
}

class _CompanionScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendQuestion() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;
    FocusScope.of(context).unfocus();

    ref.read(chatProvider.notifier).sendMessage(message);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: DefaultTextStyle(
        style: GoogleFonts.lexend(),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF01050A),
                Color(0xFF081423),
                Color(0xFF0D244A),
              ],
              stops: [0, 0.42, 1],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                const Positioned(
                  left: 25,
                  top: 20,
                  child: _BackButtonBox(),
                ),
                const Positioned(
                  left: 80,
                  top: 30,
                  child: Text(
                    'Your open companion',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                /// ✅ CHAT LIST (NEW)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 80,
                  bottom: 230,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isUser = msg.role == "user";

                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _MessageBubble(
                            width: 280,
                            minHeight: 52,
                            color: isUser
                                ? const Color(0xFF4264DE)
                                : const Color(0xFF1E1E1E),
                            borderColor: isUser
                                ? const Color(0xFFFFCC00)
                                : Colors.white24,
                            radius: 20,
                            padding: const EdgeInsets.all(14),
                            child: Text(
                              msg.content,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const Positioned(
                  left: 23,
                  bottom: 235,
                  child: _SmileButton(),
                ),

                Positioned(
                  left: 14,
                  right: 13,
                  bottom: 22,
                  child: _ComposerPanel(
                    controller: _messageController,
                    onSend: _sendQuestion,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BackButtonBox extends StatelessWidget {
  const _BackButtonBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.35), width: 1),
      ),
      child: GestureDetector(
        onTap: (){Navigator.pop(context);},
        child: const Icon(
          Icons.arrow_back,
          color: Colors.white,
          size: 27,
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.width,
    required this.minHeight,
    required this.color,
    required this.borderColor,
    required this.radius,
    required this.padding,
    required this.child,
  });

  final double width;
  final double minHeight;
  final Color color;
  final Color borderColor;
  final double radius;
  final EdgeInsets padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      constraints: BoxConstraints(minHeight: minHeight),
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor, width: 1.1),
      ),
      child: child,
    );
  }
}

class _SmileButton extends StatelessWidget {
  const _SmileButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: const BoxDecoration(
        color: Color(0xFFFF1717),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.sentiment_satisfied_alt,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}

class _ComposerPanel extends StatelessWidget {
  const _ComposerPanel({
    required this.controller,
    required this.onSend,
  });

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF071426).withOpacity(0.7),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Stack(
        children: [
          const Positioned(
            left: 36,
            top: 15,
            child: _ModeText(),
          ),
          Positioned(
            left: 8,
            right: 8,
            top: 42,
            child: Container(
              height: 148,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 26,
                    top: 13,
                    right: 54,
                    child: SizedBox(
                      height: 104,
                      child: TextField(
                        controller: controller,
                        maxLines: null,
                        expands: true,
                        cursorColor: Colors.white,
                        style: GoogleFonts.lexend(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '"Ask about any user, post, or topic."',
                          hintStyle: GoogleFonts.lexend(
                            color: Colors.white.withOpacity(0.67),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    bottom: 7,
                    child: GestureDetector(
                      onTap: onSend,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4B48E6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_upward,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
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

class _ModeText extends StatelessWidget {
  const _ModeText();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Text('Ask ', style: TextStyle(color: Colors.white)),
        Text('smarter', style: TextStyle(color: Color(0xFF1FD85D))),
        Text('  Search ', style: TextStyle(color: Colors.white)),
        Text('deeper', style: TextStyle(color: Color(0xFFFF0000))),
      ],
    );
  }
}