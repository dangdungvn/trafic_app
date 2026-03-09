import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart'; 
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../../../theme/app_theme.dart';
import '../../../widgets/custom_dialog.dart';
import '../../../widgets/loading_widget.dart'; 
import '../../../services/assets_service.dart'; 
import '../../dashboard/widgets/post_item.dart'; 
import '../../dashboard/widgets/post_item_shimmer.dart'; 
import '../controllers/user_profile_controller.dart';
import 'package:traffic_app/modules/profile/views/profile_view.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserProfileController());
    final heroTag = Get.arguments?['heroTag']?.toString();
    final initialAvatarUrl = Get.arguments?['initialAvatarUrl']?.toString();
    final initialUserName = Get.arguments?['initialUserName']?.toString();


    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textColor),
          onPressed: () => Get.back(),
        ),
        title: Obx(() => Text(
          controller.userInfo.value?.fullname ?? initialUserName ?? 'Thông tin người dùng',
          style: TextStyle(color: AppTheme.textColor, fontSize: 18.sp, fontWeight: FontWeight.bold),
        )),
        actions: [
          if (!controller.isMyProfile)
            Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: Center(
                child: Obx(() {
                  final isFollowed = controller.isFollowing.value;
                  return GestureDetector(
                    onTap: () {
                      if (isFollowed) {
                        CustomDialog.showConfirm(
                          context: context,
                          title: 'Hủy follow',
                          message: 'Bạn đã chắc chắn với lựa chọn của mình?',
                          confirmText: 'Xác nhận',
                          cancelText: 'Hủy',
                          onConfirm: () {
                            controller.toggleUserFollow();
                            Get.back();
                          },
                        );
                      } else {
                        controller.toggleUserFollow();
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: isFollowed ? AppTheme.primaryBgColor : AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(100.r),
                        boxShadow: isFollowed ? [] : [
                          BoxShadow(color: AppTheme.primaryColor.withOpacity(0.25), offset: const Offset(0, 4), blurRadius: 12),
                        ],
                      ),
                      child: Text(
                        isFollowed ? 'Unfollow' : 'Follow',
                        style: TextStyle(color: isFollowed ? AppTheme.primaryColor : Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }),
              ),
            ),

          if (controller.isMyProfile)
            IconButton(
              icon: Icon(Icons.settings_outlined, color: AppTheme.textColor),
              onPressed: () => Get.to(() => const ProfileView()),
            ),
        ],
      ),
      
      // ✅ SMART REFRESHER SỬ DỤNG CUSTOM FOOTER CỦA DASHBOARD
      body: SmartRefresher(
        controller: controller.refreshController,
        scrollController: controller.scrollController, // Bổ sung ScrollController
        enablePullDown: true,
        enablePullUp: true,
        header: const WaterDropHeader(),
        footer: CustomFooter(
          builder: (context, mode) {
            Widget body;
            if (mode == LoadStatus.idle) {
              body = Text('dashboard_pull_up_load'.tr, style: TextStyle(fontSize: 13.sp, color: Colors.grey[500]));
            } else if (mode == LoadStatus.loading) {
              body = Center(child: LoadingWidget());
            } else if (mode == LoadStatus.failed) {
              body = Text('dashboard_load_failed'.tr, style: TextStyle(fontSize: 13.sp, color: Colors.grey[500]));
            } else if (mode == LoadStatus.canLoading) {
              body = Text('dashboard_release_to_load'.tr, style: TextStyle(fontSize: 13.sp, color: Colors.grey[500]));
            } else {
              final closeComp = AssetsService.to.closeComposition.value;
              body = SizedBox(
                height: 120.h,
                width: 120.h,
                child: closeComp != null
                    ? Lottie(composition: closeComp, fit: BoxFit.contain, repeat: true, renderCache: RenderCache.drawingCommands)
                    : Lottie.asset('assets/animations/Close.json', fit: BoxFit.contain, repeat: true, renderCache: RenderCache.drawingCommands),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 100.0),
              child: SizedBox(height: 140.h, child: Center(child: body)),
            );
          },
        ),
        onRefresh: controller.refresh,
        onLoading: controller.loadMore,
        
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Obx(() {
                final user = controller.userInfo.value;
                final displayAvatarUrl = user?.fullAvatarUrl ?? initialAvatarUrl;
                final displayUserName = user?.fullname ?? initialUserName ?? 'Đang tải...';

                return Column(
                  children: [
                    SizedBox(height: 20.h),
                    Hero(
                      tag: heroTag ?? 'avatar_default_${controller.targetUserId}', 
                      child: ClipOval(
                        child: displayAvatarUrl != null
                            ? CachedNetworkImage(
                                imageUrl: displayAvatarUrl, 
                                width: 90.w, 
                                height: 90.w, 
                                fit: BoxFit.cover,
                                placeholder: (context, url) => CircularProgressIndicator(color: AppTheme.primaryColor),
                                errorWidget: (context, url, error) => Icon(Icons.person, size: 50.sp, color: Colors.grey),
                              )
                            : Container( // Placeholder khi hoàn toàn không có ảnh
                                width: 90.w, 
                                height: 90.w, 
                                color: Colors.grey[200],
                                child: Icon(Icons.person, size: 50.sp, color: Colors.grey),
                              ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    SizedBox(height: 12.h),
                    Text(
                      displayUserName, 
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppTheme.textColor)
                    ),                    SizedBox(height: 28.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem('${user?.followingsCount ?? 0}', 'Đã follow'),
                        _buildStatItem('${user?.followersCount ?? 0}', 'follower'),
                        _buildStatItem('${controller.totalLikes.value}', 'Thích'),
                      ],
                    ),
                    SizedBox(height: 24.h),
                  ],
                );
              }),
            ),

            // ==========================================
            // PHẦN DANH SÁCH BÀI VIẾT TÍCH HỢP SHIMMER VÀ LOTTIE
            // ==========================================
            Obx(() {
              // 1. TRẠNG THÁI LOADING: Dùng SliverList + PostItemShimmer
              if (controller.isLoading.value && controller.posts.isEmpty) {
                return SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: EdgeInsets.only(bottom: 20.h),
                        child: const PostItemShimmer(),
                      ),
                      childCount: 3, // Hiện 3 bộ xương (skeleton)
                    ),
                  ),
                );
              }

              // 2. TRẠNG THÁI TRỐNG: Dùng Lottie + SliverToBoxAdapter
              if (controller.posts.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 40.h), 
                        SizedBox(
                          height: 260.h,
                          child: AssetsService.to.notFoundComposition.value != null
                              ? Lottie(
                                  composition: AssetsService.to.notFoundComposition.value!,
                                  fit: BoxFit.contain,
                                  repeat: true,
                                )
                              : Lottie.asset(
                                  'assets/animations/404_not_found.json',
                                  fit: BoxFit.contain,
                                  repeat: true,
                                  renderCache: RenderCache.drawingCommands,
                                ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'dashboard_no_posts'.tr,
                          style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // 3. TRẠNG THÁI CÓ DỮ LIỆU: Render danh sách thật
              return SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final post = controller.posts[index];
                      final postId = post.id ?? '';

                      return Padding(
                        padding: EdgeInsets.only(bottom: 20.h),
                        child: PostItem(
                          key: ValueKey(post.id),
                          post: post,
                          isLikedRx: controller.likedState(postId),
                          likeCountRx: controller.likeCount(postId),
                          isFollowedRx: controller.followedState(postId),

                          currentUserId: controller.currentUserId,
                          onLike: () => controller.toggleLike(post),
                          onReport: () => controller.reportPost(post),
                          onFollow: () {}, 
                        ),
                      );
                    },
                    childCount: controller.posts.length, 
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String number, String label) {
    return Column(
      children: [
        Text(number, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
        SizedBox(height: 4.h),
        Text(label, style: TextStyle(fontSize: 13.sp, color: AppTheme.subTextColor)),
      ],
    );
  }
}