import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:traffic_app/theme/app_theme.dart';
import 'package:traffic_app/widgets/app_button.dart';
import 'package:traffic_app/widgets/custom_text_field.dart';

import '../controllers/camera_controller.dart';

class CameraView extends GetView<CameraController> {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 24.h),
                      _buildImageSection(),
                      _buildCaptureButton(),
                      if (kDebugMode) _buildGalleryPickerButton(),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: _buildInputSection(),
                      ),
                      SizedBox(height: 24.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: _buildInfoChips(),
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return GestureDetector(
      onTap: () {
        // Nếu chưa có ảnh, cho phép chọn từ thư viện khi tap vào preview
        if (!controller.hasImage.value) {
          controller.pickImageFromGallery();
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 24.w),
        height: 370.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(32.r),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32.r),
          child: Obx(() {
            if (controller.hasImage.value && controller.imageFile != null) {
              return Image.file(controller.imageFile!, fit: BoxFit.cover);
            } else {
              return Container(
                color: Colors.black,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, size: 64.sp, color: Colors.white54),
                    SizedBox(height: 12.h),
                    Text(
                      'camera_capture_or_pick'.tr,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }
          }),
        ),
      ),
    );
  }

  Widget _buildCaptureButton() {
    return Center(
      child: GestureDetector(
        onTap: controller.onActionTap,
        child: Obx(
          () => SvgPicture.asset(
            controller.hasImage.value
                ? 'assets/icons/big_send.svg'
                : 'assets/icons/big_camera.svg',
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryPickerButton() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: AppButton(
          text: 'camera_pick_from_gallery'.tr,
          onPressed: controller.pickImageFromGallery,
          type: ButtonType.secondary,
          icon: Icons.photo_library_rounded,
          iconSize: 20.sp,
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return CustomTextField(
      controller: controller.contentController,
      hintText: 'camera_content_placeholder'.tr,
      height: 108.h,
      maxLines: null,
      keyboardType: TextInputType.multiline,
    );
  }

  Widget _buildInfoChips() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChip(
            icon: Icons.access_time_filled_rounded,
            text: "${'camera_time_label'.tr} ${controller.time.value}",
          ),
          _buildChip(
            icon: Icons.location_on_rounded,
            text: "${'camera_location_label'.tr} ${controller.location.value}",
          ),
        ],
      ),
    );
  }

  Widget _buildChip({required IconData icon, required String text}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.subTextColor, size: 16.sp),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: AppTheme.subTextColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
