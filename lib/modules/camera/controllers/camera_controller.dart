import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:traffic_app/widgets/custom_dialog.dart';
import '../../../data/models/post_request.dart';
import '../../../data/repositories/post_repository.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class CameraController extends GetxController {
  final contentController = TextEditingController(); 
  final locationController = TextEditingController();

  var selectedImage = Rxn<File>();
  final ImagePicker _picker = ImagePicker();

  final PostRepository _postRepository = PostRepository();  

  var isLoading = false.obs;

  Position? currentPosition;
  var currentTimestamp = ''.obs;
  var currentAddress = 'Đang định vị...'.obs;

  @override
  void onClose() {
    contentController.dispose();
    locationController.dispose();
    super.onClose();
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
        maxWidth: 1024,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
      }
    } catch (e) {
      CustomDialog.show(
        title: 'Lỗi',
        message: 'Không thể chọn ảnh: $e',
        type: DialogType.error,
      );
    }
  } 

  void removeImage() {
    selectedImage.value = null; 
    contentController.clear();
  }

  Future<void> submit() async {
    if (selectedImage.value == null) {
       CustomDialog.show(
        title: 'Thiếu ảnh',
        message: 'Vui lòng chọn một bức ảnh!',
        type: DialogType.warning,
      );
      return;
    }

    if (contentController.text.trim().isEmpty) {
      CustomDialog.show(
        title: 'Thiếu thông tin',
        message: 'Vui lòng nhập nội dung bài viết!',
        type: DialogType.warning,
      );
      return;
    }

    if (currentPosition == null) {
      CustomDialog.show(
        title: 'Chưa định vị',
        message: 'Không thể lấy vị trí hiện tại. Vui lòng thử lại sau.',
        type: DialogType.error,
      );
      return;
    }

    try {
      isLoading.value = true;
      
      final myLocation = PostLocation(
        lat: currentPosition!.latitude, 
        lng: currentPosition!.longitude, 
        address: currentAddress.value,
      );

      final postRequest = PostRequest(
        content: contentController.text.trim(),
        location: myLocation,
        type: "TRAFFIC_JAM",
      );

      await _postRepository.createPost(
        request: postRequest,
        imageFile: selectedImage.value!,
      );
      
      Get.back(); 
      CustomDialog.show(
        title: 'Thành công',
        message: 'Bài viết đã được đăng!',
        type: DialogType.success,
      );

      removeImage();
      contentController.clear();

    } catch (e) {
      CustomDialog.show(
        title: 'Lỗi',
        message: 'Đăng bài thất bại: $e',
        type: DialogType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Lấy vị trí hiện tại của người dùng

  @override
  void onInit() {
    super.onInit();
    updateTimestamp();
    _determinePosition();
  }

  void updateTimestamp() {
    final now = DateTime.now();
    currentTimestamp.value = now.toString().substring(0, 16);
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      currentAddress.value = 'Dịch vụ định vị bị tắt.';
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        currentAddress.value = 'Quyền định vị bị từ chối.';
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      currentAddress.value = 'Quyền định vị bị từ chối vĩnh viễn.';
      return;
    } 
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      currentPosition = position;

      _getAddressFromLatLng(position);

    } catch (e) {
      currentAddress.value = 'Không thể lấy vị trí: $e';
    }
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, 
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks[0];
        String address = "${place.street}, ${place.subAdministrativeArea}, ${place.administrativeArea}"; 

        currentAddress.value = address;

        print("📍 Địa chỉ tìm được: $address");

      } else {
        currentAddress.value = 'Không tìm thấy địa chỉ.';
      }
    } catch (e) {
      currentAddress.value = 'Lỗi lấy địa chỉ: $e';
    }
  }
  
}