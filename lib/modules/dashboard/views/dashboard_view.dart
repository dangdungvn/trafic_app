import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/widgets.dart';
import '../widgets/post_item_shimmer.dart';

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
        body: RefreshIndicator(
          onRefresh: controller.refresh,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                floating: false,
                snap: false,
                pinned: true,
                elevation: 0,
                automaticallyImplyLeading: false,
                toolbarHeight: 60.h,
                titleSpacing: 24.w,
                title: const DashboardHeader(),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(64.h),
                  child: Container(
                    padding: EdgeInsets.only(
                      left: 16.w,
                      right: 16.w,
                      bottom: 16.h,
                    ),
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
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 10.h)),
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
                          Icon(
                            Icons.article_outlined,
                            size: 64.w,
                            color: Colors.grey[400],
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
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final post = controller.posts[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 20.h),
                        child: PostItem(
                          post: post,
                          onLike: () => controller.toggleLike(post),
                          onReport: () => controller.reportPost(post),
                        ),
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
    );
  }
}
