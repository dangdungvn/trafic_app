import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

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
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        border: Border(
          bottom: BorderSide(color: AppTheme.dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomTextField(
              hintText: 'discovery_search_hint'.tr,
              prefixIcon: Icons.search_rounded,
              controller: controller.searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => controller.searchFines(),
              height: 46.h,
            ),
          ),
          SizedBox(width: 10.w),
          Obx(
            () => PrimaryButton(
              text: 'discovery_search_button'.tr,
              width: 88.w,
              height: 46.h,
              isLoading: controller.isLoading.value,
              onPressed: controller.searchFines,
            ),
          ),
        ],
      ),
    );
  }
}
