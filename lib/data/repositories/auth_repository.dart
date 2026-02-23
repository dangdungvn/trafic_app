import 'package:dio/dio.dart';

import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/signup_request.dart';
import '../services/api_service.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();

  Future<void> signup(SignupRequest request) async {
    try {
      final response = await _apiService.dio.post(
        '/auth/signup',
        data: request.toJson(),
      );

      if (response.data['success'] == false) {
        throw response.data['message'] ?? 'Đăng ký thất bại';
      }

      // Save token if available
      if (response.data['data'] != null) {
        final token = response.data['data'] as String;
        _apiService.setToken(token);
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        throw e.response!.data['message'] ?? 'Đăng ký thất bại';
      }
      throw 'Lỗi kết nối mạng';
    } catch (e) {
      throw e.toString();
    }
  }

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _apiService.dio.post(
        '/auth/login',
        data: request.toJson(),
      );

      if (response.data['success'] == false) {
        throw response.data['message'] ?? 'Đăng nhập thất bại';
      }

      // Parse login response
      final loginResponse = LoginResponse.fromJson(response.data['data']);

      // Save token
      _apiService.setToken(loginResponse.token);

      return loginResponse;
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        throw e.response!.data['message'] ?? 'Đăng nhập thất bại';
      }
      throw 'Lỗi kết nối mạng';
    } catch (e) {
      throw e.toString();
    }
  }
}
