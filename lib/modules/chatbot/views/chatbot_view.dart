import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/chatbot_controller.dart';
import '../widgets/chat_header.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/chat_message_list.dart';

class ChatbotView extends GetView<ChatbotController> {
  const ChatbotView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            ChatHeader(controller: controller),
            Expanded(
              child: ColoredBox(
                color: const Color(0xFFF5F5F5),
                child: ChatMessageList(controller: controller),
              ),
            ),
            ChatInputBar(controller: controller),
          ],
        ),
      ),
    );
  }
}
