import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Logo placeholder
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(100.r),
          ),
          child: Icon(Icons.traffic, size: 20.sp, color: Colors.black54),
        ),
        const Spacer(),
        SvgPicture.asset(
          'assets/icons/notification.svg',
          width: 32.w,
          height: 32.w,
        ),
        SizedBox(width: 20.w),
        // Map marker
        SvgPicture.asset(
          'assets/icons/warning_appbar.svg',
          width: 40.w,
          height: 40.w,
        ),
        SizedBox(width: 20.w),
        // Avatar
        Container(
          width: 36.w,
          height: 36.w,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey,
            image: DecorationImage(
              image: NetworkImage("https://i.pravatar.cc/150?img=12"),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}
