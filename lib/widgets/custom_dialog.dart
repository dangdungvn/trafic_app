import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../theme/app_theme.dart';

enum DialogType { success, error, warning, info }

class CustomDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onPressed;
  final DialogType type;

  const CustomDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonText = 'OK',
    this.onPressed,
    this.type = DialogType.info,
  });

  Color get _color {
    switch (type) {
      case DialogType.success:
        return const Color(0xFF4CAF50);
      case DialogType.error:
        return const Color(0xFFF44336);
      case DialogType.warning:
        return const Color(0xFFFF9800);
      case DialogType.info:
        return AppTheme.primaryColor;
    }
  }

  IconData get _icon {
    switch (type) {
      case DialogType.success:
        return Icons.check_circle_outline;
      case DialogType.error:
        return Icons.error_outline;
      case DialogType.warning:
        return Icons.warning_amber_rounded;
      case DialogType.info:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: const Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: _color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, size: 40.sp, color: _color),
            ),
            SizedBox(height: 20.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppTheme.subTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  onPressed?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  buttonText,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void show({
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
    DialogType type = DialogType.info,
  }) {
    Get.dialog(
      CustomDialog(
        title: title,
        message: message,
        buttonText: buttonText,
        onPressed: onPressed,
        type: type,
      ),
      barrierDismissible: false,
    );
  }
}
