import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/fine_record_model.dart';
import '../../../data/repositories/fine_repository.dart';

class DiscoveryController extends GetxController {
  final FineRepository _repository = FineRepository();

  final searchController = TextEditingController();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final fineResponse = Rxn<FineResponse>();

  bool get hasSearched => fineResponse.value != null || errorMessage.isNotEmpty;

  Future<void> searchFines() async {
    final plate = searchController.text.trim();
    if (plate.isEmpty) return;

    isLoading.value = true;
    errorMessage.value = '';
    fineResponse.value = null;

    try {
      final result = await _repository.lookupFines(plate);
      fineResponse.value = result;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void clearSearch() {
    searchController.clear();
    fineResponse.value = null;
    errorMessage.value = '';
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
