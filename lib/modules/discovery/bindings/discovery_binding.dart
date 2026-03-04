import 'package:get/get.dart';
import '../controllers/discovery_controller.dart';

class DiscoveryBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DiscoveryController(), permanent: true);  
  }
}
