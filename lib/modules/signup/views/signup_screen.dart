import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:traffic_app/modules/signup/controllers/signup_controller.dart';
import 'package:traffic_app/theme/app_theme.dart';
import 'package:traffic_app/widgets/custom_text_field.dart';
import 'package:traffic_app/widgets/primary_button.dart';
import 'package:traffic_app/widgets/social_button.dart';
import 'package:traffic_app/widgets/custom_dropdown.dart';

class SignupScreen extends GetView<SignupController> {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,

      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  SizedBox(height: 40.h),
                  // Title
                  Text(
                    'Đăng ký tài khoản',
                    style: GoogleFonts.urbanist(
                      fontSize: 44.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textColor,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: 40.h),

                  // Full Name
                  CustomTextField(
                    hintText: 'Họ và tên',
                    prefixIcon: FontAwesomeIcons.userPen,
                    focusNode: controller.nameFocusNode,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: 16.h),

                  // Email
                  CustomTextField(
                    hintText: 'Email',
                    prefixIcon: FontAwesomeIcons.solidEnvelope,
                    focusNode: controller.emailFocusNode,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: 16.h),

                  // Phone
                  CustomTextField(
                    hintText: 'Số điện thoại',
                    prefixIcon: FontAwesomeIcons.phone,
                    focusNode: controller.phoneFocusNode,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: 16.h),

                  // Province Dropdown
                  Obx(
                    () => CustomDropdown<Map<String, dynamic>>(
                      hintText: 'Tỉnh/Thành phố',
                      prefixIcon: FontAwesomeIcons.mapLocationDot,
                      value: controller.selectedProvince.value,
                      items: controller.provinces,
                      itemLabel: (item) => item['name'],
                      onChanged: (value) {
                        controller.selectedProvince.value = value;
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Address
                  CustomTextField(
                    hintText: 'Địa chỉ cụ thể',
                    prefixIcon: FontAwesomeIcons.locationDot,
                    focusNode: controller.addressFocusNode,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: 16.h),

                  // Password
                  CustomTextField(
                    hintText: 'Mật khẩu',
                    prefixIcon: FontAwesomeIcons.lock,
                    isPassword: true,
                    focusNode: controller.passwordFocusNode,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: 16.h),

                  // Confirm Password
                  CustomTextField(
                    hintText: 'Nhập lại mật khẩu',
                    prefixIcon: FontAwesomeIcons.lock,
                    isPassword: true,
                    focusNode: controller.confirmPasswordFocusNode,
                    textInputAction: TextInputAction.done,
                  ),
                  SizedBox(height: 20.h),

                  // Remember Me
                  Row(
                    mainAxisAlignment: .center,
                    children: [
                      Obx(
                        () => Checkbox(
                          value: controller.rememberMe.value,
                          onChanged: controller.toggleRememberMe,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          activeColor: AppTheme.primaryColor,
                          side: const BorderSide(
                            color: AppTheme.primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                      Text(
                        'Ghi nhớ mật khẩu',
                        style: GoogleFonts.urbanist(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Signup Button
                  PrimaryButton(
                    text: 'Đăng ký',
                    onPressed: () {
                      // Handle signup
                    },
                  ),
                  SizedBox(height: 20.h),

                  // Divider
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(
                          color: AppTheme.dividerColor,
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: .symmetric(horizontal: 16.w),
                        child: Text(
                          'Hoặc đăng ký với',
                          style: GoogleFonts.urbanist(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF616161),
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(
                          color: AppTheme.dividerColor,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30.h),

                  // Social Buttons
                  Row(
                    mainAxisAlignment: .center,
                    children: [
                      SocialButton(
                        icon: FontAwesomeIcons.facebookF,
                        color: const Color(0xFF1877F2),
                        onPressed: () {},
                      ),
                      SizedBox(width: 20.w),
                      SocialButton(
                        iconAssetPath: 'assets/icons/google.svg',
                        color: Colors.white,
                        onPressed: () {},
                      ),
                      SizedBox(width: 20.w),
                      SocialButton(
                        icon: FontAwesomeIcons.apple,
                        color: Colors.black,
                        onPressed: () {},
                      ),
                    ],
                  ),
                  SizedBox(height: 40.h),

                  // Login Link
                  Row(
                    mainAxisAlignment: .center,
                    children: [
                      Text(
                        'Đã có tài khoản? ',
                        style: GoogleFonts.urbanist(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.subTextColor,
                        ),
                      ),
                      GestureDetector(
                        onTap: controller.goToLogin,
                        child: Text(
                          'Đăng nhập',
                          style: GoogleFonts.urbanist(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
