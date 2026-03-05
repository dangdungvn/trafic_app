import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_theme.dart';
import 'loading_widget.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final double? height;
  final bool isLoading;
  final Widget? child;
  final bool isCircle;

  const PrimaryButton({
    super.key,
    this.text = '',
    required this.onPressed,
    this.width,
    this.height,
    this.isLoading = false,
    this.child,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 58.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isCircle ? 999.r : 100.r),
          ),
          elevation: 4,
          shadowColor: AppTheme.primaryColor.withOpacity(0.25),
          padding: EdgeInsets.zero,
        ),
        child: isLoading
            ? LoadingWidget(height: isCircle ? (height ?? 48.h) * 0.5 : 40.h)
            : (child ??
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  )),
      ),
    );
  }
}
