import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerService extends GetxService {
  static ImagePickerService get to => Get.find();

  late final ImagePicker picker;

  Future<ImagePickerService> init() async {
    picker = ImagePicker();

    // Warm up the platform channel so the first real call is instant.
    // retrieveLostData() pings the native side without showing any UI.
    try {
      if (!kIsWeb) {
        await picker.retrieveLostData();
      }
    } catch (e) {
      // Non-fatal – ignore on platforms that don't support it.
      debugPrint('ImagePickerService warm-up: $e');
    }

    return this;
  }
}
