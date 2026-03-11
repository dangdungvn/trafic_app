import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../theme/app_theme.dart'; // Nhúng file Theme chuẩn của dự án
import '../controllers/dashboard_controller.dart';

class VoiceSearchBottomSheet extends GetView<DashboardController> {
  const VoiceSearchBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400.h,
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor, // Dùng màu nền chuẩn của app
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF04060F).withOpacity(0.05), // Bóng đổ mờ nhẹ y hệt các thẻ PostItem
            offset: const Offset(0, -4),
            blurRadius: 60,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nút X để đóng
          Padding(
            padding: EdgeInsets.only(left: 16.w, top: 16.h),
            child: IconButton(
              icon: Icon(Icons.close, color: AppTheme.textColor, size: 28.sp),
              onPressed: () => controller.stopVoiceSearch(),
            ),
          ),
          SizedBox(height: 20.h),
          
          // Tiêu đề & Chữ đang nhận diện
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Obx(() {
              final text = controller.searchController.text;
              final isListening = controller.isListening.value;
              
              return Text(
                text.isEmpty 
                    ? (isListening ? "Đang nghe..." : "Mời bạn nói...") 
                    : text,
                style: TextStyle(
                  // Chữ nháp thì dùng subTextColor, chữ thật thì dùng textColor
                  color: text.isEmpty ? AppTheme.subTextColor : AppTheme.textColor,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              );
            }),
          ),
          
          const Spacer(),
          
          // Nút Micro thu âm bự ở giữa với hiệu ứng lan tỏa
          Center(
            child: Obx(() {
              final isListening = controller.isListening.value;
              return GestureDetector(
                onTap: () {
                  if (isListening) {
                    controller.stopVoiceSearch();
                  } else {
                    controller.startListening();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // Vòng mờ lan tỏa bên ngoài khi đang thu âm
                    color: isListening 
                        ? AppTheme.primaryColor.withOpacity(0.15) 
                        : Colors.transparent, 
                  ),
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // Khi đang nghe dùng màu chủ đạo, khi tắt dùng màu nền nhạt
                        color: isListening ? AppTheme.primaryColor : AppTheme.primaryBgColor, 
                        boxShadow: isListening ? [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 5,
                          )
                        ] : [],
                      ),
                      child: Icon(
                        Icons.mic,
                        // Đổi màu icon tương phản với nền
                        color: isListening ? Colors.white : AppTheme.primaryColor,
                        size: 40.sp,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 50.h), // Căn lề dưới
        ],
      ),
    );
  }
}