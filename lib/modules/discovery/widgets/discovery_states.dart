import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/loading_widget.dart';

class DiscoveryLoadingState extends StatelessWidget {
  const DiscoveryLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const LoadingWidget(height: 80),
          SizedBox(height: 8.h),
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
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_rounded,
              size: 72.r,
              color: AppTheme.dividerColor,
            ),
            SizedBox(height: 16.h),
            Text(
              'discovery_prompt_title'.tr,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'discovery_prompt_subtitle'.tr,
              style: TextStyle(fontSize: 13.sp, color: AppTheme.subTextColor),
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
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: AppTheme.successBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline_rounded,
                size: 48.r,
                color: AppTheme.successColor,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'discovery_no_violations_title'.tr,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.successColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'discovery_no_violations_subtitle'.tr,
              style: TextStyle(fontSize: 13.sp, color: AppTheme.subTextColor),
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
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: AppTheme.errorBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 48.r,
                color: AppTheme.errorColor,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'discovery_error_title'.tr,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.errorColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: TextStyle(fontSize: 13.sp, color: AppTheme.subTextColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
