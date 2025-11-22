import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:traffic_app/modules/login/controllers/login_controller.dart';
import 'package:traffic_app/theme/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40.h),
                // Title
                Text(
                  'Đăng nhập',
                  style: GoogleFonts.urbanist(
                    fontSize: 48.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textColor,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 40.h),

                // Email Input
                _buildTextField(
                  label: 'Email',
                  icon: Icons.email_outlined,
                  hintText: 'Email',
                ),
                SizedBox(height: 24.h),

                // Password Input
                Obx(
                  () => _buildTextField(
                    label: 'Mật khẩu',
                    icon: Icons.lock_outline,
                    hintText: 'Mật khẩu',
                    isPassword: true,
                    isPasswordVisible: controller.isPasswordVisible.value,
                    onVisibilityToggle: controller.togglePasswordVisibility,
                  ),
                ),
                SizedBox(height: 24.h),

                // Remember Me
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                SizedBox(height: 24.h),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 58.h,
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle login
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                      elevation: 4,
                      shadowColor: AppTheme.primaryColor.withOpacity(0.25),
                    ),
                    child: Text(
                      'Đăng nhập',
                      style: GoogleFonts.urbanist(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // Forgot Password
                Center(
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'Quên mật khẩu?',
                      style: GoogleFonts.urbanist(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40.h),

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
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        'Hoặc đăng nhập với',
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton(
                      icon: FontAwesomeIcons.facebookF,
                      color: const Color(0xFF1877F2),
                      onPressed: () {},
                    ),
                    SizedBox(width: 20.w),
                    _buildSocialButton(
                      icon: FontAwesomeIcons.google,
                      color: Colors.white,
                      iconColor: Colors.black,
                      isGoogle: true,
                      onPressed: () {},
                    ),
                    SizedBox(width: 20.w),
                    _buildSocialButton(
                      icon: FontAwesomeIcons.apple,
                      color: Colors.black,
                      onPressed: () {},
                    ),
                  ],
                ),
                SizedBox(height: 40.h),

                // Sign Up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Đăng ký tài khoản mới? ',
                      style: GoogleFonts.urbanist(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.subTextColor,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Đăng ký',
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
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required String hintText,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onVisibilityToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.inputFillColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.subTextColor, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              obscureText: isPassword && !isPasswordVisible,
              style: GoogleFonts.urbanist(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: GoogleFonts.urbanist(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.subTextColor,
                ),
              ),
            ),
          ),
          if (isPassword)
            IconButton(
              icon: Icon(
                isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: AppTheme.subTextColor,
                size: 20.sp,
              ),
              onPressed: onVisibilityToggle,
            ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    Color iconColor = Colors.white,
    bool isGoogle = false,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 88.w,
      height: 60.h,
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.dividerColor),
        borderRadius: BorderRadius.circular(16.r),
        color: Colors.white,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: isGoogle
            ? SvgPicture.asset(
                'assets/icons/google.svg',
                width: 24.w,
                height: 24.h,
              )
            : Icon(icon, color: color, size: 24.sp),
      ),
    );
  }
}
