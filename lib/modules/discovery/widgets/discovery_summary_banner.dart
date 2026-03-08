import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';

import '../../../../data/models/fine_record_model.dart';
import '../../../../theme/app_theme.dart';

class DiscoverySummaryBanner extends StatelessWidget {
  const DiscoverySummaryBanner({required this.info, super.key});
  final FineDataInfo info;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 4.h),
      child: Row(
        children: [
          _StatChip(
            label: 'discovery_stat_total'.tr,
            value: '${info.total}',
            color: AppTheme.primaryColor,
            bgColor: AppTheme.primaryBgColor,
            icon: IconlyLight.paper,
          ),
          SizedBox(width: 8.w),
          _StatChip(
            label: 'discovery_stat_pending'.tr,
            value: '${info.chuaXuPhat}',
            color: AppTheme.errorColor,
            bgColor: AppTheme.errorBgColor,
            icon: IconlyLight.time_circle,
          ),
          SizedBox(width: 8.w),
          _StatChip(
            label: 'discovery_stat_resolved'.tr,
            value: '${info.daXuPhat}',
            color: AppTheme.successColor,
            bgColor: AppTheme.successBgColor,
            icon: IconlyBold.tick_square,
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final Color bgColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16.r, color: color),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: color,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: color.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
