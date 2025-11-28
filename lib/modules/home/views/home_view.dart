import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../controllers/home_controller.dart';
import '../../dashboard/views/dashboard_view.dart';
import '../../map/views/map_view.dart';
import '../../camera/views/camera_view.dart';
import '../../discovery/views/discovery_view.dart';
import '../../chatbot/views/chatbot_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: const [
            DashboardView(),
            MapView(),
            CameraView(),
            DiscoveryView(),
            ChatbotView(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return SizedBox(
      height: 100.h,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 80.h,
            padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(
                  0,
                  'assets/icons/home_bottom_navbar.svg',
                  'Trang chủ',
                ),
                _buildNavItem(
                  1,
                  'assets/icons/location_bottom_navbar.svg',
                  'Bản đồ',
                ),
                const SizedBox(width: 50), // Placeholder for center button
                _buildNavItem(
                  3,
                  'assets/icons/discovery_bottom_navbar.svg',
                  'Tra cứu',
                ),
                _buildNavItem(
                  4,
                  'assets/icons/chatbot_bottom_navbar.svg',
                  'Chatbot',
                ),
              ],
            ),
          ),
          Positioned(bottom: 0.h, child: _buildCenterButton()),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String iconPath, String label) {
    return Obx(() {
      final isSelected = controller.currentIndex.value == index;
      final color = isSelected
          ? const Color(0xFF4D5DFA)
          : const Color(0xFF9E9E9E);

      return GestureDetector(
        onTap: () => controller.changeTab(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 24.w,
              height: 24.h,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCenterButton() {
    return GestureDetector(
      onTap: () => controller.changeTab(2),
      child: SvgPicture.asset(
        'assets/icons/camera_bottom_navbar.svg',
        width: 120,
        height: 120,
      ),
    );
  }
}
