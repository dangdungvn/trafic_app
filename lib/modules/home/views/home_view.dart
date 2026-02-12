import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
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
                  icon: 'house',
                  label: 'home_bottom_navbar'.tr,
                  selectedIcon: 'house.fill',
                ),
                AdaptiveNavigationDestination(
                  icon: 'location',
                  label: 'map_bottom_navbar'.tr,
                  selectedIcon: 'location.fill',
                ),
                AdaptiveNavigationDestination(
                  icon: 'camera',
                  label: '',
                  selectedIcon: 'camera.fill',
                ),
                AdaptiveNavigationDestination(
                  icon: 'magnifyingglass',
                  label: 'discovery_bottom_navbar'.tr,
                  selectedIcon: 'magnifyingglass.fill',
                ),
                AdaptiveNavigationDestination(
                  icon: 'bubble.left.and.bubble.right',
                  label: 'chatbot_bottom_navbar'.tr,
                  selectedIcon: 'bubble.left.and.bubble.right.fill',
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
