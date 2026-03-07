import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:googleai_dart/googleai_dart.dart';

/// Đại diện cho một tin nhắn trong cuộc hội thoại.
class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });
}

class ChatbotController extends GetxController {
  // System prompt – định danh vai trò trợ lý giao thông
  static const String _systemPrompt = """
ROLE
Bạn là trợ lý giao thông thông minh của ứng dụng Traffic App.

CONTEXT
Traffic App là ứng dụng cung cấp thông tin giao thông tại Việt Nam, hỗ trợ người tham gia giao thông tra cứu luật, tình trạng đường xá và các vấn đề liên quan đến phương tiện.

MISSION
Nhiệm vụ của bạn là hỗ trợ người dùng với các nội dung liên quan đến giao thông tại Việt Nam.

CAPABILITIES
Bạn có thể hỗ trợ người dùng về:
- Thông tin và tình trạng giao thông đường bộ
- Luật giao thông Việt Nam và các quy định mới nhất
- Mức xử phạt vi phạm giao thông và tra cứu phạt nguội
- Giải thích biển báo và tín hiệu giao thông
- Hướng dẫn xử lý khi xảy ra tai nạn giao thông
- Tư vấn bảo dưỡng và sửa chữa phương tiện
- Gợi ý lộ trình di chuyển tối ưu và tránh tắc đường

RULES
- Chỉ cung cấp thông tin liên quan đến giao thông và phương tiện.
- Không cung cấp thông tin sai lệch hoặc suy đoán nếu không chắc chắn.
- Nếu câu hỏi ngoài phạm vi giao thông, hãy lịch sự thông báo rằng bạn chỉ hỗ trợ các vấn đề giao thông.

RESPONSE STYLE
- Luôn trả lời bằng tiếng Việt.
- Ngắn gọn, rõ ràng và dễ hiểu.
- Thân thiện và hỗ trợ người dùng.
- Khi phù hợp, trình bày dạng bullet hoặc từng bước.

PRIORITY
Luôn ưu tiên:
1. An toàn giao thông
2. Thông tin chính xác
3. Hướng dẫn thực tế và dễ áp dụng
""";

  static const String _modelId = 'gemini-2.5-flash-lite';

  final messages = <ChatMessage>[].obs;
  final isTyping = false.obs;
  final streamingText = ''.obs;

  final textController = TextEditingController();
  final scrollController = ScrollController();
  final focusNode = FocusNode();

  late GoogleAIClient _client;
  bool _hasApiKey = false;

  final suggestions = const [
    'chatbot_suggestion_1',
    'chatbot_suggestion_2',
    'chatbot_suggestion_3',
    'chatbot_suggestion_4',
    'chatbot_suggestion_5',
  ];

  @override
  void onInit() {
    super.onInit();
    _initClient();
    _addWelcomeMessage();
  }

  void _initClient() {
    final rawKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    final apiKey = rawKey.trim();
    _hasApiKey = apiKey.isNotEmpty && apiKey != 'YOUR_GEMINI_API_KEY_HERE';
    debugPrint('[Chatbot] hasApiKey=$_hasApiKey, keyLength=${apiKey.length}');
    if (_hasApiKey) {
      _client = GoogleAIClient(
        config: GoogleAIConfig(authProvider: ApiKeyProvider(apiKey)),
      );
    }
  }

  void _addWelcomeMessage() {
    messages.clear();
    messages.add(
      ChatMessage(
        id: 'welcome',
        text: 'chatbot_welcome'.tr,
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || isTyping.value) return;

    if (!_hasApiKey) {
      Get.snackbar(
        'chatbot_config_error'.tr,
        'chatbot_config_error_message'.tr,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    // Thêm tin nhắn người dùng
    messages.add(
      ChatMessage(
        id: '${DateTime.now().millisecondsSinceEpoch}_user',
        text: trimmed,
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );
    textController.clear();
    _scrollToBottom();

    isTyping.value = true;
    streamingText.value = '';

    // Xây dựng lịch sử hội thoại (loại bỏ welcome và error messages)
    final conversationContents = messages
        .where((m) => m.id != 'welcome' && !m.isError)
        .map(
          (m) => m.isUser
              ? Content.user([Part.text(m.text)])
              : Content.model([Part.text(m.text)]),
        )
        .toList();

    try {
      String fullText = '';

      await for (final chunk in _client.models.streamGenerateContent(
        model: _modelId,
        request: GenerateContentRequest(
          systemInstruction: Content(parts: [Part.text(_systemPrompt)]),
          contents: conversationContents,
        ),
      )) {
        final chunkText = chunk.text;
        if (chunkText != null && chunkText.isNotEmpty) {
          fullText += chunkText;
          streamingText.value = fullText;
          _scrollToBottom();
        }
      }

      if (fullText.isNotEmpty) {
        messages.add(
          ChatMessage(
            id: '${DateTime.now().millisecondsSinceEpoch}_ai',
            text: fullText,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      }
    } catch (e, st) {
      debugPrint('[Chatbot] API error: $e');
      debugPrint('[Chatbot] Stack: $st');
      final errStr = e.toString();
      final String errorMsg;
      if (errStr.contains('429')) {
        errorMsg = 'chatbot_error_quota'.tr;
      } else if (errStr.contains('401') || errStr.contains('403')) {
        errorMsg = 'chatbot_error_auth'.tr;
      } else if (errStr.contains('404')) {
        errorMsg = 'chatbot_error_not_found'.tr;
      } else if (errStr.contains('SocketException') ||
          errStr.contains('network') ||
          errStr.contains('connection')) {
        errorMsg = 'chatbot_error_network'.tr;
      } else {
        errorMsg =
            '${'chatbot_error_generic'.tr}\n(${errStr.substring(0, errStr.length.clamp(0, 100))})';
      }
      messages.add(
        ChatMessage(
          id: '${DateTime.now().millisecondsSinceEpoch}_err',
          text: errorMsg,
          isUser: false,
          timestamp: DateTime.now(),
          isError: true,
        ),
      );
    } finally {
      streamingText.value = '';
      isTyping.value = false;
      _scrollToBottom();
    }
  }

  void clearChat() {
    messages.clear();
    textController.clear();
    _addWelcomeMessage();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 80), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    focusNode.dispose();
    if (_hasApiKey) _client.close();
    super.onClose();
  }
}
