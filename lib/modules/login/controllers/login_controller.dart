import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  var rememberMe = false.obs;

  final usernameFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  @override
  void onClose() {
    usernameFocusNode.dispose();
    passwordFocusNode.dispose();
    super.onClose();
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  void login() {
    // TODO: Implement actual login logic here
    Get.offAllNamed(Routes.HOME);
  }
}
