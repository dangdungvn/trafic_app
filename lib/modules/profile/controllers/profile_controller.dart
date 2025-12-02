import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:traffic_app/data/repositories/auth_repository.dart';
import 'package:traffic_app/widgets/custom_dialog.dart';
import '../../../data/models/profile_request.dart';

class ProfileController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.onClose();
  }

  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true; // Bật xoay

      final user = await _authRepository.getProfile();

      nameController.text = user.fullName ?? ""; 
      emailController.text = user.email ?? "";
      phoneController.text = user.phoneNumber ?? "";  
      addressController.text = user.province ?? "";

    } catch (e) {
      CustomDialog.show(
        title: 'Lỗi',
        message: 'Không thể tải thông tin cá nhân: $e',
        type: DialogType.error,
      );
    } finally {
      isLoading.value = false; 
    }
  }

  Future<void> saveProfile() async {
    if (emailController.text.isEmpty ||
        phoneController.text.isEmpty || 
        addressController.text.isEmpty) { 
      CustomDialog.show(
        title: 'Thông báo',
        message: 'Họ tên không được để trống!',
        type: DialogType.warning,
      );
      return;
    }

    try {
      isLoading.value = true;

      final updatedUser = ProfileRequest(
        fullName: nameController.text.trim(),
        email: emailController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        province: addressController.text.trim(),
        // Có thể thêm avatarUrl nếu sau này làm chức năng up ảnh
      );

      await _authRepository.updateProfile(updatedUser);

      CustomDialog.show(
        title: 'Thành công',
        message: 'Cập nhật thông tin thành công',
        type: DialogType.success,
      );

      
      loadUserProfile(); 

    } catch (e) {
      CustomDialog.show(
        title: 'Lỗi',
        message: 'Cập nhật thông tin thất bại: $e',
        type: DialogType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }
}