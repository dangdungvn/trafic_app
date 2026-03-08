import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:traffic_app/theme/app_theme.dart';

import '../../../widgets/liquid_glass_bottom_bar.dart';
import '../../../widgets/location_permission_banner.dart';
import '../../../widgets/upload_progress_overlay.dart';
import '../../camera/views/camera_view.dart';
import '../../chatbot/views/chatbot_view.dart';
import '../../dashboard/views/dashboard_view.dart';
import '../../discovery/views/discovery_view.dart';
import '../../map/views/map_view.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        extendBody: true,
        backgroundColor: AppTheme.backgroundColor,
        body: Stack(
          children: [
            IndexedStack(
              index: controller.currentIndex.value,
              children: const [
                DashboardView(),
                MapView(),
                CameraView(),
                DiscoveryView(),
                ChatbotView(),
              ],
            ),
            // Liquid Glass Bottom Bar
            SafeArea(
              bottom: false,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: LiquidGlassBottomBar(
                  selectedIndex: controller.currentIndex.value,
                  onTabSelected: controller.changeTab,
                  tabs: [
                    LiquidGlassBottomBarTab(
                      label: 'home_bottom_navbar'.tr,
                      icon: IconlyLight.home,
                      selectedIcon: IconlyBold.home,
                    ),
                    LiquidGlassBottomBarTab(
                      label: 'map_bottom_navbar'.tr,
                      icon: IconlyLight.location,
                      selectedIcon: IconlyBold.location,
                    ),
                    LiquidGlassBottomBarTab(
                      label: 'camera_bottom_navbar'.tr,
                      icon: IconlyLight.camera,
                      selectedIcon: IconlyBold.camera,
                    ),
                    LiquidGlassBottomBarTab(
                      label: 'discovery_bottom_navbar'.tr,
                      icon: IconlyLight.search,
                      selectedIcon: IconlyBold.search,
                    ),
                    LiquidGlassBottomBarTab(
                      label: 'chatbot_bottom_navbar'.tr,
                      icon: IconlyLight.chat,
                      selectedIcon: IconlyBold.chat,
                    ),
                  ],
                ),
              ),
            ),
            // Upload Progress Overlay
            if (controller.isUploading.value)
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 0,
                right: 0,
                child: UploadProgressOverlay(
                  progress: controller.uploadProgress.value,
                  label: controller.uploadLabel.value,
                  onCancel: controller.cancelUpload,
                ),
              ),
            // Location Permission / Service Banner
            if (!controller.locationBannerDismissed.value &&
                !controller.isUploading.value &&
                (controller.isLocationPermissionDenied.value ||
                    controller.isLocationServiceDisabled.value))
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 0,
                right: 0,
                child: LocationPermissionBanner(
                  isServiceDisabled: controller.isLocationServiceDisabled.value,
                  onAction: controller.requestLocationPermission,
                  onDismiss: controller.dismissLocationBanner,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
