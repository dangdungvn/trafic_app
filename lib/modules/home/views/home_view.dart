import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';

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
      () => Stack(
        children: [
          AdaptiveScaffold(
            body: IndexedStack(
              index: controller.currentIndex.value,
              children: const [
                DashboardView(),
                MapView(),
                CameraView(),
                DiscoveryView(),
                ChatbotView(),
              ],
            ),
            bottomNavigationBar: AdaptiveBottomNavigationBar(
              selectedIndex: controller.currentIndex.value,
              onTap: (index) => controller.changeTab(index),
              items: [
                AdaptiveNavigationDestination(
                  icon: PlatformInfo.isIOS26OrHigher()
                      ? "house"
                      : IconlyLight.home,
                  selectedIcon: PlatformInfo.isIOS26OrHigher()
                      ? "house.fill"
                      : IconlyBold.home,
                  label: 'home_bottom_navbar'.tr,
                ),
                AdaptiveNavigationDestination(
                  icon: PlatformInfo.isIOS26OrHigher()
                      ? "location"
                      : IconlyLight.location,
                  selectedIcon: PlatformInfo.isIOS26OrHigher()
                      ? "location.fill"
                      : IconlyBold.location,
                  label: 'map_bottom_navbar'.tr,
                ),
                AdaptiveNavigationDestination(
                  icon: PlatformInfo.isIOS26OrHigher()
                      ? "camera"
                      : IconlyLight.camera,
                  selectedIcon: PlatformInfo.isIOS26OrHigher()
                      ? "camera.fill"
                      : IconlyBold.camera,
                  label: '',
                ),
                AdaptiveNavigationDestination(
                  icon: PlatformInfo.isIOS26OrHigher()
                      ? "magnifyingglass"
                      : IconlyLight.search,
                  selectedIcon: PlatformInfo.isIOS26OrHigher()
                      ? "magnifyingglass"
                      : IconlyBold.search,
                  label: 'discovery_bottom_navbar'.tr,
                ),
                AdaptiveNavigationDestination(
                  icon: PlatformInfo.isIOS26OrHigher()
                      ? "bubble.left.and.bubble.right"
                      : IconlyLight.chat,
                  selectedIcon: PlatformInfo.isIOS26OrHigher()
                      ? "bubble.left.and.bubble.right.fill"
                      : IconlyBold.chat,
                  label: 'chatbot_bottom_navbar'.tr,
                ),
              ],
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
                onCancel: controller.cancelUpload,
              ),
            ),
        ],
      ),
    );
  }
}
