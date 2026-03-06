import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/sos_model.dart'; // Đảm bảo đường dẫn này đúng với project của bạn

class SosBottomSheet {
  static void show({required SosResponseDTO sos}) {
    // Xử lý thời gian (Lấy giờ và phút từ timestamp)
    String timeString = '';
    if (sos.timestamp != null) {
      final localTime = sos.timestamp!.toLocal(); // Chuyển về giờ địa phương
      timeString = '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';
    }

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min, // Tự động co giãn theo nội dung
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thanh kéo nhỏ (Drag handle) ở trên cùng
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // Header: Icon + Tiêu đề + Thời gian
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.emergency, color: Colors.redAccent, size: 28.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Tín hiệu SOS',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                  // Hiển thị thời gian tự động từ backend
                  if (timeString.isNotEmpty)
                    Text(
                      timeString,
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
                    ),
                ],
              ),
              SizedBox(height: 16.h),

              // Nội dung sự cố (Note)
              Text(
                (sos.note != null && sos.note!.isNotEmpty)
                    ? sos.note! // Dữ liệu thật người dùng nhập
                    : 'Cần hỗ trợ khẩn cấp!', // Fallback nếu rỗng
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16.h),

              // Số điện thoại
              Row(
                children: [
                  Icon(Icons.phone, size: 20.sp, color: Colors.grey.shade600),
                  SizedBox(width: 8.w),
                  Text(
                    (sos.phoneNumber != null && sos.phoneNumber!.isNotEmpty)
                        ? sos.phoneNumber! // SĐT thật trả về từ backend
                        : 'Không có số điện thoại',
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.h),

              // Hai Nút: Đóng và Gọi hỗ trợ
              Row(
                children: [
                  // Nút Đóng
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        'Đóng',
                        style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade700),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  
                  // Nút Gọi hỗ trợ
                  Expanded(
                    flex: 2, // Cho nút gọi to hơn nút đóng (giống trong ảnh)
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // Kích hoạt chức năng gọi điện thật
                        if (sos.phoneNumber != null && sos.phoneNumber!.isNotEmpty) {
                          final Uri launchUri = Uri(
                            scheme: 'tel',
                            path: sos.phoneNumber,
                          );
                          if (await canLaunchUrl(launchUri)) {
                            await launchUrl(launchUri, mode: LaunchMode.externalApplication);
                          } else {
                            Get.snackbar('Lỗi', 'Không thể mở trình gọi điện trên thiết bị này');
                          }
                        } else {
                          Get.snackbar('Thông báo', 'Người này không cung cấp số điện thoại!');
                        }
                      },
                      icon: Icon(Icons.call, color: Colors.white, size: 20.sp),
                      label: Text(
                        'Gọi hỗ trợ',
                        style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5), // Màu xanh tím giống y hệt UI
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Để bo góc hoạt động mượt mà
    );
  }
}