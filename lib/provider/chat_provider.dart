import 'package:chatai/model/chatmessage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hooks_riverpod/legacy.dart';

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  ChatNotifier() : super([]);

  final geminiapikey = dotenv.env['GEMINI_API_KEY'];
  late final _model = GenerativeModel(
    model: 'gemini-2.5-flash',
    apiKey: geminiapikey.toString(),
  );

  void addUserMessage(String text) {
    state = [
      ...state,
      ChatMessage(text: text, isUser: true, time: DateTime.now()),
    ];
  }

  void addBotMessage(String text) {
    state = [
      ...state,
      ChatMessage(text: text, isUser: false, time: DateTime.now()),
    ];
  }

  Future<void> sendMessage(String text) async {
    addUserMessage(text);

    try {
      final stream = _model.generateContentStream([Content.text(text)]);
      String buffer = '';

      addBotMessage("Kalemp sedang mengetik...");

      await for (final event in stream) {
        buffer += event.text ?? '';

        final updatedMessages = [...state];
        final lastIndex = updatedMessages.lastIndexWhere((m) => !m.isUser);

        if (lastIndex != -1) {
          updatedMessages[lastIndex] = ChatMessage(
            text: "Kalemp: $buffer",
            isUser: false,
            time: DateTime.now(),
          );
          state = updatedMessages;
        }
      }
    } catch (e) {
      addBotMessage("Terjadi error: $e");
    }
  }

}

final chatProvider =
StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier();
});
