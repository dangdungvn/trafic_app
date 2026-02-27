import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:traffic_app/widgets/custom_alert.dart';
import 'package:traffic_app/widgets/custom_dialog.dart';

import '../../../data/models/profile_request.dart';
import '../../../data/repositories/user_repository.dart';
import '../../home/controllers/home_controller.dart';
import '../../../services/storage_service.dart';

class ProfileController extends GetxController {
  final UserRepository _userRepository = UserRepository();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final relativePhoneController = TextEditingController();

  var isLoading = false.obs;

  var selectedImagePath = ''.obs;
  var currentAvatarUrl = ''.obs;

  // Provinces data
  var provinces = <Map<String, dynamic>>[].obs;
  var selectedProvince = Rxn<Map<String, dynamic>>();

  final ImagePicker _picker = ImagePicker();

  // Flag để kiểm tra dữ liệu đã được load chưa
  var isDataLoaded = false.obs;
  var isProvincesLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Load provinces và profile song song, không block UI
    _initData();
  }

  Future<void> _initData() async {
    // Load cả 2 song song để tối ưu thời gian
    await Future.wait([loadProvinces(), loadUserProfile()]);
  }

  Future<void> loadProvinces() async {
    if (isProvincesLoaded.value) return;

    try {
      final String response = await rootBundle.loadString(
        'assets/json/provinces.json',
      );
      final List<dynamic> data = json.decode(response);
      final List<Map<String, dynamic>> mappedData = data
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      provinces.assignAll(mappedData);
      isProvincesLoaded.value = true;
    } catch (e) {
      debugPrint('Error loading provinces: $e');
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    relativePhoneController.dispose();
    super.onClose();
  }

  /// Load thông tin người dùng từ API
  /// [forceRefresh] = true sẽ bắt buộc call API lại
  Future<void> loadUserProfile({bool forceRefresh = false}) async {
    // Nếu đã load dữ liệu và không yêu cầu refresh thì không call API nữa
    if (isDataLoaded.value && !forceRefresh) {
      return;
    }

    try {
      isLoading.value = true;

      final user = await _userRepository.getProfile();

      nameController.text = user.fullName ?? "";
      emailController.text = user.email ?? "";
      phoneController.text = user.phoneNumber ?? "";
      addressController.text = user.province ?? "";
      relativePhoneController.text = user.relativePhone ?? "";

      StorageService.to.saveUserInfo(
        fullName: user.fullName,
        province: user.province,
        relativePhone: user.relativePhone,
      );

      // Set selected province
      if (user.province != null && user.province!.isNotEmpty) {
        // Wait for provinces to load if empty
        if (!isProvincesLoaded.value) {
          await loadProvinces();
        }

        final province = provinces.firstWhere(
          (element) => element['name'] == user.province?.trim(),
          orElse: () => {},
        );

        if (province.isNotEmpty) {
          selectedProvince.value = province;
        }
      }

      if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
        currentAvatarUrl.value =
            "${user.avatarUrl}?t=${DateTime.now().millisecondsSinceEpoch}";
      } else {
        currentAvatarUrl.value = "";
      }

      // Đánh dấu đã load dữ liệu thành công
      isDataLoaded.value = true;
    } catch (e) {
      CustomDialog.show(
        title: 'profile_load_error_title'.tr,
        message: '${'profile_load_error_message'.tr}: $e',
        type: DialogType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveProfile() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (emailController.text.isEmpty) {
      CustomDialog.show(
        title: 'profile_notice_title'.tr,
        message: 'profile_email_empty'.tr,
        type: DialogType.warning,
      );
      return;
    }

    if (nameController.text.isEmpty) {
      CustomDialog.show(
        title: 'profile_notice_title'.tr,
        message: 'profile_name_empty'.tr,
        type: DialogType.warning,
      );
      return;
    }

    if (selectedProvince.value == null) {
      CustomDialog.show(
        title: 'profile_notice_title'.tr,
        message: 'profile_province_empty'.tr,
        type: DialogType.warning,
      );
      return;
    }
    try {
      final homeController = Get.find<HomeController>();
      homeController.startUpload(label: 'profile_upload_label'.tr);
      Get.back(); // Quay về home ngay lập tức, không đợi API

      final updatedUser = ProfileRequest(
        fullName: nameController.text.trim(),
        email: emailController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        province: selectedProvince.value!['name'],
        relativePhone: relativePhoneController.text.trim(),
      );
      File? imageFile;
      if (selectedImagePath.value.isNotEmpty) {
        imageFile = File(selectedImagePath.value);
      }

      await _userRepository.updateProfile(
        updatedUser,
        imageFile,
        onSendProgress: (sent, total) {
          if (total > 0) homeController.updateUploadProgress(sent / total);
        },
      );

      homeController.completeUpload();
      selectedImagePath.value = '';

      CustomAlert.showSuccess('profile_update_success'.tr);

      // Sau khi update profile, force refresh để lấy dữ liệu mới
      loadUserProfile(forceRefresh: true);
    } catch (e) {
      Get.find<HomeController>().cancelUpload();
      CustomAlert.showError('${'profile_update_error'.tr}: $e');
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxWidth: 800,
      );
      if (image != null) {
        selectedImagePath.value = image.path;
      }
    } catch (e) {
      CustomDialog.show(
        title: 'profile_load_error_title'.tr,
        message: '${'profile_pick_image_error'.tr}: $e',
        type: DialogType.error,
      );
    }
  }
}
