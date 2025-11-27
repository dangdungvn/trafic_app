import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:traffic_app/widgets/custom_dialog.dart';
import '../../../routes/app_pages.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/login_request.dart';
import '../../../services/storage_service.dart';

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
    usernameController.dispose();
    passwordController.dispose();
    usernameFocusNode.dispose();
    passwordFocusNode.dispose();
    super.onClose();
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> login() async {
    // Get.focusScope?.unfocus(); ẩn bàn phím

    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      CustomDialog.show(
        title: 'Thông báo',
        message: 'Vui lòng điền đầy đủ thông tin đăng nhập',
        type: DialogType.warning,
      );
      return;
    }

    isLoading.value = true;

    try {
      await _authRepository.login(
        LoginRequest(
          username: usernameController.text.trim(),
          password: passwordController.text,
        ),
      );

      // Save credentials for auto-login
      await _storageService.saveCredentials(
        usernameController.text.trim(),
        passwordController.text,
      );

      // Navigate to home page on successful login
      Get.offAllNamed(Routes.HOME);
    } catch (e) {
      CustomDialog.show(
        title: 'Đăng nhập thất bại',
        message: e.toString(),
        type: DialogType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
