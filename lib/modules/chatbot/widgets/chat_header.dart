import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../theme/app_theme.dart';
import '../../../widgets/custom_dialog.dart';
import '../controllers/chatbot_controller.dart';

class ChatHeader extends StatelessWidget {
  final ChatbotController controller;
  const ChatHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF04060F).withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 50,
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 24.w,
        right: 24.w,
        top: MediaQuery.of(context).padding.top + 10.h,
        bottom: 12.h,
      ),
      child: Row(
        children: [
          // Bot avatar
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryColor.withOpacity(0.1),
            ),
            child: Center(
              child: Icon(
                Icons.smart_toy_rounded,
                color: AppTheme.primaryColor,
                size: 22.sp,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // Tên và trạng thái
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'chatbot_title'.tr,
                  style: TextStyle(
                    color: AppTheme.textColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3.h),
                Row(
                  children: [
                    Container(
                      width: 7.w,
                      height: 7.w,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      'chatbot_online_status'.tr,
                      style: TextStyle(
                        color: AppTheme.subTextColor,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Nút xóa hội thoại
          ClearChatButton(controller: controller),
        ],
      ),
    );
  }
}

class ClearChatButton extends StatelessWidget {
  final ChatbotController controller;
  const ClearChatButton({super.key, required this.controller});

  void _showClearDialog(BuildContext context) {
    CustomDialog.showConfirm(
      context: context,
      title: 'chatbot_new_conversation'.tr,
      message: 'chatbot_clear_message'.tr,
      confirmText: 'chatbot_clear_confirm'.tr,
      cancelText: 'chatbot_cancel'.tr,
      onConfirm: controller.clearChat,
      type: DialogType.warning,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showClearDialog(context),
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.primaryColor.withOpacity(0.08),
        ),
        child: Icon(
          Icons.refresh_rounded,
          color: AppTheme.primaryColor,
          size: 18.sp,
        ),
      ),
    );
  }
}
