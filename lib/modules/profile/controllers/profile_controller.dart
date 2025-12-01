import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:traffic_app/widgets/custom_dialog.dart';

class ProfileController extends GetxController {
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

  void loadUserProfile(){
    nameController.text = "Nguyen Van A";
    emailController.text = "nguyenanhdung831@gmail.com";
    phoneController.text = "0123456789";  
    addressController.text = "Hà Nội";
  }

  Future<void> saveProfile() async {
    if (emailController.text.isEmpty || 
        phoneController.text.isEmpty || 
        addressController.text.isEmpty) {
      CustomDialog.show(
        title: 'Thông báo',
        message: 'Vui lòng nhập đầy đủ thông tin! ',
        type: DialogType.warning,
      );
      return;
    }

    try {
      isLoading.value = true;

      await Future.delayed(Duration(seconds: 1));

      CustomDialog.show(
        title: 'Thành công',
        message: 'Cập nhật thông tin thành công',
        type: DialogType.success,
      );

      Get.back();

    } catch (e) {
      CustomDialog.show(
        title: 'Lỗi',
        message: 'Cập nhật thông tin thất bại',
        type: DialogType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }
}