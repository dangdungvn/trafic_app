import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
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
        body: CustomScrollView(
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
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              sliver: Obx(
                () => SliverList(
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
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 70.h)),
          ],
        ),
      ),
    );
  }
}
