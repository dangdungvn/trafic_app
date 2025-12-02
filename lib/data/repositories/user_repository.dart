import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../models/profile_request.dart';
import '../services/api_service.dart';

class UserRepository {
  final ApiService _apiService = ApiService();

  // 1. Lấy thông tin (GET)
  Future<ProfileRequest> getProfile() async {
    try {
      final response = await _apiService.dio.get('/users/profile');

      // Nếu API trả về thành công 200 OK
      return ProfileRequest.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        throw e.response!.data['message'] ?? 'Không thể tải thông tin cá nhân';
      }
      throw 'Lỗi kết nối khi lấy thông tin';
    } catch (e) {
      throw e.toString();
    }
  }

  // 2. Cập nhật thông tin (PUT)
  Future<void> updateProfile(ProfileRequest user, File? avatarFile) async {
    try {
      String jsonProfile = jsonEncode(user.toJson());
      print("JSON Profile: $jsonProfile");
      final Map<String, dynamic> formDataMap = {
        'profile': MultipartFile.fromString(
          jsonProfile,
          contentType: MediaType('application', 'json'),
        ),
      };
      if (avatarFile != null) {
        String fileName = avatarFile.path.split('/').last;
        formDataMap['avatar'] = await MultipartFile.fromFile(
          avatarFile.path,
          filename: fileName,
          contentType: MediaType('image', 'jpeg'),
        );
      }

      final formData = FormData.fromMap(formDataMap);
      print("Form Data: $formData");
      await _apiService.dio.put('/users/profile', data: formData);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        throw e.response!.data['message'] ?? 'Cập nhật thất bại';
      }
      throw 'Lỗi kết nối khi cập nhật';
    } catch (e) {
      throw e.toString();
    }
  }
}
