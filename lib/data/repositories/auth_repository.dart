import 'package:dio/dio.dart';
import 'package:traffic_app/data/models/signup_request.dart';
import 'package:traffic_app/data/services/api_service.dart';

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
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        throw e.response!.data['message'] ?? 'Đăng ký thất bại';
      }
      throw 'Lỗi kết nối mạng';
    } catch (e) {
      throw e.toString();
    }
  }
}
