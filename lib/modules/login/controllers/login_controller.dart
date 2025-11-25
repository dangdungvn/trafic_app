import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class LoginController extends GetxController {
  var rememberMe = false.obs;
  var assetLoadProgress = 0.0.obs;
  var isAssetsLoaded = false.obs;

  final usernameFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  // List of assets to preload
  final List<String> _assetsToLoad = [
    'assets/animations/404_not_found.json',
    // Add other Lottie files here
  ];

  @override
  void onInit() {
    super.onInit();
    _preloadAssets();
  }

  @override
  void onClose() {
    usernameFocusNode.dispose();
    passwordFocusNode.dispose();
    super.onClose();
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  Future<void> _preloadAssets() async {
    if (_assetsToLoad.isEmpty) {
      assetLoadProgress.value = 1.0;
      isAssetsLoaded.value = true;
      return;
    }

    int loadedCount = 0;
    for (final asset in _assetsToLoad) {
      try {
        // Load and cache the Lottie composition
        await AssetLottie(asset).load();
      } catch (e) {
        debugPrint('Failed to preload asset: $asset, error: $e');
      } finally {
        loadedCount++;
        assetLoadProgress.value = loadedCount / _assetsToLoad.length;
      }
    }

    isAssetsLoaded.value = true;
  }
}
