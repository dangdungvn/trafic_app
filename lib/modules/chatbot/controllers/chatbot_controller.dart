import 'package:get/get.dart';

import '../../../data/services/sos_stream_service.dart';

class ChatbotController extends GetxController {
  // Delegate mọi stream state về SosStreamService
  SosStreamService get sosService => SosStreamService.to;
}
