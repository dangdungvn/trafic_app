import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../data/models/fine_record_model.dart';
import '../../../../theme/app_theme.dart';

class FineResultList extends StatelessWidget {
  const FineResultList({required this.records, super.key});
  final List<FineRecord> records;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 12.h,
      ).copyWith(bottom: MediaQuery.of(context).viewPadding.bottom + 46.h),
      itemCount: records.length,
      itemBuilder: (_, index) => FineCard(record: records[index], index: index),
    );
  }
}

class FineCard extends StatelessWidget {
  const FineCard({required this.record, required this.index, super.key});
  final FineRecord record;
  final int index;

  @override
  Widget build(BuildContext context) {
    final isPaid = record.isPaid;
    final statusColor = isPaid ? AppTheme.successColor : AppTheme.errorColor;
    final statusBgColor = isPaid
        ? AppTheme.successBgColor
        : AppTheme.errorBgColor;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppTheme.primaryBgColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.directions_car_rounded,
                  color: AppTheme.primaryColor,
                  size: 18.r,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    '${'discovery_violation'.tr} #${index + 1}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    record.trangThai.isEmpty
                        ? 'discovery_status_unknown'.tr
                        : record.trangThai,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Card body
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                if (record.hanhViViPham.isNotEmpty)
                  FineInfoRow(
                    icon: Icons.warning_amber_rounded,
                    iconColor: AppTheme.warningColor,
                    label: 'discovery_field_violation'.tr,
                    value: record.hanhViViPham,
                  ),
                if (record.thoiGianViPham.isNotEmpty)
                  FineInfoRow(
                    icon: Icons.access_time_rounded,
                    iconColor: AppTheme.primaryColor,
                    label: 'discovery_field_time'.tr,
                    value: record.thoiGianViPham,
                  ),
                if (record.diaDiemViPham.isNotEmpty)
                  FineInfoRow(
                    icon: Icons.location_on_rounded,
                    iconColor: AppTheme.errorColor,
                    label: 'discovery_field_location'.tr,
                    value: record.diaDiemViPham,
                  ),
                if (record.loaiPhuongTien.isNotEmpty)
                  FineInfoRow(
                    icon: Icons.two_wheeler_rounded,
                    iconColor: AppTheme.subTextColor,
                    label: 'discovery_field_vehicle_type'.tr,
                    value: record.loaiPhuongTien,
                  ),
                if (record.donViPhatHien.isNotEmpty)
                  FineInfoRow(
                    icon: Icons.local_police_rounded,
                    iconColor: AppTheme.subTextColor,
                    label: 'discovery_field_unit'.tr,
                    value: record.donViPhatHien,
                    isLast: record.noiGiaiQuyet.isEmpty,
                  ),
                if (record.noiGiaiQuyet.isNotEmpty)
                  FineResolveSection(items: record.noiGiaiQuyet),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FineInfoRow extends StatelessWidget {
  const FineInfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.isLast = false,
    super.key,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16.r, color: iconColor),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppTheme.subTextColor,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppTheme.textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast)
          Divider(height: 16.h, thickness: 0.5, color: AppTheme.dividerColor),
      ],
    );
  }
}

class FineResolveSection extends StatelessWidget {
  const FineResolveSection({required this.items, super.key});
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: 16.h, thickness: 0.5, color: AppTheme.dividerColor),
        Row(
          children: [
            Icon(Icons.place_rounded, size: 16.r, color: AppTheme.primaryColor),
            SizedBox(width: 8.w),
            Text(
              'discovery_field_resolve_location'.tr,
              style: TextStyle(fontSize: 11.sp, color: AppTheme.subTextColor),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        ...items.map(
          (item) => Padding(
            padding: EdgeInsets.only(bottom: 4.h, left: 24.w),
            child: Text(
              item,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppTheme.textColor,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
