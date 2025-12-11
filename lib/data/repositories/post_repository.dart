import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart'; // Cần import cái này
import '../services/api_service.dart';
import '../models/post_request.dart';

class PostRepository {
  final ApiService _apiService = ApiService();

  Future<void> createPost({
    required PostRequest request,
    required File imageFile,
  }) async {
    try {
      String jsonString = jsonEncode(request.toJson());

      final formData = FormData.fromMap({
        // Ngăn 1: Chứa JSON thông tin bài viết
        'TrafficPost': MultipartFile.fromString(
          jsonString,
          contentType: MediaType('application', 'json'),
        ),

        // Ngăn 2: Chứa File ảnh
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
          contentType: MediaType('image', 'jpeg'),
        ),
      });

      // 3. Gửi API
      await _apiService.dio.post(
        '/TrafficPost',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data', 
          },
        ),
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw e.response!.data['message'] ?? 'Đăng bài thất bại (${e.response?.statusCode})';
      }
      throw 'Lỗi kết nối máy chủ';
    } catch (e) {
      throw e.toString();
    }
  }
}