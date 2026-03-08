import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';

import '../../../theme/app_theme.dart';
import '../../../widgets/custom_text_field.dart';
import '../controllers/dashboard_controller.dart';

class DashboardSearchBar extends StatefulWidget {
  final TextEditingController controller;

  const DashboardSearchBar({super.key, required this.controller});

  @override
  State<DashboardSearchBar> createState() => _DashboardSearchBarState();
}

class _DashboardSearchBarState extends State<DashboardSearchBar> {
  final _hasText = false.obs;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _hasText.value = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_onTextChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChange() {
    _hasText.value = widget.controller.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final dashboardController = Get.find<DashboardController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(
          () => CustomTextField(
            hintText: 'dashboard_search_hint'.tr,
            prefixIcon: IconlyBroken.search,
            controller: widget.controller,
            focusNode: _focusNode,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _focusNode.unfocus(),
            isLoading:
                dashboardController.isSearching.value &&
                dashboardController.isLoading.value,
            showClearButton: _hasText.value,
            onClear: () {
              dashboardController.clearSearch();
              _focusNode.unfocus();
            },
            trailingIconAsset: 'assets/icons/voice.svg',
          ),
        ),
        // Label từ khóa đang tìm
        Obx(() {
          final keyword = dashboardController.currentKeyword.value;
          if (keyword.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 14.w,
                  color: AppTheme.primaryColor,
                ),
                SizedBox(width: 4.w),
                Text(
                  '${'dashboard_searching_for'.tr} "$keyword"',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
