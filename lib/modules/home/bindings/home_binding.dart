import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../map/controllers/map_controller.dart';
import '../../discovery/controllers/discovery_controller.dart';
import '../../chatbot/controllers/chatbot_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<MapController>(() => MapController());
    // Get.lazyPut<CameraController>(() => CameraController());
    Get.lazyPut<DiscoveryController>(() => DiscoveryController());
    Get.lazyPut<ChatbotController>(() => ChatbotController());

    // ProfileController được đăng ký permanent để giữ dữ liệu khi navigate
    // API profile sẽ được gọi ngay khi vào Home/Dashboard
    Get.put<ProfileController>(ProfileController(), permanent: true);
  }
}
