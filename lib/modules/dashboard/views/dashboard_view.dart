import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:traffic_app/theme/app_theme.dart';
import 'package:traffic_app/widgets/loading_widget.dart';

import '../../../services/assets_service.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/new_post_animator.dart';
import '../widgets/post_item_shimmer.dart';
import '../widgets/widgets.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Column(
          children: [
            // Header cố định
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(
                left: 24.w,
                right: 24.w,
                top: MediaQuery.paddingOf(context).top + 10.h,
                bottom: 10.h,
              ),
              child: const DashboardHeader(),
            ),
            // Search bar cố định
            Container(
              padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16.r),
                  bottomRight: Radius.circular(16.r),
                ),
              ),
              child: DashboardSearchBar(
                controller: controller.searchController,
              ),
            ),
            SizedBox(height: 10.h),
            // Content với SmartRefresher
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    itemCount: 5,
                    itemBuilder: (context, index) => Padding(
                      padding: EdgeInsets.only(bottom: 20.h),
                      child: const PostItemShimmer(),
                    ),
                  );
                }

                if (controller.posts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 260.h,
                          child:
                              AssetsService.to.notFoundComposition.value != null
                              ? Lottie(
                                  composition: AssetsService
                                      .to
                                      .notFoundComposition
                                      .value!,
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
                          controller.currentKeyword.value.isNotEmpty
                              ? 'dashboard_no_search_results'.tr
                              : 'dashboard_no_posts'.tr,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return SmartRefresher(
                  controller: controller.refreshController,
                  scrollController: controller.scrollController,
                  enablePullDown: true,
                  enablePullUp: true,
                  header: const WaterDropHeader(),
                  footer: CustomFooter(
                    builder: (context, mode) {
                      Widget body;
                      if (mode == LoadStatus.idle) {
                        body = Text(
                          'dashboard_pull_up_load'.tr,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey[500],
                          ),
                        );
                      } else if (mode == LoadStatus.loading) {
                        body = Center(child: LoadingWidget());
                      } else if (mode == LoadStatus.failed) {
                        body = Text(
                          'dashboard_load_failed'.tr,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey[500],
                          ),
                        );
                      } else if (mode == LoadStatus.canLoading) {
                        body = Text(
                          'dashboard_release_to_load'.tr,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey[500],
                          ),
                        );
                      } else {
                        final closeComp =
                            AssetsService.to.closeComposition.value;
                        body = SizedBox(
                          height: 120.h,
                          width: 120.h,
                          child: closeComp != null
                              ? Lottie(
                                  composition: closeComp,
                                  fit: BoxFit.contain,
                                  repeat: true,
                                  renderCache: RenderCache.drawingCommands,
                                )
                              : Lottie.asset(
                                  'assets/animations/Close.json',
                                  fit: BoxFit.contain,
                                  repeat: true,
                                  renderCache: RenderCache.drawingCommands,
                                ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 100.0),
                        child: SizedBox(
                          height: 140.h,
                          child: Center(child: body),
                        ),
                      );
                    },
                  ),
                  onRefresh: controller.refresh,
                  onLoading: controller.loadMore,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    itemCount: controller.posts.length,
                    cacheExtent: 1200,
                    addRepaintBoundaries: false,
                    itemBuilder: (context, index) {
                      final post = controller.posts[index];
                      final postId = post.id ?? '';
                      final child = RepaintBoundary(
                        key: ValueKey(postId),
                        child: PostItem(
                          key: ValueKey(postId),
                          post: post,
                          isLikedRx: controller.likedState(postId),
                          likeCountRx: controller.likeCount(postId),
                          isFollowedRx: controller.followedState(postId),
                          onLike: () => controller.toggleLike(post),
                          onReport: () => controller.reportPost(post),
                          onFollow: () => controller.toggleFollow(post),
                          currentUserId: controller.currentUserId,
                        ),
                      );
                      return _PostKeepAlive(
                        key: ValueKey('keep_$postId'),
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 20.h),
                          child: Obx(() {
                            final isNew = controller.newPostId.value == post.id;
                            return isNew
                                ? NewPostAnimator(
                                    key: ValueKey('anim_$postId'),
                                    dashController: controller,
                                    child: child,
                                  )
                                : child;
                          }),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostKeepAlive extends StatefulWidget {
  final Widget child;

  const _PostKeepAlive({super.key, required this.child});

  @override
  State<_PostKeepAlive> createState() => _PostKeepAliveState();
}

class _PostKeepAliveState extends State<_PostKeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
