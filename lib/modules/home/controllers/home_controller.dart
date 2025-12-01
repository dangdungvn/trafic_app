import 'package:get/get.dart';
import 'package:traffic_app/routes/app_pages.dart';

class HomeController extends GetxController {
  // Bottom Navigation State
  var currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }

  void goToEditProfile() {
    Get.toNamed(Routes.PROFILE);
  }
}
