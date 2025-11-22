import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  var rememberMe = false.obs;

  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  @override
  void onClose() {
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.onClose();
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }
}
