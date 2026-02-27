import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../services/storage_service.dart';
import '../../../widgets/custom_alert.dart';

class EmergencyController extends GetxController {
  // 0: Gọi cho người thân, 1: Gọi cứu thương
  var selectedOption = 0.obs;

  void selectOption(int index) {
    selectedOption.value = index;
  }

  Future<void> onContinue() async {
    if (selectedOption.value == 0) {
      // 1. GỌI CHO NGƯỜI THÂN
      // Gọi trực tiếp hàm getRelativePhone() từ StorageService
      final String relativePhone = StorageService.to.getRelativePhone() ?? '';

      await _makePhoneCall(relativePhone);
    } else {
      // 2. GỌI CỨU THƯƠNG (Mặc định là 115)
      await _makePhoneCall('115');
    }
  }

  // Hàm xử lý gọi điện dùng chung
  Future<void> _makePhoneCall(String phoneNumber) async {
    // Tạo đường dẫn URL cho trình gọi điện (scheme: tel)
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    try {
      // Kiểm tra xem thiết bị có hỗ trợ mở trình gọi điện không
      if (await canLaunchUrl(launchUri)) {
        // mode: LaunchMode.externalApplication giúp ép HĐH mở app Điện thoại 
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      } else {
        CustomAlert.showError('Thiết bị của bạn không hỗ trợ tính năng gọi điện.');
      }
    } catch (e) {
      CustomAlert.showError('Không thể mở trình gọi điện: $e');
    }
  }
}