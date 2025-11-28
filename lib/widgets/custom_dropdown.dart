import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_theme.dart';

class CustomDropdown<T> extends StatelessWidget {
  final String hintText;
  final IconData? prefixIcon;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?>? onChanged;
  final FocusNode? focusNode;

  const CustomDropdown({
    super.key,
    required this.hintText,
    this.prefixIcon,
    required this.items,
    required this.itemLabel,
    this.value,
    this.onChanged,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return DropdownMenu<T>(
          width: constraints.maxWidth,
          initialSelection: value,
          hintText: hintText,
          requestFocusOnTap: true,
          enableFilter: true,
          focusNode: focusNode,
          leadingIcon: prefixIcon != null
              ? Icon(prefixIcon, color: AppTheme.subTextColor, size: 20.sp)
              : null,
          textStyle: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textColor,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppTheme.inputFillColor,
            hintStyle: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: AppTheme.subTextColor,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 16.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(
                color: AppTheme.primaryColor,
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
          ),
          menuHeight: 250.h,
          menuStyle: MenuStyle(
            backgroundColor: MaterialStateProperty.all(Colors.white),
            surfaceTintColor: MaterialStateProperty.all(Colors.white),
            elevation: MaterialStateProperty.all(4),
            shadowColor: MaterialStateProperty.all(
              Colors.black.withOpacity(0.1),
            ),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            ),
            padding: MaterialStateProperty.all(
              EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
            ),
          ),
          dropdownMenuEntries: items.map((item) {
            return DropdownMenuEntry<T>(
              value: item,
              label: itemLabel(item),
              style: ButtonStyle(
                textStyle: MaterialStateProperty.all(
                  TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textColor,
                  ),
                ),
                foregroundColor: MaterialStateProperty.all(AppTheme.textColor),
                overlayColor: MaterialStateProperty.all(
                  AppTheme.primaryColor.withOpacity(0.1),
                ),
                padding: MaterialStateProperty.all(
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                ),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            );
          }).toList(),
          onSelected: onChanged,
        );
      },
    );
  }
}
