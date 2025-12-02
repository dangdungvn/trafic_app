  import 'package:dio/dio.dart';
  import '../models/login_request.dart';
  import '../models/signup_request.dart';
  import '../services/api_service.dart';
  import '../models/profile_request.dart';
  import 'dart:convert'; // Để dùng jsonEncode
  import 'package:http_parser/http_parser.dart'; // Để dùng MediaType

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

    Future<void> login(LoginRequest request) async {
      try {
        final response = await _apiService.dio.post(
          '/auth/login',
          data: request.toJson(),
        );

        if (response.data['success'] == false) {
          throw response.data['message'] ?? 'Đăng nhập thất bại';
        }

        // Save token if available
        if (response.data['data'] != null) {
          final token = response.data['data'] as String;
          _apiService.setToken(token);
        }
      } on DioException catch (e) {
        if (e.response != null && e.response!.data is Map) {
          throw e.response!.data['message'] ?? 'Đăng nhập thất bại';
        }
        throw 'Lỗi kết nối mạng';
      } catch (e) {
        throw e.toString();
      }
    }

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
    Future<void> updateProfile(ProfileRequest user) async {
    try {
      String jsonProfile = jsonEncode(user.toJson());

      final formData = FormData.fromMap({
        'profile': MultipartFile.fromString(
          jsonProfile,
          contentType: MediaType('application', 'json'), // Bắt buộc dòng này để Spring Boot hiểu đây là JSON
        ),
        
        // Nếu sau này bạn làm chức năng upload ảnh thì thêm dòng này:
        // 'avatar': await MultipartFile.fromFile(imagePath),
      });

      // SỬA: Thêm .dio vào
      await _apiService.dio.put(
        '/users/profile', 
        data: formData,
      );
      
      // PUT thường không cần return gì nếu thành công (void)
      
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
