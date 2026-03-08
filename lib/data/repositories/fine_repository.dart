import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../models/fine_record_model.dart';

class FineRepository {
  static const String _baseUrl = 'https://api.checkphatnguoi.vn';

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      responseType: ResponseType
          .plain, // nhận raw string, tự decode để tránh lỗi content-type
    ),
  );

  Future<FineResponse> lookupFines(String licensePlate) async {
    final plate = licensePlate.trim().toUpperCase();
    try {
      final response = await _dio.post(
        '$_baseUrl/phatnguoi',
        data: {'bienso': plate},
      );
      final Map<String, dynamic> json =
          jsonDecode(response.data as String) as Map<String, dynamic>;
      return FineResponse.fromJson(json);
    } on DioException catch (e) {
      throw e.message ?? 'discovery_error_network'.tr;
    }
  }
}
