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
  final IconData? icon;
  final double? iconSize;
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.width,
    this.height,
    this.isLoading = false,
    this.icon,
    this.iconSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isPrimary = type == ButtonType.primary;

    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: width,
        height: height,
        padding: padding ?? EdgeInsets.symmetric(horizontal: 18.r),
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
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Invisible text to maintain size
            Padding(
              padding: EdgeInsets.symmetric(vertical: 18.h),
              child: Opacity(
                opacity: isLoading ? 0.0 : 1.0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        size: iconSize ?? 20.sp,
                        color: isPrimary ? Colors.white : AppTheme.primaryColor,
                      ),
                      SizedBox(width: 8.w),
                    ],
                    Text(
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
                  ],
                ),
              ),
            ),
            // Loading indicator
            if (isLoading)
              Positioned.fill(child: Center(child: _buildLoading())),
          ],
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
