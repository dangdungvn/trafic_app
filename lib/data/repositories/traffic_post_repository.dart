import 'package:dio/dio.dart';
import '../models/traffic_post_model.dart';
import '../services/api_service.dart';

class TrafficPostRepository {
  final ApiService _apiService = ApiService();

  /// Lấy danh sách bài viết theo vị trí với pagination
  ///
  /// [location]: Tên địa điểm (province hoặc address)
  /// [page]: Số trang (bắt đầu từ 0)
  /// [size]: Số lượng bài viết mỗi trang (mặc định 10)
  ///
  /// Returns: List<TrafficPostModel> hoặc throw Exception
  Future<List<TrafficPostModel>> getPosts({
    required String location,
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await _apiService.dio.get(
        '/TrafficPost',
        queryParameters: {'location': location, 'page': page, 'size': size},
      );
      // Check response structure
      if (response.data == null) {
        return [];
      }

      // Handle different response formats
      List<dynamic> postsJson = [];

      if (response.data is Map) {
        // New format: { data: { content: [...] }, success: true }
        final data = response.data['data'];
        if (data != null) {
          if (data is Map && data['content'] != null) {
            postsJson = data['content'] as List;
          } else if (data is List) {
            postsJson = data;
          }
        } else if (response.data['content'] != null) {
          // Fallback for direct Pageable response
          postsJson = response.data['content'] as List;
        }
      } else if (response.data is List) {
        postsJson = response.data as List;
      }

      return postsJson
          .map(
            (json) => TrafficPostModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response!.data is Map
            ? e.response!.data['message'] ?? 'Không thể tải bài viết'
            : 'Không thể tải bài viết';
        throw errorMessage;
      }
      throw 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet.';
    } catch (e) {
      throw 'Có lỗi xảy ra: ${e.toString()}';
    }
  }

  /// Tạo bài viết mới
  Future<TrafficPostModel> createPost({
    required String userId,
    required String type,
    required String content,
    required double lat,
    required double lng,
    required String address,
    String status = 'ACTIVE',
    List<String>? filePaths,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'TrafficPost': {
          'userId': userId,
          'type': type,
          'content': content,
          'location': {'lat': lat, 'lng': lng, 'address': address},
          'status': status,
          'timestamp': DateTime.now().toIso8601String(),
        },
      });

      // Add files if provided
      if (filePaths != null && filePaths.isNotEmpty) {
        for (var path in filePaths) {
          formData.files.add(
            MapEntry('file', await MultipartFile.fromFile(path)),
          );
        }
      }

      final response = await _apiService.dio.post(
        '/TrafficPost',
        data: formData,
      );

      if (response.data['success'] == false) {
        throw response.data['message'] ?? 'Không thể tạo bài viết';
      }

      final postData = response.data['data'] ?? response.data;
      return TrafficPostModel.fromJson(postData as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        throw e.response!.data['message'] ?? 'Không thể tạo bài viết';
      }
      throw 'Lỗi kết nối mạng';
    } catch (e) {
      throw e.toString();
    }
  }

  /// Cập nhật bài viết
  Future<void> updatePost({
    required String postId,
    required String userId,
    required String type,
    required String content,
    required double lat,
    required double lng,
    required String address,
    required String status,
  }) async {
    try {
      final response = await _apiService.dio.put(
        '/TrafficPost/$postId',
        data: {
          'userId': userId,
          'type': type,
          'content': content,
          'location': {'lat': lat, 'lng': lng, 'address': address},
          'status': status,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (response.data['success'] == false) {
        throw response.data['message'] ?? 'Không thể cập nhật bài viết';
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        throw e.response!.data['message'] ?? 'Không thể cập nhật bài viết';
      }
      throw 'Lỗi kết nối mạng';
    } catch (e) {
      throw e.toString();
    }
  }

  /// Xóa bài viết
  Future<void> deletePost(String postId) async {
    try {
      final response = await _apiService.dio.delete('/TrafficPost/$postId');

      if (response.data['success'] == false) {
        throw response.data['message'] ?? 'Không thể xóa bài viết';
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        throw e.response!.data['message'] ?? 'Không thể xóa bài viết';
      }
      throw 'Lỗi kết nối mạng';
    } catch (e) {
      throw e.toString();
    }
  }
}
