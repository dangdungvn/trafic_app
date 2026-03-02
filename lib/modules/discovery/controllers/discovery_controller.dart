import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DiscoveryController extends GetxController {
  late final WebViewController webViewController;

  @override
  void onInit() {
    super.onInit();
    
    // Khởi tạo và cấu hình WebView siêu gọn nhẹ
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // Bắt buộc bật để trang web không bị lỗi hiển thị
      ..loadRequest(Uri.parse('https://vnexpress.net/tra-cuu-phat-nguoi-oto-xe-may-5004696.html'));
  }
}