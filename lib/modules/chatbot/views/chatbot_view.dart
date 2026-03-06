import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../theme/app_theme.dart';
import '../../../widgets/custom_dialog.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/primary_button.dart';
import '../controllers/chatbot_controller.dart';

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
            _ChatHeader(controller: controller),
            Expanded(
              child: ColoredBox(
                color: const Color(0xFFF5F5F5),
                child: _ChatMessageList(controller: controller),
              ),
            ),
            _ChatInputBar(controller: controller),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────

class _ChatHeader extends StatelessWidget {
  final ChatbotController controller;
  const _ChatHeader({required this.controller});

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
                  'Trợ lý Giao thông AI',
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
                      'Trực tuyến · Gemini AI',
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
          _ClearButton(controller: controller),
        ],
      ),
    );
  }
}

class _ClearButton extends StatelessWidget {
  final ChatbotController controller;
  const _ClearButton({required this.controller});

  void _showClearDialog(BuildContext context) {
    CustomDialog.showConfirm(
      context: context,
      title: 'Cuộc trò chuyện mới',
      message: 'Bạn có muốn xóa lịch sử và bắt đầu lại không?',
      confirmText: 'Xóa',
      cancelText: 'Hủy',
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

// ─────────────────────────────────────────────
// MESSAGE LIST
// ─────────────────────────────────────────────

class _ChatMessageList extends StatelessWidget {
  final ChatbotController controller;
  const _ChatMessageList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final msgs = controller.messages;
      final isTyping = controller.isTyping.value;
      final showSuggestions = msgs.length <= 1 && !isTyping;
      final extraItems = (isTyping ? 1 : 0) + (showSuggestions ? 1 : 0);

      return ListView.builder(
        controller: controller.scrollController,
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          top: 16.h,
          bottom: 12.h,
        ),
        itemCount: msgs.length + extraItems,
        itemBuilder: (ctx, index) {
          // Gợi ý nhanh (khi hội thoại trống)
          if (showSuggestions && index == msgs.length) {
            return _SuggestionChips(controller: controller);
          }
          // Typing / Streaming bubble
          if (isTyping && index == msgs.length + (showSuggestions ? 1 : 0)) {
            return Obx(() {
              final text = controller.streamingText.value;
              return text.isEmpty
                  ? const _TypingBubble()
                  : _AIMessageBubble(text: text, isStreaming: true);
            });
          }
          // Tin nhắn thông thường
          final msg = msgs[index];
          return msg.isUser
              ? _UserMessageBubble(msg: msg)
              : _AIMessageBubble(
                  text: msg.text,
                  timestamp: msg.timestamp,
                  isError: msg.isError,
                );
        },
      );
    });
  }
}

// ─────────────────────────────────────────────
// AI MESSAGE BUBBLE
// ─────────────────────────────────────────────

class _AIMessageBubble extends StatelessWidget {
  final String text;
  final DateTime? timestamp;
  final bool isStreaming;
  final bool isError;

  const _AIMessageBubble({
    required this.text,
    this.timestamp,
    this.isStreaming = false,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar trợ lý
          Container(
            width: 32.w,
            height: 32.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF4D5DFA), Color(0xFF7B88FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 16.sp,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          // Bubble
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 11.h,
                  ),
                  decoration: BoxDecoration(
                    color: isError
                        ? const Color(0xFFFFEBEE)
                        : Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4.r),
                      topRight: Radius.circular(18.r),
                      bottomLeft: Radius.circular(18.r),
                      bottomRight: Radius.circular(18.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isError
                              ? const Color(0xFFD32F2F)
                              : AppTheme.textColor,
                          height: 1.55,
                        ),
                      ),
                      // Cursor nhấp nháy khi đang stream
                      if (isStreaming)
                        Padding(
                          padding: EdgeInsets.only(top: 2.h),
                          child: const _BlinkingCursor(),
                        ),
                    ],
                  ),
                ),
                if (timestamp != null && !isStreaming)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h, left: 4.w),
                    child: Text(
                      DateFormat('HH:mm').format(timestamp!),
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppTheme.subTextColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 44.w),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// USER MESSAGE BUBBLE
// ─────────────────────────────────────────────

class _UserMessageBubble extends StatelessWidget {
  final ChatMessage msg;
  const _UserMessageBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(width: 44.w),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 11.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4D5DFA), Color(0xFF6B78FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18.r),
                      topRight: Radius.circular(4.r),
                      bottomLeft: Radius.circular(18.r),
                      bottomRight: Radius.circular(18.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4D5DFA).withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white,
                      height: 1.55,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 4.h, right: 4.w),
                  child: Text(
                    DateFormat('HH:mm').format(msg.timestamp),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppTheme.subTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TYPING INDICATOR (3 chấm nảy)
// ─────────────────────────────────────────────

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF4D5DFA), Color(0xFF7B88FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 16.sp,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4.r),
                topRight: Radius.circular(18.r),
                bottomLeft: Radius.circular(18.r),
                bottomRight: Radius.circular(18.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const _TypingDots(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SUGGESTION CHIPS
// ─────────────────────────────────────────────

class _SuggestionChips extends StatelessWidget {
  final ChatbotController controller;
  const _SuggestionChips({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 4.h, bottom: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 44.w, bottom: 8.h),
            child: Text(
              'Hỏi nhanh:',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppTheme.subTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 44.w),
            child: Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: controller.suggestions.map((s) {
                return GestureDetector(
                  onTap: () => controller.sendMessage(s),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.35),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      s,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// INPUT BAR
// ─────────────────────────────────────────────

class _ChatInputBar extends StatelessWidget {
  final ChatbotController controller;
  const _ChatInputBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 10.h,
        bottom: PlatformInfo.isIOS26OrHigher()
            ? MediaQuery.of(context).viewPadding.bottom + 65.h
            : MediaQuery.of(context).padding.bottom + 10.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.dividerColor, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Text input
          Expanded(
            child: CustomTextField(
              controller: controller.textController,
              focusNode: controller.focusNode,
              hintText: 'Nhập tin nhắn...',
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
  }
}

// ─────────────────────────────────────────────
// ANIMATED TYPING DOTS
// ─────────────────────────────────────────────

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 480),
      ),
    );
    _animations = _controllers
        .map(
          (c) => Tween<double>(
            begin: 0,
            end: -7,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut)),
        )
        .toList();

    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 170), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        3,
        (i) => AnimatedBuilder(
          animation: _animations[i],
          builder: (ctx, child) => Transform.translate(
            offset: Offset(0, _animations[i].value),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              width: 9.w,
              height: 9.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withOpacity(0.65),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BLINKING CURSOR (hiệu ứng đang stream)
// ─────────────────────────────────────────────

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
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
      builder: (ctx, child) => Opacity(
        opacity: _controller.value,
        child: Container(
          width: 2.w,
          height: 14.h,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
      ),
    );
  }
}
