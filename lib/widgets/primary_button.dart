import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import '../theme/app_theme.dart';
import '../services/assets_service.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final double? height;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height,
    this.isLoading = false,
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
            borderRadius: BorderRadius.circular(100.r),
          ),
          elevation: 4,
          shadowColor: AppTheme.primaryColor.withOpacity(0.25),
        ),
        child: isLoading
            ? _buildLoading()
            : Text(
                text,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildLoading() {
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
  }
}
