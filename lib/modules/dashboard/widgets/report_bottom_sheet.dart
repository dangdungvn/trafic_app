import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../theme/app_theme.dart';
import '../../../widgets/app_button.dart';

class ReportBottomSheet extends StatefulWidget {
  final Future<void> Function(String) onReport;

  const ReportBottomSheet({super.key, required this.onReport});

  @override
  State<ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends State<ReportBottomSheet> {
  String _selectedReason = "";
  bool _isLoading = false;
  final List<String> _reasons = [
    "Tin giả",
    "Ảnh/video không phù hợp",
    "Ngôn từ xúc phạm",
    "Khác (nhập chi tiết)",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40.r),
          topRight: Radius.circular(40.r),
        ),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 48.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 38.w,
            height: 3.h,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(100.r),
            ),
          ),
          SizedBox(height: 24.h),
          // Title
          Text(
            "Báo cáo",
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF212121),
              height: 1.2,
            ),
          ),
          SizedBox(height: 12.h),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          SizedBox(height: 20.h),
          // Reasons List
          ..._reasons.map((reason) => _buildReasonItem(reason)),
          SizedBox(height: 12.h),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          SizedBox(height: 20.h),
          // Buttons
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: "Hủy",
                  onPressed: () => Get.back(),
                  type: ButtonType.secondary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: AppButton(
                  text: "Gửi",
                  isLoading: _isLoading,
                  onPressed: () async {
                    if (_selectedReason.isNotEmpty) {
                      setState(() {
                        _isLoading = true;
                      });
                      await widget.onReport(_selectedReason);
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }
                  },
                  type: _isLoading ? ButtonType.secondary : ButtonType.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReasonItem(String reason) {
    final isSelected = _selectedReason == reason;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedReason = reason;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13.r),
          border: isSelected
              ? Border.all(color: AppTheme.primaryColor, width: 1)
              : Border.all(color: Colors.white, width: 1),
          boxShadow: isSelected
              ? null
              : [
                  BoxShadow(
                    color: const Color(0xFF04060F).withOpacity(0.05),
                    offset: const Offset(0, 4),
                    blurRadius: 60,
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : const Color(0xFFE0E0E0),
                  width: isSelected ? 6 : 2,
                ),
              ),
            ),
            SizedBox(width: 24.w),
            Text(
              reason,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF616161),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
