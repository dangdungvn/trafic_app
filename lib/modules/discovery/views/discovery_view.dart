import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/discovery_controller.dart';

class DiscoveryView extends GetView<DiscoveryController> {
  const DiscoveryView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Tra cứu"));
  }
}
