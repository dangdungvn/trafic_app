import 'package:get/get.dart';
import 'package:traffic_app/routes/app_pages.dart';

class HomeController extends GetxController {
  // Bottom Navigation State
  var currentIndex = 0.obs;

  // Upload Progress State
  var isUploading = false.obs;
  var uploadProgress = 0.0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }

  void goToEditProfile() {
    Get.toNamed(Routes.PROFILE);
  }

  // Upload Progress Methods
  void startUpload() {
    isUploading.value = true;
    uploadProgress.value = 0.0;
  }

  void updateUploadProgress(double progress) {
    uploadProgress.value = progress;
  }

  void completeUpload() {
    uploadProgress.value = 1.0;
    // Delay để hiển thị 100% trước khi ẩn
    Future.delayed(const Duration(milliseconds: 500), () {
      isUploading.value = false;
      uploadProgress.value = 0.0;
    });
  }

  void cancelUpload() {
    isUploading.value = false;
    uploadProgress.value = 0.0;
  }
}
