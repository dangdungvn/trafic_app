import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class AssetsService extends GetxService {
  static AssetsService get to => Get.find();

  final Rx<LottieComposition?> notFoundComposition = Rx<LottieComposition?>(
    null,
  );
  final Rx<LottieComposition?> loadingComposition = Rx<LottieComposition?>(
    null,
  );

  Future<void> init() async {
    // Preload critical animations
    try {
      notFoundComposition.value = await AssetLottie(
        'assets/animations/404_not_found.json',
      ).load();
      loadingComposition.value = await AssetLottie(
        'assets/animations/Loading.json',
      ).load();
    } catch (e) {
      debugPrint('Error preloading assets: $e');
    }
  }
}
