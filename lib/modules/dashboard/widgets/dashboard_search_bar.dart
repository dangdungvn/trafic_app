import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../theme/app_theme.dart';

class DashboardSearchBar extends StatefulWidget {
  final TextEditingController controller;

  const DashboardSearchBar({super.key, required this.controller});

  @override
  State<DashboardSearchBar> createState() => _DashboardSearchBarState();
}

class _DashboardSearchBarState extends State<DashboardSearchBar> {
  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: _isFocused
            ? AppTheme.primaryColor.withOpacity(0.08)
            : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12.r),
        border: _isFocused
            ? Border.all(color: AppTheme.primaryColor, width: 1)
            : null,
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/search.svg',
            width: 20.w,
            height: 20.w,
            colorFilter: ColorFilter.mode(
              _isFocused ? AppTheme.primaryColor : AppTheme.subTextColor,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              cursorColor: AppTheme.primaryColor,
              decoration: InputDecoration(
                hintText: "Tìm kiếm bài đăng theo địa điểm ...".tr,
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: AppTheme.subTextColor,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.textColor,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SvgPicture.asset(
            'assets/icons/voice.svg',
            width: 20.w,
            height: 20.w,
            colorFilter: ColorFilter.mode(
              _isFocused ? AppTheme.primaryColor : AppTheme.subTextColor,
              BlendMode.srcIn,
            ),
          ),
        ],
      ),
    );
  }
}
