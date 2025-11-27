import 'package:get/get.dart';

class HomeController extends GetxController {
  // Bottom Navigation State
  var currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }
}
