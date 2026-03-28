import 'package:get/get.dart';
import '../../core/network/api_client.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, DateTime? timestamp})
      : timestamp = timestamp ?? DateTime.now();
}

class ChatController extends GetxController {
  final ApiClient _client = Get.find<ApiClient>();

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = false.obs;
  final RxString inputText = ''.obs;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    messages.add(ChatMessage(text: text.trim(), isUser: true));
    inputText.value = '';
    isLoading.value = true;

    try {
      final response = await _client.safePost('/chat', {
        'message': text.trim(),
      });
      final body = response.body as Map<String, dynamic>;
      final reply = body['reply'] as String? ?? 'No response';
      messages.add(ChatMessage(text: reply, isUser: false));
    } catch (e) {
      messages.add(ChatMessage(
        text: 'Sorry, I had trouble processing that. Please try again.',
        isUser: false,
      ));
    } finally {
      isLoading.value = false;
    }
  }
}
