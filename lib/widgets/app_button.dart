import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import '../services/assets_service.dart';
import '../theme/app_theme.dart';

enum ButtonType { primary, secondary }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonType type;
  final double? width;
  final double? height;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.width,
    this.height,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPrimary = type == ButtonType.primary;

    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: width,
        height: height,
        padding: EdgeInsets.symmetric(vertical: isLoading ? 9.h : 18.h),
        decoration: BoxDecoration(
          color: isPrimary ? AppTheme.primaryColor : const Color(0xFFEDEFFF),
          borderRadius: BorderRadius.circular(100.r),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.25),
                    offset: const Offset(4, 8),
                    blurRadius: 24,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isLoading
              ? _buildLoading()
              : Text(
                  text,
                  textAlign: TextAlign.center,
                  style: isPrimary
                      ? TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        )
                      : TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                        ),
                ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    try {
      final composition = AssetsService.to.loadingComposition.value;
      if (composition != null) {
        return Lottie(
          composition: composition,
          height: 40.h,
          fit: BoxFit.contain,
          renderCache: RenderCache.drawingCommands,
        );
      }
      return Lottie.asset(
        'assets/animations/Loading.json',
        height: 40.h,
        fit: BoxFit.contain,
        renderCache: RenderCache.drawingCommands,
      );
    } catch (e) {
      return SizedBox(
        height: 40.h,
        width: 40.h,
        child: const CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      );
    }
  }
}
