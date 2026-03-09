import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../../../widgets/primary_button.dart';
import '../controllers/discovery_controller.dart';

class DiscoverySearchBar extends StatelessWidget {
  const DiscoverySearchBar({required this.controller, super.key});
  final DiscoveryController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF04060F).withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 50,
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: MediaQuery.of(context).padding.top + 10.h,
        bottom: 16.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                ),
                child: Icon(
                  IconlyBroken.shield_done,
                  color: AppTheme.primaryColor,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'traffic_fine_lookup'.tr,
                      style: TextStyle(
                        color: AppTheme.textColor,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'discovery_header_subtitle'.tr,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppTheme.subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  hintText: 'discovery_search_hint'.tr,
                  prefixIcon: IconlyBroken.search,
                  controller: controller.searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => controller.searchFines(),
                  height: 50.h,
                ),
              ),
              SizedBox(width: 10.w),
              Obx(
                () => PrimaryButton(
                  text: 'discovery_search_button'.tr,
                  width: 92.w,
                  height: 50.h,
                  isLoading: controller.isLoading.value,
                  onPressed: controller.searchFines,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
