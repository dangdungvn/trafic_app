import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:traffic_app/routes/app_pages.dart';

class SignupController extends GetxController {
  var rememberMe = false.obs;

  // Provinces data
  var provinces = <Map<String, dynamic>>[].obs;
  var selectedProvince = Rxn<Map<String, dynamic>>();

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
    emailFocusNode.dispose();
    nameFocusNode.dispose();
    passwordFocusNode.dispose();
    phoneFocusNode.dispose();
    // addressFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    super.onClose();
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
      print('Error loading provinces: $e');
    }
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  void goToLogin() {
    Get.offNamed(Routes.LOGIN);
  }
}
