import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../services/storage_service.dart';
import '../../../widgets/custom_alert.dart';

class EmergencyController extends GetxController {
  var selectedOption = 0.obs;

  void selectOption(int index) {
    selectedOption.value = index;
  }

  Future<void> onContinue() async {
    if (selectedOption.value == 0) {
      final String relativePhone = (StorageService.to.getRelativePhone() ?? '').trim();

      if (relativePhone.isEmpty) {
        CustomAlert.showWarning('emergency_notification_mesg_1'.tr);
          await _makePhoneCall(''); 
      } else {
        await _makePhoneCall(relativePhone);
      }
    } else {
      // 2. GỌI CỨU THƯƠNG (Mặc định là 115)
      await _makePhoneCall('115');
    }
  }

  // Hàm xử lý gọi điện dùng chung
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    try {
      if (await canLaunchUrl(launchUri)) {
        // mode: LaunchMode.externalApplication giúp ép HĐH mở app Điện thoại 
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      } else {
        CustomAlert.showError('emergency_notification_mesg_2'.tr);
      }
    } catch (e) {
      CustomAlert.showError('emergency_notification_mesg_3'.tr);
    }
  }
}