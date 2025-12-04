  import 'package:dio/dio.dart';
  import '../models/login_request.dart';
  import '../models/signup_request.dart';
  import '../services/api_service.dart';
  import 'package:firebase_messaging/firebase_messaging.dart';

  class AuthRepository {
    final ApiService _apiService = ApiService();
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

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
        String? deviceToken = await _getDeviceToken();
        final requestData = request.toJson();
        if (deviceToken != null) {
          requestData['deviceToken'] = deviceToken;
        }
        final response = await _apiService.dio.post(
          '/auth/login',
          data: requestData,
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
    // --- Lấy Device Token từ Firebase ---
    Future<String?> _getDeviceToken() async {
      try {
        // 1. Xin quyền thông báo (Bắt buộc cho iOS)
        await _firebaseMessaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );

        // 2. Lấy token
        String? token = await _firebaseMessaging.getToken();
        print("FCM Token: $token"); // Log để debug
        return token;
      } catch (e) {
        print("Lỗi lấy Device Token: $e");
        // Trả về null nếu lỗi, để luồng đăng nhập vẫn tiếp tục bình thường
        return null;
      }
    }
  }
