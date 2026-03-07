import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:lottie/lottie.dart';

import '../../../../services/assets_service.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/loading_widget.dart';
import '../../../../widgets/primary_button.dart';
import '../controllers/discovery_controller.dart';

class DiscoveryLoadingState extends StatelessWidget {
  const DiscoveryLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const LoadingWidget(height: 100),
          SizedBox(height: 4.h),
          Text(
            'discovery_searching'.tr,
            style: TextStyle(color: AppTheme.subTextColor, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }
}

class DiscoveryEmptyState extends StatelessWidget {
  const DiscoveryEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 200.h,
              child: AssetsService.to.notFoundComposition.value != null
                  ? Lottie(
                      composition: AssetsService.to.notFoundComposition.value!,
                      fit: BoxFit.contain,
                      repeat: true,
                    )
                  : Lottie.asset(
                      'assets/animations/404_not_found.json',
                      fit: BoxFit.contain,
                      repeat: true,
                    ),
            ),
            SizedBox(height: 8.h),
            Text(
              'discovery_prompt_title'.tr,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'discovery_prompt_subtitle'.tr,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppTheme.subTextColor,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class DiscoveryNoViolationsState extends StatelessWidget {
  const DiscoveryNoViolationsState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100.w,
              height: 100.w,
              decoration: const BoxDecoration(
                color: AppTheme.successBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                IconlyBold.shield_done,
                size: 52.r,
                color: AppTheme.successColor,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'discovery_no_violations_title'.tr,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'discovery_no_violations_subtitle'.tr,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppTheme.subTextColor,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class DiscoveryErrorState extends StatelessWidget {
  const DiscoveryErrorState({required this.message, super.key});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100.w,
              height: 100.w,
              decoration: const BoxDecoration(
                color: AppTheme.errorBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                IconlyLight.danger,
                size: 52.r,
                color: AppTheme.errorColor,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'discovery_error_title'.tr,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppTheme.subTextColor,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            PrimaryButton(
              text: 'discovery_retry'.tr,
              width: 160.w,
              height: 48.h,
              onPressed: () => Get.find<DiscoveryController>().searchFines(),
            ),
          ],
        ),
      ),
    );
  }
}
