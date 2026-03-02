import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../controllers/discovery_controller.dart';

class DiscoveryView extends GetView<DiscoveryController> {
  const DiscoveryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "traffic_fine_lookup".tr, // Tận dụng luôn đa ngôn ngữ
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      // Bỏ hẳn Stack và vòng xoay Loading, ốp thẳng WebView vào luôn
      body: WebViewWidget(controller: controller.webViewController),
    );
  }
}