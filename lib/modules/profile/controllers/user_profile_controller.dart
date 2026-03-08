import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:traffic_app/widgets/custom_alert.dart';

import '../../../data/models/traffic_post_model.dart';
import '../../../data/models/user_info_model.dart';
import '../../../data/repositories/follow_repository.dart';
import '../../../data/repositories/traffic_post_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../services/storage_service.dart';
import '../../dashboard/widgets/report_bottom_sheet.dart';

class UserProfileController extends GetxController {
  // profile cache 
  static final Map<String, Map<String, dynamic>> _profileCache = {};

  final UserRepository _userRepo = UserRepository();
  final TrafficPostRepository _postRepository = TrafficPostRepository();
  final FollowRepository _followRepository = FollowRepository();
  final StorageService _storageService = Get.find<StorageService>();

  final refreshController = RefreshController(initialRefresh: false);
  final ScrollController scrollController = ScrollController();

  final userInfo = Rxn<UserInfoModel>();
  final posts = <TrafficPostModel>[].obs; 
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final errorMessage = ''.obs;

  final isFollowing = false.obs;
  final totalLikes = 0.obs;

  int currentPage = 0;
  final int pageSize = 10;

  late final String targetUserId;
  late final bool isMyProfile;

  int? get currentUserId => _storageService.getUserId();

  @override
  void onInit() {
    super.onInit();
    final myId = currentUserId?.toString() ?? '';
    targetUserId = Get.arguments?['userId']?.toString() ?? myId;
    isMyProfile = (targetUserId == myId);

    // ✅ Thay thế loadProfileData bằng hàm check cache
    _checkCacheAndLoad();
  }

  @override
  void onClose() {
    scrollController.dispose();
    refreshController.dispose();
    super.onClose();
  }

  void scrollToTop() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  // =========================================================================
  // LOGIC KIỂM TRA BỘ NHỚ ĐỆM TRƯỚC KHI GỌI API
  // =========================================================================
  void _checkCacheAndLoad() {
    if (_profileCache.containsKey(targetUserId)) {
      // 1. CÓ CACHE: Nạp dữ liệu lên màn hình ngay lập tức (0s chờ đợi)
      final cachedData = _profileCache[targetUserId]!;
      userInfo.value = cachedData['userInfo'];
      posts.assignAll(cachedData['posts']);
      isFollowing.value = userInfo.value?.follow ?? false;
      _calculateTotalLikes();
      
      isLoading.value = false;

      // 2. Gọi API ngầm ở nền để cập nhật số Like/Follow mới nhất (Không hiện vòng xoay)
      loadProfileData(refresh: true, showLoading: false);
    } else {
      // 3. CHƯA CÓ CACHE: Load bình thường và bật Shimmer
      loadProfileData(refresh: true, showLoading: true);
    }
  }

  // =========================================================================
  // TẢI DỮ LIỆU TỪ API (Có hỗ trợ showLoading để ẩn/hiện vòng xoay)
  // =========================================================================
  Future<void> loadProfileData({bool refresh = false, bool showLoading = true}) async {
    if (refresh) {
      currentPage = 0;
      hasMore.value = true;
      errorMessage.value = '';
    }

    if (!hasMore.value) return;

    // Set loading state
    if (refresh) {
      if (showLoading) {
        isLoading.value = true;
        posts.clear(); // Xóa list cũ đi để hiện xương Shimmer
      }
    } else {
      isLoadingMore.value = true;
    }

    try {
      // Gọi API lấy UserInfo & Posts (có phân trang)
      final result = await _userRepo.getUserProfile(
        targetUserId,
        page: currentPage,
        size: pageSize,
      );

      final newUserInfo = result['userInfo'] as UserInfoModel;
      final newPosts = result['posts'] as List<TrafficPostModel>;

      userInfo.value = newUserInfo;
      isFollowing.value = newUserInfo.follow ?? false;

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
          
          // ✅ LƯU KẾT QUẢ MỚI VÀO BỘ NHỚ ĐỆM TĨNH ĐỂ LẦN SAU DÙNG
          _profileCache[targetUserId] = {
            'userInfo': newUserInfo,
            'posts': List<TrafficPostModel>.from(newPosts), // Tạo bản sao danh sách
          };
        } else {
          posts.addAll(newPosts);
          refreshController.loadComplete();
        }
        currentPage++;
      }

      errorMessage.value = '';
      _calculateTotalLikes();

    } catch (e) {
      errorMessage.value = e.toString();
      if (refresh) {
        refreshController.refreshFailed();
        // Chỉ văng lỗi bự lên màn hình nếu là lần đầu load và không có cache
        if (posts.isEmpty) CustomAlert.showError(e.toString());
      } else {
        refreshController.loadFailed();
      }
    } finally {
      if (showLoading) isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Load more khi scroll đến cuối danh sách (Gọi bởi SmartRefresher)
  Future<void> loadMore() async {
    if (!isLoadingMore.value && hasMore.value) {
      await loadProfileData(refresh: false, showLoading: false);
    } else if (!hasMore.value) {
      refreshController.loadNoData();
    }
  }

  /// Refresh toàn bộ danh sách
  @override
  Future<void> refresh() async {
    refreshController.resetNoData();
    await loadProfileData(refresh: true, showLoading: true);
  }

  void _calculateTotalLikes() {
    totalLikes.value = posts.fold(0, (sum, post) => sum + (post.likes ?? 0));
  }

  Future<void> toggleUserFollow() async {
    if (isMyProfile) return;

    // Optimistic Update cho Header
    isFollowing.value = !isFollowing.value;
    if (userInfo.value != null) {
      int currentFollowers = userInfo.value!.followersCount ?? 0;
      int newFollowers = isFollowing.value ? currentFollowers + 1 : currentFollowers - 1;
      
      userInfo.value = userInfo.value!.copyWith(
        followersCount: newFollowers > 0 ? newFollowers : 0,
        follow: isFollowing.value,
      );
    }

    try {
      final userIdInt = int.tryParse(targetUserId);
      if (userIdInt != null) {
        await _followRepository.followUser(userIdInt);
      }
    } catch (_) {
      // Rollback
      isFollowing.value = !isFollowing.value;
      CustomAlert.showError('Không thể thực hiện. Vui lòng thử lại!');
    }
  }

  /// Toggle like/unlike post 
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
    _calculateTotalLikes();

    try {
      await _postRepository.likePost(post.id!);
    } catch (_) {
      if (index < posts.length) {
        posts[index] = post.copyWith(
          isLiked: currentIsLiked,
          likes: currentLikes,
        );
        _calculateTotalLikes();
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
              CustomAlert.showSuccess('Báo cáo bài viết thành công');
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