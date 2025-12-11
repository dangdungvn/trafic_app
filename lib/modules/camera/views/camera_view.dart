import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:traffic_app/theme/app_theme.dart'; // Import file theme
import '../controllers/camera_controller.dart';

class CameraView extends GetView<CameraController> {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context) {
    
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor, // Tái sử dụng
        appBar: _buildAppBar(),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: 10.h),
                    Obx(() => controller.selectedImage.value == null
                        ? _buildPlaceholder()
                        : _buildSelectedContent()),
                  ],
                ),
              ),
            ),
            _buildHomeButton(),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        "Đăng bài".tr,
        style: TextStyle(
          color: AppTheme.textColor, // Tái sử dụng
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      children: [
        GestureDetector(
          onTap: controller.pickImage,
          child: Container(
            height: 400.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.inputFillColor, 
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: AppTheme.dividerColor), 
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_outlined, size: 60.sp, color: AppTheme.subTextColor), // Tái sử dụng
                SizedBox(height: 10.h),
                Text("Bấm để chọn ảnh", style: TextStyle(color: AppTheme.subTextColor)), // Tái sử dụng
              ],
            ),
          ),
        ),
        SizedBox(height: 40.h),
        _buildCircleButton(
          icon: Icons.camera_alt,
          color: AppTheme.primaryColor, 
          onTap: controller.pickImage,
          heroTag: 'camera_hero_tag',
        ),
      ],
    );
  }

  Widget _buildSelectedContent() {
    return Column(
      children: [
        // 1. Ảnh hiển thị
        Container(
          height: 380.h,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            image: DecorationImage(
              image: FileImage(controller.selectedImage.value!),
              fit: BoxFit.cover,
            ),
          ),
        ),

        SizedBox(height: 20.h),

        // 2. Cụm nút bấm
        SizedBox(
          height: 80.h,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Obx(() => _buildCircleButton(
                    icon: Icons.send_rounded,
                    color: AppTheme.primaryColor, 
                    isLoading: controller.isLoading.value,
                    onTap: controller.submit,
                    size: 70.w,
                  )),
              Positioned(
                right: 0,
                child: GestureDetector(
                  onTap: controller.removeImage,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    color: Colors.transparent,
                    child: Icon(Icons.close, size: 32.sp, color: AppTheme.textColor), 
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 20.h),

        // 3. Khung nhập liệu
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.04), 
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller.contentController,
            maxLines: 4,
            style: TextStyle(fontSize: 14.sp, color: AppTheme.textColor), // Tái sử dụng
            decoration: InputDecoration.collapsed(
              hintText: "Nhập nội dung bài viết...",
              hintStyle: TextStyle(color: AppTheme.subTextColor), // Tái sử dụng
            ),
          ),
        ),

        SizedBox(height: 20.h),

        // 4. Metadata
        Obx(() => _buildMetadataRow(
              Icons.access_time_filled,
              "Thời gian: ${controller.currentTimestamp.value}",
            )),

        SizedBox(height: 8.h),

        Obx(() => _buildMetadataRow(
              Icons.location_on,
              "Địa điểm: ${controller.currentAddress.value}",
            )),

        SizedBox(height: 70.h),
      ],
    );
  }

  Widget _buildMetadataRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: AppTheme.subTextColor), // Tái sử dụng
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: AppTheme.subTextColor, fontSize: 13.sp), // Tái sử dụng
          ),
        ),
      ],
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isLoading = false,
    double? size,
    String? heroTag,
  }) {
    final btnSize = size ?? 70.w;

    Widget buttonWidget = GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: btnSize,
        width: btnSize,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: isLoading
            ? Padding(
                padding: EdgeInsets.all(btnSize * 0.25),
                child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Icon(icon, color: Colors.white, size: btnSize * 0.45),
      ),
    );

    if (heroTag != null) {
      return Hero(
        tag: heroTag,
        child: Material( // Cần Material để icon không bị lỗi font khi đang bay
          color: Colors.transparent,
          child: buttonWidget,
        ),
      );
    } else {
      return buttonWidget;
    }
    
  }

  Widget _buildHomeButton() {
    return GestureDetector(
      onTap: () => Get.back(),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 24.w),
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.08), 
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Trang chủ",
              style: TextStyle(
                color: AppTheme.primaryColor, // Tái sử dụng
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor, size: 24.sp) // Tái sử dụng
          ],
        ),
      ),
    );
  }
}