import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/login_request.dart';
import '../../../services/storage_service.dart';
import '../../../widgets/custom_dialog.dart';

class LoginController extends GetxController {
  var rememberMe = false.obs;
  var isLoading = false.obs;
  var isPasswordHidden = true.obs;

  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final StorageService _storageService = Get.find<StorageService>();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final usernameFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  @override
  void onClose() {
    super.onClose();
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> login() async {
    Get.focusScope?.unfocus();

    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      CustomDialog.show(
        title: 'Thông báo',
        message: 'Vui lòng điền đầy đủ thông tin đăng nhập',
        type: DialogType.warning,
      );
      return;
    }

    // Bắt đầu loading
    isLoading.value = true;

    try {
      await _authRepository.login(
        LoginRequest(
          username: usernameController.text.trim(),
          password: passwordController.text,
        ),
      );

      // --- XỬ LÝ THÀNH CÔNG ---
      if (rememberMe.value) {
        await _storageService.saveCredentials(
          usernameController.text.trim(),
          passwordController.text,
        );
      } else {
        await _storageService.clearCredentials();
      }

      isLoading.value = false;

      // Chuyển trang
      Get.offAllNamed(Routes.HOME);

    } catch (e) {
      isLoading.value = false;

      String errorMsg = e.toString().replaceAll("Exception:", "").trim();

      CustomDialog.show(
        title: 'Đăng nhập thất bại',
        message: errorMsg,
        type: DialogType.error,
      );
    } 
  }
}