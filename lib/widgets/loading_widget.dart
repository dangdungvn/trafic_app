import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import '../services/assets_service.dart';

class LoadingWidget extends StatelessWidget {
  final double? height;
  final double? width;

  const LoadingWidget({super.key, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    final composition = AssetsService.to.loadingComposition.value;
    if (composition != null) {
      return Lottie(
        composition: composition,
        height: height ?? 40.h,
        width: width,
        fit: BoxFit.contain,
        renderCache: RenderCache.drawingCommands,
      );
    }
    return Lottie.asset(
      'assets/animations/Loading.json',
      height: height ?? 40.h,
      width: width,
      fit: BoxFit.contain,
      renderCache: RenderCache.drawingCommands,
    );
  }
}
