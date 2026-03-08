import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/emergency_controller.dart';
import '../../../theme/app_theme.dart';

// ✅ Phải đổi thành StatefulWidget để chạy Animation
class SosActiveScreen extends StatefulWidget {
  const SosActiveScreen({super.key});

  @override
  State<SosActiveScreen> createState() => _SosActiveScreenState();
}

// ✅ Thêm SingleTickerProviderStateMixin để quản lý khung hình (fps)
class _SosActiveScreenState extends State<SosActiveScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // Tạo bộ đếm animation chạy liên tục trong 1.5 giây mỗi chu kỳ
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(); // repeat() giúp sóng phát liên tục không ngừng
  }

  @override
  void dispose() {
    _animationController.dispose(); // Bắt buộc phải hủy để tránh rò rỉ bộ nhớ
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EmergencyController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor, 
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 200.w, 
                height: 200.w,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        _buildRippleEffect(
                          maxRadius: 100.w,
                          value: _animationController.value,
                          delay: 0.5, // Bắt đầu trễ nửa nhịp để tạo hiệu ứng gối nhau
                        ),
                        _buildRippleEffect(
                          maxRadius: 100.w,
                          value: _animationController.value,
                          delay: 0.0,
                        ),
                        Container(
                          width: 80.w,
                          height: 80.w,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.5),
                                blurRadius: 10,
                                spreadRadius: 2,
                              )
                            ]
                          ),
                          child: Icon(Icons.emergency_share, size: 40.sp, color: Colors.white),
                        ),
                      ],
                    );
                  },
                ),
              ),
              
              SizedBox(height: 12.h),
              Text(
                'Đang phát tín hiệu SOS...',
                style: TextStyle(
                  fontSize: 22.sp, 
                  fontWeight: FontWeight.bold, 
                  color: AppTheme.textColor, 
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Hệ thống đang thông báo cho các xe lân cận',
                style: TextStyle(
                  fontSize: 14.sp, 
                  color: AppTheme.subTextColor, 
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 64.h), 

              Obx(() => GestureDetector(
                onTap: controller.isLoading.value ? null : () => controller.cancelActiveSos(),
                child: Opacity(
                  opacity: controller.isLoading.value ? 0.5 : 1.0,
                  child: Column(
                    children: [
                      Container(
                        width: 72.w, 
                        height: 72.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.errorColor, width: 2), 
                          color: AppTheme.backgroundColor,
                        ),
                        child: Icon(Icons.close, color: AppTheme.errorColor, size: 36.sp),
                      ),
                      SizedBox(height: 8.h),
                      Text('Hủy yêu cầu', style: TextStyle(fontSize: 14.sp, color: AppTheme.errorColor, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              )),
              
              SizedBox(height: 32.h),
              
              Obx(() => GestureDetector(
                onTap: controller.isLoading.value ? null : () => controller.resolveActiveSos(),
                child: Opacity(
                  opacity: controller.isLoading.value ? 0.5 : 1.0,
                  child: Column(
                    children: [
                      Container(
                        width: 72.w,
                        height: 72.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.successColor, width: 2), 
                          color: AppTheme.backgroundColor,
                        ),
                        child: Icon(Icons.check, color: AppTheme.successColor, size: 36.sp),
                      ),
                      SizedBox(height: 8.h),
                      Text('Đã được hỗ trợ', style: TextStyle(fontSize: 14.sp, color: AppTheme.successColor, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  // Hàm tự vẽ một vòng sóng lan tỏa (Ripple)
  Widget _buildRippleEffect({required double maxRadius, required double value, required double delay}) {
    // Tính toán lại chu kỳ để có độ trễ
    double progress = (value + delay) % 1.0;
    
    return Container(
      // Vòng tròn to dần theo tiến độ progress (từ 0 -> 1)
      width: 80.w + (maxRadius * progress * 2),
      height: 80.w + (maxRadius * progress * 2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Khi vòng tròn to ra, màu sẽ nhạt dần và biến mất ở progress = 1
        color: AppTheme.primaryColor.withOpacity(0.4 * (1 - progress)),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.8 * (1 - progress)), 
          width: 2
        ),
      ),
    );
  }
}