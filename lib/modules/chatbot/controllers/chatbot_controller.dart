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
  static const String _systemPrompt =
      'Bạn là trợ lý giao thông thông minh của ứng dụng Traffic App – '
      'ứng dụng thông tin giao thông Việt Nam. '
      'Nhiệm vụ của bạn là hỗ trợ người dùng về: '
      'thông tin và tình trạng giao thông đường bộ; '
      'luật giao thông Việt Nam và các quy định mới nhất; '
      'xử phạt vi phạm giao thông, tra cứu phạt nguội; '
      'biển báo và tín hiệu đường bộ; '
      'cấp cứu và xử lý khi xảy ra tai nạn giao thông; '
      'bảo dưỡng và sửa chữa xe cộ; '
      'lộ trình di chuyển tối ưu và tránh tắc đường. '
      'Luôn trả lời bằng tiếng Việt, ngắn gọn, thân thiện, '
      'chính xác và ưu tiên an toàn giao thông trong mọi tư vấn.';

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
    '🚦 Kiểm tra phạt nguội như thế nào?',
    '📋 Các mức phạt vượt đèn đỏ?',
    '🗺️ Làm gì khi gặp tắc đường?',
    '⚠️ Biển báo giao thông cần biết',
    '🚗 Xử lý thế nào khi tai nạn?',
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
        text:
            'Xin chào! Tôi là Trợ lý Giao thông AI của Traffic App 🚦\n\n'
            'Tôi có thể giúp bạn tra cứu luật giao thông, mức phạt, '
            'biển báo, xử lý tai nạn và nhiều thông tin hữu ích khác.\n\n'
            'Bạn cần hỗ trợ gì không?',
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
        'Lỗi cấu hình',
        'Chưa thiết lập GEMINI_API_KEY trong file .env',
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
        errorMsg =
            '⚠️ Đã vượt giới hạn quota API miễn phí. Vui lòng thử lại sau vài phút hoặc kiểm tra kế hoạch billing tại Google AI Studio.';
      } else if (errStr.contains('401') || errStr.contains('403')) {
        errorMsg =
            '🔑 API key không hợp lệ hoặc không có quyền truy cập. Vui lòng kiểm tra GEMINI_API_KEY trong file .env';
      } else if (errStr.contains('404')) {
        errorMsg = '❌ Model AI không tìm thấy. Vui lòng liên hệ hỗ trợ.';
      } else if (errStr.contains('SocketException') ||
          errStr.contains('network') ||
          errStr.contains('connection')) {
        errorMsg =
            '📡 Không có kết nối mạng. Vui lòng kiểm tra Internet và thử lại.';
      } else {
        errorMsg =
            'Đã xảy ra lỗi. Vui lòng thử lại.\n(${errStr.substring(0, errStr.length.clamp(0, 100))})';
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
