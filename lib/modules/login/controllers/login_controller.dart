import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/login_request.dart';
import '../../../services/storage_service.dart';
import '../../../widgets/custom_dialog.dart';

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
    // 1. Ẩn bàn phím để tránh lỗi Focus/Controller khi đang xử lý
    Get.focusScope?.unfocus();

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
      // 2. Gọi hàm login
      // Vì bên Repo đã "throw" lỗi nếu thất bại, nên ta chỉ cần await.
      // Nếu dòng này chạy xong mà không văng lỗi -> nghĩa là Đăng nhập thành công.
      await _authRepository.login(
        LoginRequest(
          username: usernameController.text.trim(),
          password: passwordController.text,
        ),
      );

      // --- XỬ LÝ KHI THÀNH CÔNG ---
      
      // Lưu mật khẩu nếu cần
      if (rememberMe.value) {
        await _storageService.saveCredentials(
          usernameController.text.trim(),
          passwordController.text,
        );
      } else {
        await _storageService.clearCredentials();
      }

      // QUAN TRỌNG: Tắt loading TRƯỚC khi chuyển trang
      // Để tránh việc Controller bị hủy mà isLoading vẫn cố update UI
      isLoading.value = false;

      // Chuyển sang trang chủ
      Get.offAllNamed(Routes.HOME);

    } catch (e) {
      // --- XỬ LÝ KHI CÓ LỖI (Repo ném ra) ---
      
      // 1. Phải tắt loading ngay để người dùng bấm lại được (tránh bị đơ)
      isLoading.value = false;
      
      // 2. Lấy thông báo lỗi
      // Vì Repo của bạn throw String, nên e chính là chuỗi thông báo lỗi
      String errorMessage = e.toString();
      
      // Xử lý chuỗi "Exception:" nếu có (cho đẹp)
      if (errorMessage.startsWith("Exception: ")) {
        errorMessage = errorMessage.replaceAll("Exception: ", "");
      }

      // 3. Hiện Dialog báo lỗi
      CustomDialog.show(
        title: 'Đăng nhập thất bại',
        message: errorMessage,
        type: DialogType.error,
      );
    }
    
    // KHÔNG DÙNG FINALLY Ở ĐÂY
    // Vì nếu đăng nhập thành công, ta đã chuyển trang (Get.offAllNamed).
    // Nếu dùng finally, nó sẽ chạy sau khi chuyển trang -> Controller đã bị hủy -> Lỗi "TextEditingController disposed"
  }
}
