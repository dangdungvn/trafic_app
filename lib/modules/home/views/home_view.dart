import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

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
                      : 'assets/icons/home_bottom_navbar.svg',
                  selectedIcon: PlatformInfo.isIOS26OrHigher()
                      ? "house.fill"
                      : 'assets/icons/home_bottom_navbar.svg',
                  label: 'home_bottom_navbar'.tr,
                ),
                AdaptiveNavigationDestination(
                  icon: PlatformInfo.isIOS26OrHigher()
                      ? "location"
                      : 'assets/icons/location_bottom_navbar.svg',
                  selectedIcon: PlatformInfo.isIOS26OrHigher()
                      ? "location.fill"
                      : 'assets/icons/location_bottom_navbar.svg',
                  label: 'map_bottom_navbar'.tr,
                ),
                AdaptiveNavigationDestination(
                  icon: PlatformInfo.isIOS26OrHigher()
                      ? "camera"
                      : 'assets/icons/camera_bottom_navbar.svg',
                  selectedIcon: PlatformInfo.isIOS26OrHigher()
                      ? "camera.fill"
                      : 'assets/icons/camera_bottom_navbar.svg',
                  label: '',
                ),
                AdaptiveNavigationDestination(
                  icon: PlatformInfo.isIOS26OrHigher()
                      ? "magnifyingglass"
                      : 'assets/icons/discovery_bottom_navbar.svg',
                  selectedIcon: PlatformInfo.isIOS26OrHigher()
                      ? "magnifyingglass"
                      : 'assets/icons/discovery_bottom_navbar.svg',
                  label: 'discovery_bottom_navbar'.tr,
                ),
                AdaptiveNavigationDestination(
                  icon: PlatformInfo.isIOS26OrHigher()
                      ? "bubble.left.and.bubble.right"
                      : 'assets/icons/chatbot_bottom_navbar.svg',
                  selectedIcon: PlatformInfo.isIOS26OrHigher()
                      ? "bubble.left.and.bubble.right.fill"
                      : 'assets/icons/chatbot_bottom_navbar.svg',
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
