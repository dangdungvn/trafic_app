import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';

import '../../../../data/models/fine_record_model.dart';
import '../../../../theme/app_theme.dart';

class FineResultList extends StatelessWidget {
  const FineResultList({required this.records, super.key});
  final List<FineRecord> records;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        16.w,
        12.h,
        16.w,
        MediaQuery.of(context).viewPadding.bottom + 24.h,
      ),
      itemCount: records.length,
      itemBuilder: (_, index) => FineCard(record: records[index], index: index),
    );
  }
}

class FineCard extends StatelessWidget {
  const FineCard({required this.record, required this.index, super.key});
  final FineRecord record;
  final int index;

  /// Strip internal code prefix e.g. "12321.5.5.i.01.Điều khiển xe..."
  static String _cleanViolation(String raw) {
    // Match patterns like "CC.X.Y.z.NN." at the start
    final match = RegExp(r'^[\d.a-zA-Z]+\.\s*').firstMatch(raw);
    if (match != null && match.end < raw.length) {
      final afterCode = raw.substring(match.end).trimLeft();
      if (afterCode.isNotEmpty) return afterCode;
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final isPaid = record.isPaid;
    final accentColor = isPaid ? AppTheme.successColor : AppTheme.errorColor;
    final statusBgColor = isPaid
        ? AppTheme.successBgColor
        : AppTheme.errorBgColor;

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF04060F).withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 40,
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left accent border
            Container(
              width: 4.w,
              margin: EdgeInsets.symmetric(vertical: 20.h),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(36.r),
                  bottomLeft: Radius.circular(36.r),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${'discovery_violation'.tr} #${index + 1}',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: AppTheme.subTextColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                record.bienKiemSoat.isNotEmpty
                                    ? record.bienKiemSoat
                                    : '—',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              if (record.loaiPhuongTien.isNotEmpty)
                                Text(
                                  record.loaiPhuongTien,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: AppTheme.subTextColor,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
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
                              color: accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Divider(
                      height: 1,
                      thickness: 0.5,
                      color: AppTheme.dividerColor,
                    ),
                    SizedBox(height: 12.h),
                    // Detail rows
                    if (record.hanhViViPham.isNotEmpty)
                      _DetailRow(
                        icon: IconlyLight.document,
                        iconColor: AppTheme.warningColor,
                        label: 'discovery_field_violation'.tr,
                        value: _cleanViolation(record.hanhViViPham),
                      ),
                    if (record.thoiGianViPham.isNotEmpty)
                      _DetailRow(
                        icon: IconlyLight.time_circle,
                        iconColor: AppTheme.primaryColor,
                        label: 'discovery_field_time'.tr,
                        value: record.thoiGianViPham,
                      ),
                    if (record.diaDiemViPham.isNotEmpty)
                      _DetailRow(
                        icon: IconlyLight.location,
                        iconColor: AppTheme.errorColor,
                        label: 'discovery_field_location'.tr,
                        value: record.diaDiemViPham,
                      ),
                    if (record.donViPhatHien.isNotEmpty)
                      _DetailRow(
                        icon: IconlyLight.shield_done,
                        iconColor: AppTheme.subTextColor,
                        label: 'discovery_field_unit'.tr,
                        value: record.donViPhatHien,
                      ),
                    if (record.noiGiaiQuyet.isNotEmpty)
                      FineResolveSection(items: record.noiGiaiQuyet),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 15.r, color: iconColor),
          ),
          SizedBox(width: 10.w),
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
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FineResolveSection extends StatelessWidget {
  const FineResolveSection({required this.items, super.key});
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 2.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppTheme.primaryBgColor,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                IconlyBold.location,
                size: 14.r,
                color: AppTheme.primaryColor,
              ),
              SizedBox(width: 6.w),
              Text(
                'discovery_field_resolve_location'.tr,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ...items.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 4.h),
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
      ),
    );
  }
}
