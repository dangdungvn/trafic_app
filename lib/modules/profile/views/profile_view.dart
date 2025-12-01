import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../theme/app_theme.dart'; // Import theme
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/primary_button.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor, 
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.textColor), 
            onPressed: () => Get.back(),
          ),
          title: Text(
            "Quản lý tài khoản",
            style: TextStyle(
              color: AppTheme.textColor, 
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            children: [
              // 1. Avatar + Icon Edit
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 100.w,
                      height: 100.w,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage("https://i.pravatar.cc/300"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor, 
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.white, width: 2), 
                        ),
                        child: Icon(Icons.edit, color: Colors.white, size: 14.sp),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.h),

              // 2. Các ô nhập liệu
              CustomTextField(
                controller: controller.nameController,
                hintText: "Họ và tên",
                prefixIcon: Icons.person_outline,
                keyboardType: TextInputType.name,
              ),
              SizedBox(height: 16.h),

              CustomTextField(
                controller: controller.emailController,
                hintText: "Email",
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16.h),

              CustomTextField(
                controller: controller.phoneController,
                hintText: "Số điện thoại",
                prefixIcon: Icons.phone_android,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16.h),

              // Tỉnh thành (Dùng AbsorbPointer + GestureDetector)
              GestureDetector(
                onTap: () {
                  // Xử lý chọn tỉnh
                  print("Chọn tỉnh");
                },
                child: AbsorbPointer(
                  child: CustomTextField(
                    controller: controller.addressController,
                    hintText: "Tỉnh/thành phố sinh sống",
                    prefixIcon: Icons.location_on_outlined,
                  ),
                ),
              ),
              
              SizedBox(height: 24.h),

              // 3. Thẻ "Lái xe an toàn"
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: AppTheme.dividerColor), 
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50.w,
                      height: 50.w,
                      decoration: BoxDecoration(
                        color: AppTheme.inputFillColor, 
                        shape: BoxShape.circle, 
                      ),
                      child: const Icon(Icons.stars, color: Colors.amber, size: 30),
                    ),
                    SizedBox(width: 16.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Lái xe an toàn",
                          style: TextStyle(
                            fontSize: 16.sp, 
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textColor, 
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "Điểm số: 1500",
                          style: TextStyle(
                            fontSize: 14.sp, 
                            color: AppTheme.subTextColor, 
                            fontWeight: FontWeight.w600
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              SizedBox(height: 40.h),

              // 4. Nút Lưu
              Obx(() => PrimaryButton(
                text: controller.isLoading.value ? 'Đang lưu...' : 'Lưu thay đổi',
                onPressed: controller.isLoading.value 
                    ? () {} 
                    : controller.saveProfile,
              )),
              
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}