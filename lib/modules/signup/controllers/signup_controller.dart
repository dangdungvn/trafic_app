import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../data/models/signup_request.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/custom_dialog.dart';

class SignupController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  var rememberMe = false.obs;
  var isLoading = false.obs;

  // Provinces data
  var provinces = <Map<String, dynamic>>[].obs;
  var selectedProvince = Rxn<Map<String, dynamic>>();

  final usernameController = TextEditingController();
  final fullNameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final usernameFocusNode = FocusNode();
  final emailFocusNode = FocusNode();
  final nameFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final phoneFocusNode = FocusNode();
  // final addressFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();
    loadProvinces();
  }

  @override
  void onClose() {
    usernameController.dispose();
    fullNameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    usernameFocusNode.dispose();
    emailFocusNode.dispose();
    nameFocusNode.dispose();
    passwordFocusNode.dispose();
    phoneFocusNode.dispose();
    // addressFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    super.onClose();
  }

  Future<void> signup() async {
    if (usernameController.text.isEmpty ||
        fullNameController.text.isEmpty ||
        passwordController.text.isEmpty ||
        selectedProvince.value == null) {
      CustomDialog.show(
        title: 'Thông báo',
        message: 'Vui lòng điền đầy đủ thông tin',
        type: DialogType.warning,
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      CustomDialog.show(
        title: 'Thông báo',
        message: 'Mật khẩu không khớp',
        type: DialogType.warning,
      );
      return;
    }

    try {
      isLoading.value = true;
      final request = SignupRequest(
        userName: usernameController.text,
        fullName: fullNameController.text,
        password: passwordController.text,
        province: selectedProvince.value!['name'],
      );

      await _authRepository.signup(request);

      CustomDialog.show(
        title: 'Thành công',
        message: 'Đăng ký tài khoản thành công',
        type: DialogType.success,
        onPressed: () => Get.offNamed(Routes.LOGIN),
      );
    } catch (e) {
      CustomDialog.show(
        title: 'Lỗi',
        message: e.toString(),
        type: DialogType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadProvinces() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/json/provinces.json',
      );
      final List<dynamic> data = json.decode(response);
      final List<Map<String, dynamic>> mappedData = data
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      provinces.assignAll(mappedData);
    } catch (e) {
      debugPrint('Error loading provinces: $e');
    }
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  void goToLogin() {
    Get.offNamed(Routes.LOGIN);
  }
}
