import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import '../../routes/app_pages.dart';
import '../../theme/app_theme.dart';

import '../../services/assets_service.dart';
import '../../widgets/primary_button.dart';

class NotFoundPage extends StatelessWidget {
  final String animationAsset;
  final String? title;
  final String? subtitle;
  final String? buttonText;

  const NotFoundPage({
    super.key,
    this.animationAsset = 'assets/animations/404_not_found.json',
    this.title,
    this.subtitle,
    this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 260.h,
                  child: AssetsService.to.notFoundComposition.value != null
                      ? Lottie(
                          composition:
                              AssetsService.to.notFoundComposition.value!,
                          fit: BoxFit.contain,
                          repeat: true,
                        )
                      : Lottie.asset(
                          animationAsset,
                          fit: BoxFit.contain,
                          repeat: true,
                          renderCache: RenderCache.drawingCommands,
                        ),
                ),
                SizedBox(height: 24.h),
                Text(
                  title ?? '404_title'.tr,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),
                Text(
                  subtitle ?? '404_subtitle'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.subTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                PrimaryButton(
                  text: buttonText ?? 'go_home'.tr,
                  onPressed: () {
                    Get.offAllNamed(AppPages.INITIAL);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
