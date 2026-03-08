import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:traffic_app/widgets/custom_alert.dart';

import '../../../data/models/traffic_post_model.dart';
import '../../../data/repositories/follow_repository.dart';
import '../../../data/repositories/traffic_post_repository.dart';
import '../../../services/storage_service.dart';
import '../widgets/report_bottom_sheet.dart';

class DashboardController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final TrafficPostRepository _postRepository = TrafficPostRepository();
  final FollowRepository _followRepository = FollowRepository();
  final StorageService _storageService = Get.find<StorageService>();

  /// ID của user hiện tại (dùng để ẩn nút follow trên bài viết của chính mình)
  int? get currentUserId => _storageService.getUserId();

  final refreshController = RefreshController(initialRefresh: false);
  final ScrollController scrollController = ScrollController();

  // State management
  final posts = <TrafficPostModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final errorMessage = ''.obs;

  // Animation: id của bài viết mới nhất vừa được prepend
  final newPostId = RxnString();

  // Search
  final isSearching = false.obs;
  final currentKeyword = ''.obs;
  Timer? _debounceTimer;

  // Voice search
  final isListening = false.obs;
  final SpeechToText _speechToText = SpeechToText();
  bool _speechAvailable = false;

  // Pagination
  int currentPage = 0;
  final int pageSize = 10;
  String currentLocation = '';

  void scrollToTop() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    if (isListening.value) _speechToText.stop();
    scrollController.dispose();
    searchController.dispose();
    refreshController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    _initializeLocation();
    _setupSearchDebounce();
    _initSpeech();
  }

  /// Khởi tạo speech_to_text
  Future<void> _initSpeech() async {
    _speechAvailable = await _speechToText.initialize(onError: _onSpeechError);
  }

  /// Thiết lập debounce 300ms cho ô tìm kiếm
  void _setupSearchDebounce() {
    searchController.addListener(() {
      final keyword = searchController.text.trim();
      if (keyword == currentKeyword.value) return;

      _debounceTimer?.cancel();
      isSearching.value = keyword.isNotEmpty;

      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        currentKeyword.value = keyword;
        refreshController.resetNoData();
        loadPosts(refresh: true);
      });
    });
  }

  /// Xóa nội dung tìm kiếm và load lại tất cả bài viết
  void clearSearch() {
    searchController.clear();
  }

  /// Bắt đầu / dừng tìm kiếm bằng giọng nói
  Future<void> toggleVoiceSearch() async {
    if (isListening.value) {
      await _speechToText.stop();
      isListening.value = false;
      return;
    }

    if (!_speechAvailable) {
      // Thử khởi tạo lại nếu chưa sẵn sàng
      _speechAvailable = await _speechToText.initialize(
        onError: _onSpeechError,
      );
    }

    if (!_speechAvailable) {
      CustomAlert.show(
        message: 'dashboard_voice_not_available'.tr,
        type: AlertType.warning,
      );
      return;
    }

    isListening.value = true;
    await _speechToText.listen(
      onResult: (result) {
        // Đổ text realtime vào ô tìm kiếm
        searchController.text = result.recognizedWords;
        // Đặt cursor cuối dòng
        searchController.selection = TextSelection.fromPosition(
          TextPosition(offset: searchController.text.length),
        );
        // Khi kết quả final, dừng listening
        if (result.finalResult) {
          isListening.value = false;
        }
      },
      localeId: Get.locale?.toString().replaceAll('_', '-') ?? 'vi-VN',
      pauseFor: const Duration(seconds: 3),
      listenFor: const Duration(seconds: 30),
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
      ),
    );
  }

  void _onSpeechError(SpeechRecognitionError error) {
    isListening.value = false;
    if (error.errorMsg != 'error_speech_timeout' &&
        error.errorMsg != 'error_no_match') {
      CustomAlert.show(
        message: 'dashboard_voice_error'.tr,
        type: AlertType.error,
      );
    }
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
        keyword: currentKeyword.value.isNotEmpty ? currentKeyword.value : null,
      );

      if (newPosts.isEmpty) {
        hasMore.value = false;
        if (refresh) {
          refreshController.refreshCompleted();
        } else {
          refreshController.loadNoData();
        }
      } else {
        if (refresh) {
          posts.value = newPosts;
          refreshController.refreshCompleted();
        } else {
          posts.addAll(newPosts);
          refreshController.loadComplete();
        }
        currentPage++;
      }

      errorMessage.value = '';
    } catch (e) {
      errorMessage.value = e.toString();
      if (refresh) {
        refreshController.refreshFailed();
        CustomAlert.showError(e.toString());
      } else {
        refreshController.loadFailed();
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
    } else if (!hasMore.value) {
      refreshController.loadNoData();
    }
  }

  /// Refresh toàn bộ danh sách
  @override
  Future<void> refresh() async {
    refreshController.resetNoData();
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

  /// Thêm bài viết mới lên đầu danh sách (không rebuild toàn trang)
  void prependPost(TrafficPostModel post) {
    newPostId.value = post.id;
    posts.insert(0, post);
  }

  /// Xóa newPostId sau khi animation kết thúc
  void clearNewPostId() {
    newPostId.value = null;
  }

  /// Toggle like/unlike post với Optimistic Update
  /// - Cập nhật UI ngay lập tức (không chờ API)
  /// - Gọi API ở nền
  /// - Nếu API lỗi: rollback lại trạng thái cũ
  Future<void> toggleLike(TrafficPostModel post) async {
    final index = posts.indexWhere((p) => p.id == post.id);
    if (index == -1 || post.id == null) return;

    final currentIsLiked = post.isLiked ?? false;
    final currentLikes = post.likes ?? 0;

    // Optimistic update: cập nhật UI ngay
    posts[index] = post.copyWith(
      isLiked: !currentIsLiked,
      likes: currentIsLiked ? currentLikes - 1 : currentLikes + 1,
    );

    try {
      await _postRepository.likePost(post.id!);
    } catch (_) {
      // Rollback nếu API thất bại
      if (index < posts.length) {
        posts[index] = post.copyWith(
          isLiked: currentIsLiked,
          likes: currentLikes,
        );
      }
    }
  }

  /// Toggle follow/unfollow user với Optimistic Update
  Future<void> toggleFollow(TrafficPostModel post) async {
    final index = posts.indexWhere((p) => p.id == post.id);
    if (index == -1 || post.userId == null) return;

    final userId = int.tryParse(post.userId!);
    if (userId == null) return;

    final currentFollow = post.isFollowedByCurrentUser ?? false;

    // Optimistic update: cập nhật UI ngay
    posts[index] = post.copyWith(isFollowedByCurrentUser: !currentFollow);

    try {
      await _followRepository.followUser(userId);
    } catch (_) {
      // Rollback nếu API thất bại
      if (index < posts.length) {
        posts[index] = post.copyWith(isFollowedByCurrentUser: currentFollow);
      }
    }
  }

  /// Report post
  void reportPost(TrafficPostModel post) {
    if (post.id == null) return;

    Get.bottomSheet(
      ReportBottomSheet(
        onReport: (reason) async {
          try {
            await _postRepository.reportPost(postId: post.id!, reason: reason);

            Get.back();

            WidgetsBinding.instance.addPostFrameCallback((_) {
              CustomAlert.showSuccess('dashboard_report_success'.tr);
            });
          } catch (e) {
            Get.back();

            WidgetsBinding.instance.addPostFrameCallback((_) {
              CustomAlert.showError(e.toString());
            });
          }
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
