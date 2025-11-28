import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';

class SocialButton extends StatelessWidget {
  final IconData? icon;
  final String? iconAssetPath;
  final Color? color;
  final Color? iconColor;
  final VoidCallback onPressed;

  const SocialButton({
    super.key,
    this.icon,
    this.iconAssetPath,
    this.color,
    this.iconColor = Colors.white,
    required this.onPressed,
  }) : assert(
         icon != null || iconAssetPath != null,
         'Either icon or iconAssetPath must be provided',
       );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88.w,
      height: 60.h,
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.dividerColor),
        borderRadius: BorderRadius.circular(16.r),
        color: Colors.white,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: iconAssetPath != null
            ? SvgPicture.asset(iconAssetPath!, width: 24.w, height: 24.h)
            : Icon(icon, color: color, size: 24.sp),
      ),
    );
  }
}
