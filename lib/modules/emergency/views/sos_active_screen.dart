import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/emergency_controller.dart';

class SosActiveScreen extends StatelessWidget {
  const SosActiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Căn giữa toàn màn hình
            children: [
              // Tiêu đề trạng thái
              Icon(Icons.radar, size: 80.sp, color: const Color(0xFF4F46E5)),
              SizedBox(height: 24.h),
              Text(
                'Đang phát tín hiệu SOS...',
                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              SizedBox(height: 8.h),
              Text(
                'Hệ thống đang thông báo cho các xe lân cận',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
              ),
              
              SizedBox(height: 80.h), // Khoảng trống lớn trước khi đến 2 nút

              // Nút 1: HỦY TÍN HIỆU (Chữ X)
              GestureDetector(
                onTap: () => Get.find<EmergencyController>().cancelActiveSos(),
                child: Column(
                  children: [
                    Container(
                      width: 80.w, // Nút to đùng cho dễ bấm
                      height: 80.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.redAccent, width: 3),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.redAccent.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))
                        ]
                      ),
                      child: Icon(Icons.close, color: Colors.redAccent, size: 40.sp),
                    ),
                    SizedBox(height: 12.h),
                    Text('Hủy yêu cầu', style: TextStyle(fontSize: 16.sp, color: Colors.redAccent, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              
              SizedBox(height: 48.h), // Khoảng cách xa giữa 2 nút để tránh bấm nhầm
              
              // Nút 2: ĐÃ GIẢI QUYẾT (Chữ V)
              GestureDetector(
                onTap: () => Get.find<EmergencyController>().resolveActiveSos(),
                child: Column(
                  children: [
                    Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.green, width: 3),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.green.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))
                        ]
                      ),
                      child: Icon(Icons.check, color: Colors.green, size: 40.sp),
                    ),
                    SizedBox(height: 12.h),
                    Text('Đã được hỗ trợ', style: TextStyle(fontSize: 16.sp, color: Colors.green, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}