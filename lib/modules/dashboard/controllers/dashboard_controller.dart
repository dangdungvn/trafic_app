import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:traffic_app/widgets/custom_alert.dart';
import '../../../data/models/traffic_post_model.dart';
import '../../../data/repositories/traffic_post_repository.dart';
import '../../../services/storage_service.dart';
import '../widgets/report_bottom_sheet.dart';

class DashboardController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final TrafficPostRepository _postRepository = TrafficPostRepository();
  final StorageService _storageService = Get.find<StorageService>();

  // State management
  final posts = <TrafficPostModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final errorMessage = ''.obs;

  // Pagination
  int currentPage = 0;
  final int pageSize = 10;
  String currentLocation = '';

  @override
  void onInit() {
    super.onInit();
    _initializeLocation();
  }

  /// Khởi tạo location từ storage và load posts
  void _initializeLocation() async {
    // Lấy province từ user profile hoặc default
    final prefs = _storageService;
    currentLocation = prefs.getString('userProvince') ?? 'Hà Nội';

    // Load posts lần đầu
    await loadPosts(refresh: true);
  }

  /// Load danh sách bài viết
  /// [refresh]: true nếu muốn load lại từ đầu (pull to refresh)
  Future<void> loadPosts({bool refresh = false}) async {
    if (refresh) {
      currentPage = 0;
      hasMore.value = true;
      errorMessage.value = '';
    }

    if (!hasMore.value) return;

    // Set loading state
    if (refresh) {
      isLoading.value = true;
      posts.clear();
    } else {
      isLoadingMore.value = true;
    }

    try {
      final newPosts = await _postRepository.getPosts(
        location: currentLocation,
        page: currentPage,
        size: pageSize,
      );

      if (newPosts.isEmpty) {
        hasMore.value = false;
      } else {
        if (refresh) {
          posts.value = newPosts;
        } else {
          posts.addAll(newPosts);
        }
        currentPage++;
      }

      errorMessage.value = '';
    } catch (e) {
      errorMessage.value = e.toString();
      if (refresh) {
        CustomAlert.showError(e.toString());
      }
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Load more khi scroll đến cuối danh sách
  Future<void> loadMore() async {
    if (!isLoadingMore.value && hasMore.value) {
      await loadPosts(refresh: false);
    }
  }

  /// Refresh toàn bộ danh sách
  @override
  Future<void> refresh() async {
    await loadPosts(refresh: true);
  }

  /// Thay đổi location và load lại posts
  void changeLocation(String location) {
    if (location != currentLocation) {
      currentLocation = location;
      // Save to storage
      _storageService.setString('userProvince', location);
      loadPosts(refresh: true);
    }
  }

  /// Toggle like/unlike post
  void toggleLike(TrafficPostModel post) {
    final index = posts.indexWhere((p) => p.id == post.id);
    if (index != -1) {
      final updatedPost = posts[index].copyWith(
        likes: post.isLiked ? post.likes - 1 : post.likes + 1,
        isLiked: !post.isLiked,
      );
      posts[index] = updatedPost;
    }

    // TODO: Call API to update like status on server
  }

  /// Report post
  void reportPost(TrafficPostModel post) {
    Get.bottomSheet(
      ReportBottomSheet(
        onReport: (reason) async {
          await Future.delayed(const Duration(seconds: 1));

          Get.back();

          WidgetsBinding.instance.addPostFrameCallback((_) {
            CustomAlert.showSuccess("Đã báo cáo bài viết: $reason");
          });

          // TODO: Call API to report post
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
