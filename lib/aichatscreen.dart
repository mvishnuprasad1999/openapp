
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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

  bool _isAiTyping = false;
  int _messagesBeforeRequest = 0;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendQuestion() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    FocusScope.of(context).unfocus();

    _messagesBeforeRequest = ref.read(chatProvider).length;

    setState(() {
      _isAiTyping = true;
    });

    _messageController.clear();

    await Future.sync(() {
      return ref.read(chatProvider.notifier).sendMessage(message);
    });
  }

  void _hideTypingIfAnswerArrived(List messages) {
    if (!_isAiTyping || messages.isEmpty) return;

    final hasNewMessage = messages.length > _messagesBeforeRequest;
    final lastMessageIsAi = messages.last.role != "user";

    if (hasNewMessage && lastMessageIsAi) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _isAiTyping = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);

    _hideTypingIfAnswerArrived(messages);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: DefaultTextStyle(
        style: GoogleFonts.lexend(),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF01050A), Color(0xFF081423), Color(0xFF0D244A)],
              stops: [0, 0.42, 1],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                const Positioned(left: 25, top: 20, child: _BackButtonBox()),
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

                Positioned(
                  left: 0,
                  right: 0,
                  top: 80,
                  bottom: 230,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    itemCount: messages.length + (_isAiTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_isAiTyping && index == messages.length) {
                        return const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: _MessageBubble(
                              width: 88,
                              minHeight: 52,
                              color: Color(0xFF1E1E1E),
                              borderColor: Colors.white24,
                              radius: 20,
                              padding: EdgeInsets.all(14),
                              child: _TypingDots(),
                            ),
                          ),
                        );
                      }

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

                const Positioned(left: 23, bottom: 235, child: _SmileButton()),

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
        onTap: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.arrow_back, color: Colors.white, size: 27),
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

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final value = (_controller.value + (index * 0.25)) % 1;
            final opacity = value < 0.5 ? 0.35 + value : 1.35 - value;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Opacity(
                opacity: opacity.clamp(0.35, 1.0),
                child: const CircleAvatar(
                  radius: 4,
                  backgroundColor: Colors.white,
                ),
              ),
            );
          }),
        );
      },
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
      child: SvgPicture.asset(
        'assets/images/c.svg',
        width: 48,
        height: 48,
      ),
    );
  }
}

class _ComposerPanel extends StatelessWidget {
  const _ComposerPanel({required this.controller, required this.onSend});

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
          const Positioned(left: 36, top: 15, child: _ModeText()),
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
