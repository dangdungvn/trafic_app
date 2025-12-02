import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:traffic_app/widgets/custom_dialog.dart';
import '../../../data/models/profile_request.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/repositories/user_repository.dart';
import 'dart:io';

class ProfileController extends GetxController {
  final UserRepository _userRepository = UserRepository();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  var isLoading = false.obs;

  var selectedImagePath = ''.obs; 
  var currentAvatarUrl = ''.obs;

  final ImagePicker _picker = ImagePicker();

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
      isLoading.value = true; 

      final user = await _userRepository.getProfile();

      nameController.text = user.fullName ?? ""; 
      emailController.text = user.email ?? "";
      phoneController.text = user.phoneNumber ?? "";  
      addressController.text = user.province ?? "";

      if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
        currentAvatarUrl.value = "${user.avatarUrl}?t=${DateTime.now().millisecondsSinceEpoch}";
      } else {
        currentAvatarUrl.value = "";
      }

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
    if (emailController.text.isEmpty) { 
      CustomDialog.show(
        title: 'Thông báo',
        message: 'Không được để trống email!',
        type: DialogType.warning,
      );
      return;
    }

    if (nameController.text.isEmpty) { 
      CustomDialog.show(
        title: 'Thông báo',
        message: 'Không được để trống tên!',
        type: DialogType.warning,
      );
      return;
    }

    if (addressController.text.isEmpty) { 
      CustomDialog.show(
        title: 'Thông báo',
        message: 'Không được để trống địa chỉ!',
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
      );

      File? imageFile;
      if (selectedImagePath.value.isNotEmpty) {
        imageFile = File(selectedImagePath.value);
      }

      await _userRepository.updateProfile(updatedUser, imageFile);

      CustomDialog.show(
        title: 'Thành công',
        message: 'Cập nhật thông tin thành công',
        type: DialogType.success,
      );

      selectedImagePath.value = '';

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

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, 
      );      
      if (image != null) {
        selectedImagePath.value = image.path;
      }
    } catch (e) {
      CustomDialog.show(
        title: 'Lỗi',
        message: 'Không thể chọn ảnh: $e',
        type: DialogType.error,
      );
    }
  }
}