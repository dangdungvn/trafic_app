import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../services/assets_service.dart';
import '../controllers/dashboard_controller.dart';
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
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // Header cố định
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(
                left: 24.w,
                right: 24.w,
                top: MediaQuery.of(context).padding.top + 10.h,
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
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF04060F).withOpacity(0.05),
                    offset: const Offset(0, 2),
                    blurRadius: 50,
                  ),
                ],
              ),
              child: DashboardSearchBar(
                controller: controller.searchController,
              ),
            ),
            SizedBox(height: 10.h),
            // Content với RefreshIndicator
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refresh,
                child: CustomScrollView(
                  slivers: [
                    Obx(() {
                      if (controller.isLoading.value) {
                        return SliverPadding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 20.h),
                                  child: const PostItemShimmer(),
                                );
                              },
                              childCount: 5, // Show 5 shimmer items
                            ),
                          ),
                        );
                      }

                      if (controller.posts.isEmpty) {
                        return SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 260.h,
                                  child:
                                      AssetsService
                                              .to
                                              .notFoundComposition
                                              .value !=
                                          null
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
                                          renderCache:
                                              RenderCache.drawingCommands,
                                        ),
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'Chưa có bài viết nào',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final post = controller.posts[index];
                            final isNew = controller.newPostId.value == post.id;
                            final child = RepaintBoundary(
                              key: ValueKey(post.id),
                              child: PostItem(
                                key: ValueKey(post.id),
                                post: post,
                                onLike: () => controller.toggleLike(post),
                                onReport: () => controller.reportPost(post),
                              ),
                            );
                            return Padding(
                              padding: EdgeInsets.only(bottom: 20.h),
                              child: isNew
                                  ? _NewPostAnimator(
                                      key: ValueKey('anim_${post.id}'),
                                      dashController: controller,
                                      child: child,
                                    )
                                  : child,
                            );
                          }, childCount: controller.posts.length),
                        ),
                      );
                    }),
                    Obx(() {
                      if (controller.isLoadingMore.value) {
                        return SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: const Color(0xFF4D5DFA),
                              ),
                            ),
                          ),
                        );
                      }
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    }),
                    SliverToBoxAdapter(child: SizedBox(height: 70.h)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget bọc bài viết mới: slide xuống từ trên + fade in khi vừa được đăng
class _NewPostAnimator extends StatefulWidget {
  final Widget child;
  final DashboardController dashController;

  const _NewPostAnimator({
    super.key,
    required this.child,
    required this.dashController,
  });

  @override
  State<_NewPostAnimator> createState() => _NewPostAnimatorState();
}

class _NewPostAnimatorState extends State<_NewPostAnimator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeIn);

    _anim.forward();
    _anim.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.dashController.clearNewPostId();
      }
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
