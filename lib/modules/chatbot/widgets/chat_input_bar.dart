import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../theme/app_theme.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/primary_button.dart';
import '../controllers/chatbot_controller.dart';

class ChatInputBar extends StatelessWidget {
  final ChatbotController controller;
  const ChatInputBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller.focusNode,
      builder: (context, child) {
        final isFocused = controller.focusNode.hasFocus;
        return Container(
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            top: 10.h,
            bottom:
                MediaQuery.of(context).viewPadding.bottom +
                (isFocused ? 95.h : 65.h) +
                (GetPlatform.isAndroid ? 50.h : 0),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: AppTheme.dividerColor, width: 1),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Text input
              Expanded(
                child: CustomTextField(
                  controller: controller.textController,
                  focusNode: controller.focusNode,
                  hintText: 'chatbot_input_hint'.tr,
                  maxLines: 4,
                  minLines: 1,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  onSubmitted: (_) =>
                      controller.sendMessage(controller.textController.text),
                ),
              ),
              SizedBox(width: 10.w),
              // Nút gửi (reactive)
              Obx(
                () => PrimaryButton(
                  isCircle: true,
                  width: 48.w,
                  height: 48.w,
                  isLoading: controller.isTyping.value,
                  onPressed: () =>
                      controller.sendMessage(controller.textController.text),
                  child: SvgPicture.asset('assets/icons/big_send.svg'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
