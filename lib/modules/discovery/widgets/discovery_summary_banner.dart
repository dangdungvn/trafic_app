import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../data/models/fine_record_model.dart';
import '../../../../theme/app_theme.dart';

class DiscoverySummaryBanner extends StatelessWidget {
  const DiscoverySummaryBanner({required this.info, super.key});
  final FineDataInfo info;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppTheme.warningBgColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.warningColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.summarize_rounded,
            color: AppTheme.warningColor,
            size: 20.r,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'discovery_summary'.trParams({
                'total': '${info.total}',
                'pending': '${info.chuaXuPhat}',
                'resolved': '${info.daXuPhat}',
              }),
              style: TextStyle(
                fontSize: 13.sp,
                color: AppTheme.warningAlertTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (info.latest.isNotEmpty) ...[
            SizedBox(width: 8.w),
            Text(
              info.latest,
              style: TextStyle(fontSize: 11.sp, color: AppTheme.subTextColor),
            ),
          ],
        ],
      ),
    );
  }
}
