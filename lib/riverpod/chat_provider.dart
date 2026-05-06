
import 'package:flutter_riverpod/legacy.dart';
import 'package:open_ui/services/chat_api.dart';


class ChatMessage {
  final String role; // "user" or "assistant"
  final String content;

  ChatMessage({required this.role, required this.content});
}

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  ChatNotifier() : super([]);

  bool isLoading = false;

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Add user message
    state = [...state, ChatMessage(role: "user", content: message)];

    isLoading = true;

    try {
      final history = state
          .map((m) => {"role": m.role, "content": m.content})
          .toList();

      final reply = await ChatApi.sendMessage(
        query: message,
        history: history,
      );

      // Add assistant reply
      state = [...state, ChatMessage(role: "assistant", content: reply)];
    } catch (e) {
      state = [
        ...state,
        ChatMessage(role: "assistant", content: "Error: $e"),
      ];
    }

    isLoading = false;
  }
}

final chatProvider =
    StateNotifierProvider<ChatNotifier, List<ChatMessage>>(
  (ref) => ChatNotifier(),
);